# Module that holds all the class and method of LiteIGD
# Not Done :
#   -> Checking WANIPConnection service capabilities (AddPortMap on etc...)
module LiteIGD
  Service = Struct.new :type, :id, :control_url, :scpdurl, :event_sub_url
  Device = Struct.new :devices, :services, :type, :name, 
    :manufacturer, :manufacturer_url, :model_name, :udn, :presentation_url, :serial_number
  PortMapping = Struct.new :external_port, :protocol, :internal_port, :internal_ip, :description, :duration, :enabled, :remote_host
  
  WANIP = ["WANIPConnection:2", "WANIPConnection:1"]
	WANPPP = ["WANPPPConnection:2", "WANPPPConnection:1"]
  #ActionXML = '<?xml version="1.0"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><SOAP-ENV:Body><m:%{action} xmlns:m="%{type}">%{arguments}</m:%{action}></SOAP-ENV:Body></SOAP-ENV:Envelope>'
  UDP = "UDP"
  TCP = "TCP"
  ActionXML = <<-EOF
<s:Envelope 
   xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" 
   s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
   <s:Body>
	  <u:%{action} xmlns:u="%{type}">%{arguments}
	  </u:%{action}>
   </s:Body>
</s:Envelope>

EOF
  
  @debug = false
  module_function
  # Function that display debug info
  def debug(str, ret = false)
    puts str if @debug
    return ret
  end
  # Enable the debug
  def enable_debug
    @debug = true
  end
  # Disable the debug
  def disable_debug
    @debug = false
  end
  # Function that send a httpu request and retreive the result if possible
  # @param ip [String] ip of the server
  # @param port [Integer] port of the server
  # @param data [String] data
  # @return [String, nil]
  def httpu_get(ip, port, data)
    socket = UDPSocket.new
    debug("Sending httpu data to #{ip} #{port}")
    socket.send(data, 0, ip, port)
    sleep(0.25)
    max_times = 3
    times = 1
    begin
      debug("Attempt to receive data n°#{times}")
      return_data = socket.recvfrom_nonblock(4096)
      return return_data
    rescue IO::WaitReadable
      if times < max_times
        times += 1
        IO.select([socket], nil, nil, 0.5)
        debug("Resending data httpu data")
        socket.send(data, 0, ip, port)
        retry
      end
    end
    return nil
  end
  # Constant that contains the IGD search request
  SEARCH_IGD = "M-SEARCH * HTTP/1.1\r\nHost: 239.255.255.250:1900\r\nST: urn:schemas-upnp-org:device:InternetGatewayDevice:1\r\nMan: \"ssdp:discover\"\r\nMX: 3\r\n\r\n"
  # Search an IGD device
  # @return [Boolean] if the operation was a success
  def search_igd
    debug("Searching for a IGD")
    data = httpu_get("239.255.255.250", 1900, SEARCH_IGD)
    if(data)
      return load_location_from_httpu_data(data.first)
    else
      debug "Failed to find IGD"
      return false
    end
  end
  # Load IGD device
  # @return [Boolean] if the operation was a success
  def load_igd_device
    return debug("No IGD location...") unless @igd_location
    debug("Loading IGD description...")
    res = Net::HTTP.get_response(URI(@igd_location_descr))
    if res.is_a?(Net::HTTPSuccess)
      xml = REXML::Document.new(res.body).root
    else
      return debug("Failed to load IGD description... #{res}")
    end
    #> Adjust IGD Location (for URL formating)
    url_base = xml.get_text('URLBase')
    @igd_location = url_base if url_base
    debug "Updated IGD location #@igd_location"
    @igd_device = {}
    scan_device_in_xml(xml, @igd_device)
    device = (@igd_device["InternetGatewayDevice:1"] || @igd_device["InternetGatewayDevice:2"])
    return debug("Device not found...") unless(device)
    device = (device.devices["WANDevice:1"] || device.devices["WANDevice:2"])
    return debug("WAN device not found...") unless(device)
    device = (device.devices["WANConnectionDevice:1"] || device.devices["WANConnectionDevice:2"])
    return debug("WAN connection device not found...") unless(device)
    debug "Devices found !"
    debug "Searching WANIPConnection..."
    #> Searching for a WANIP service
    debug("WAN IP connection service not found") unless find_wan_service(device, WANIP)
    unless @wan_service
      #> Searching for a WANPPP service
      return debug("WAN PPP connection service not found") unless find_wan_service(device, WANPPP)
    end
    return true
  end
  # Find a WANIP/WANPPP service in the IGD
  # @param device [Device]
  # @param const [Array<String>] type of services
  # @return [Boolean]
  def find_wan_service(device, const)
    const.each do |i|
      service = device.services[i]
      if(service)
        @wan_service = service
        debug("ControlURL : #{service.control_url}")
        debug("Service description url : #{service.scpdurl}")
        return true
      end
    end
    return false
  end
  # Scan devices out of an XML Element
  # @param xml [REXML::Element] element to extract devices
  # @param hash [Hash{String => Device}]
  # @return hash
  def scan_device_in_xml(xml, hash)
    xml.each_element('device') do |device|
      #> Creating device and storing it to the hash
      dev = Device.new({}, {})
      type = device.get_text('deviceType').to_s
      hash[type.split(':')[-2, 2].join(':')] = dev
      # Loading device data
      dev.type = type
      dev.name = device.get_text('friendlyName').to_s
      dev.manufacturer = device.get_text('manufacturer').to_s
      dev.manufacturer_url = device.get_text('manufacturerURL').to_s
      dev.model_name = device.get_text('modelName').to_s
      dev.serial_number = device.get_text('serialNumber').to_s
      dev.udn = device.get_text('UDN').to_s
      dev.presentation_url = device.get_text('presentationURL').to_s
      # Loading device services
      service_hash = dev.services
      device.each_element('serviceList/service') do |service|
        #> Creating service
        type = service.get_text('serviceType').to_s
        service_hash[type.split(':')[-2, 2].join(':')] = 
          Service.new(type, 
            service.get_text('serviceId').to_s, 
            service.get_text('controlURL').to_s,
            service.get_text('SCPDURL').to_s,
            service.get_text('eventSubURL').to_s)
      end
      # Loading device sub devices
      device.each_element('deviceList') do |device_list|
        scan_device_in_xml(device_list, dev.devices)
      end
    end
    return hash
  end
  # Constant that contains the WANIPConnection search request
  SEARCH_WANCON = "M-SEARCH * HTTP/1.1\r\nHost: 239.255.255.250:1900\r\nST: urn:schemas-upnp-org:service:%s\r\nMan: \"ssdp:discover\"\r\nMX: 3\r\n\r\n"
  # Search an IGD device
  def search_WANConnection
    WANIP.each do |i|
      data = httpu_get("239.255.255.250", 1900, sprintf(SEARCH_WANCON, i))
      return load_location_from_httpu_data(data.first) if(data)
    end
    debug("Failed to find WANIPConnection")
    WANPPP.each do |i|
      data = httpu_get("239.255.255.250", 1900, sprintf(SEARCH_WANCON, i))
      return load_location_from_httpu_data(data.first) if(data)
    end
    return false
  end
  # Load the location from the httpu data
  # @param data [String]
  # @return [Boolean] for now always true :v
  def load_location_from_httpu_data(data)
    debug data
    data.gsub(/LOCATION:([^\r\n]+)/i) do |i| @igd_location_descr = $1.strip end
    debug "IGD location : #@igd_location_descr"
    @igd_location = @igd_location_descr.split('/')[0, 3].join('/')
    return true
  end
  # Send an action to the service
  # @param service [Service] the service that should receive the action
  # @param action [String] case sensitive : action to perform
  # @param param [Hash<String => String>] the parameters of the action (case sensitive)
  # @return [Hash]
  def send_action(service, action, param)
    param_str = ""
    param.each do |key, value|
      param_str << '<%{key}>%{value}</%{key}>'.%(key: key, value: value)
    end
    xmldata = ActionXML.%(type: service.type, action: action, arguments: param_str)
    req = Net::HTTP::Post.new(uri = URI(@igd_location + service.control_url))
    req.content_type = 'text/xml; charset="utf-8"'
    req['SOAPAction'] = '"%{type}#%{action}"'.%(type: service.type, action: action)
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req, xmldata)
    end
    #res = Net::HTTP.request(req, xmldata)
    xml = REXML::Document.new(res.body).root
    if(res.is_a?(Net::HTTPSuccess))
      xml.each_element('s:Body/u:*') do |element|
        return {is_error: false, has_xml: true, xml: element}
      end
    else
      return {is_error: true, 
        faultcode: xml.get_text('s:Body/s:Fault/faultcode').to_s,
        faultstring: xml.get_text('s:Body/s:Fault/faultstring').to_s,
        code: xml.get_text('s:Body/s:Fault/detail/UPnPError/errorCode').to_s.to_i,
        descr: xml.get_text('s:Body/s:Fault/detail/UPnPError/errorDescription').to_s
      }
    end
    return {is_error: false, has_xml: false}
  end
  # Retreive the external ip address
  # @return [String, Hash, false, nil] if Hash/false => error
  def get_external_ip_address
    return debug('No WAN Service') unless @wan_service
    hash = send_action(@wan_service, 'GetExternalIPAddress', {})
    return hash if(hash[:is_error])
    return nil unless(hash[:has_xml])
    return hash[:xml].get_text('NewExternalIPAddress')
  end
  # Retreive the internal ip address of the current machine (ipv4)
  # @return [String] 127.0.0.1 if not found
  def get_internal_ip_address
    sock = UDPSocket.new
    sock.connect('1.0.0.1', 1) #@igd_location.split('//').last.split('/').first.split(':').first
    return sock.addr.last
  rescue Exception
    return "127.0.0.1"
  end
  # Delete a port mapping
  # @param external_port [Integer]
  # @param protocol ["UDP", "TCP"]
  # @param remote_host [String]
  # @return [Hash, false] false => error
  def delete_port(external_port, protocol = TCP, remote_host = '')
    return debug('No WAN Service') unless @wan_service
    return send_action(@wan_service, 'DeletePortMapping', 
      NewRemoteHost: remote_host, 
      NewExternalPort: external_port, 
      NewProtocol: (protocol == TCP ? TCP : UDP))
  end
  # Add a port mapping
  # @param external_port [Integer]
  # @param protocol ["UDP", "TCP"]
  # @param internal_port [Integer]
  # @param internal_ip [String]
  # @param description [String]
  # @param duration [Integer]
  # @param enabled [Boolean]
  # @param remote_host [String]
  # @return [Hash, false]
  def add_port(external_port, protocol, internal_port, internal_ip, description, duration = 0, enabled = true, remote_host = '')
    return debug('No WAN Service') unless @wan_service
    return send_action(@wan_service, 'AddPortMapping', 
      NewRemoteHost: remote_host, 
      NewExternalPort: external_port, 
      NewProtocol: (protocol == TCP ? TCP : UDP),
      NewInternalPort: internal_port,
      NewInternalClient: internal_ip,
      NewEnabled: (enabled ? 1 : 0),
      NewPortMappingDescription: description,
      NewLeaseDuration: duration)
  end
  # Enumerate each port registered in the NAT, yield block with a PortMapping object
  # @return [Integer, false] number of ports if no error
  def each_port
    return debug('No WAN Service') unless @wan_service
    i = 0
    ok = true
    while ok
      hash = send_action(@wan_service, 'GetGenericPortMappingEntry', NewPortMappingIndex: i)
      if hash[:is_error]
        ok = false
      elsif xml = hash[:xml]
        yield(PortMapping.new(
            xml.get_text('NewExternalPort').to_s.to_i,
            xml.get_text('NewProtocol').to_s,
            xml.get_text('NewInternalPort').to_s.to_i,
            xml.get_text('NewInternalClient').to_s,
            xml.get_text('NewPortMappingDescription').to_s,
            xml.get_text('NewLeaseDuration').to_s.to_i,
            xml.get_text('NewEnabled').to_s == '1',
            xml.get_text('NewRemoteHost').to_s
          )
        )
      end
      i += 1
    end
    return i
  end
  # Retreive a specific port mapping 
  # @param external_port [Integer]
  # @param protocol ["UDP", "TCP"]
  # @param remote_host [String]
  # @return [PortMapping, Hash, false] Hash/false => error
  def get_port(external_port, protocol = TCP, remote_host = '')
    return debug('No WAN Service') unless @wan_service
    hash = send_action(@wan_service, 'GetSpecificPortMappingEntry', 
      NewRemoteHost: remote_host, 
      NewExternalPort: external_port, 
      NewProtocol: (protocol == TCP ? TCP : UDP))
    if hash[:is_error]
      return hash
    elsif xml = hash[:xml]
      return PortMapping.new(
          (xml.get_text('NewExternalPort') || external_port).to_s.to_i,
          (xml.get_text('NewProtocol') || protocol).to_s,
          xml.get_text('NewInternalPort').to_s.to_i,
          xml.get_text('NewInternalClient').to_s,
          xml.get_text('NewPortMappingDescription').to_s,
          xml.get_text('NewLeaseDuration').to_s.to_i,
          xml.get_text('NewEnabled').to_s == '1',
          (xml.get_text('NewRemoteHost') || remote_host).to_s
        )
    end
    return hash
  end
end
