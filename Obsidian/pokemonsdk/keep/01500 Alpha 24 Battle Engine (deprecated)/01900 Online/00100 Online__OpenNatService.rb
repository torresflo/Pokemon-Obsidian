# Module that manage Online Interaction of Pokemon SDK
# @note : Uses https://gitlab.com/NuriYuri/rubyliteigd
module Online
  # Class that helps to open port using LiteIGD
  # @note This class is called OpenNatService because in previous PSDK versions and application named "Yuri's Open.Nat Service" was used to manage the port opening.
  class OpenNatService
    # Default game port
    GamePort = 1060
    # Default port description
    PortDescr = "Port de communication Online pour PSDK"
    # Default port time to leave (port is open of 1 hour)
    PortTime = 3600
    # Variable that tells the IGD has already been found
    @@found_once = false
    # IP Address of the Computer on the internet (private IP if no IGD found)
    # @return [String]
    attr_reader :public_ip
    # IP address of the Computer on the network
    # @return [String]
    attr_reader :private_ip
    # If an IGD has been found 
    # @return [Boolean]
    attr_reader :igd_available
    # Port of the self hosted server on the Internet
    # @return [Integer]
    attr_reader :public_port
    # Port of the self hosted server on the network
    # @return [Integer]
    attr_reader :private_port
    # Create a new OpenNatService instance
    def initialize
      retreive_ips
    end
    # Retreive the IP adresses of the computer
    def retreive_ips
      #LiteIGD.enable_debug
      @valid = true
      @private_ip = LiteIGD.get_internal_ip_address
      unless @@found_once or LiteIGD.search_WANConnection
        @igd_available = false
        @public_ip = @private_ip
      else
        LiteIGD.load_igd_device
        ip = LiteIGD.get_external_ip_address
        if(ip.is_a?(Hash)) #> A failure :v
          @igd_available = false
          return @public_ip = @private_ip
        end
        @igd_available = true
        @public_ip = ip.to_s
        @@found_once = true
      end
    end
    # Open a port
    # @param span [Integer] number of port to try until the opening is considered as a failure
    # @param port [Integer] first port in the span you'd like to open
    # @param ttl [Integer] number of second the port should stay open
    # @param protocol [String] protocol used on the port
    # @return [Integer, nil] port if success, nil if failure
    def open_port(span, port = GamePort, ttl = PortTime, protocol = LiteIGD::TCP)
      if @igd_available
        port.upto(port + span) do |i|
          port = LiteIGD.get_port(i)
          if port.is_a?(LiteIGD::PortMapping)
            if port.internal_ip == @private_ip and check_port(i)
              LiteIGD.delete_port(i, protocol)
              LiteIGD.add_port(i, protocol, i, @private_ip, PortDescr, ttl)
            else
              next
            end
          else
            next unless check_port(i)
            LiteIGD.add_port(i, protocol, i, @private_ip, PortDescr, ttl)
          end
          return @private_port = @public_port = i
        end
      else
        port.upto(port + span) { |i| return @private_port = @public_port = i if check_port(i) }
      end
      return nil
    end
    # Check if a port is not used
    # @param port [Integer] the port to check
    # @return [Boolean] true if not used
    def check_port(port)
      begin
        TCPServer.new("0.0.0.0", port).close
      rescue Exception
        return false
      end
      begin
        sock = UDPSocket.new
        sock.bind("0.0.0.0", port)
        sock.close
      rescue Exception
        return false
      end
      return true
    end
    # Code cipher for the IP section (max value of each cell : 700)
    CodeIP = [611, 530, 220, 305] # /!\ ne jamais dépasser 700
    # Code cipher for the PORT section (max value : 33000)
    CodePORT = 29312
    # Generate a port from this object (or specific parameters)
    # @param offset [Integer] offset to add to the IP section to prevent service collision (Battle/Trade)
    # @param public_ip [String] IP of the computer on the Internet or where it's visible
    # @param public_port [Integer] public port to use
    # @return [String] the code to exchange to the partner
    def code(offset = 0, public_ip = @public_ip, public_port = @public_port)
      port_str = sprintf('%05d',(public_port + CodePORT)) # /!\ Ne jamais dépasser 33000
      public_ip_arr = public_ip.split('.')
      str = port_str[4]
      4.times do |i|
        str << (sprintf('%03d',(public_ip_arr[i].to_i + (CodeIP[i] + offset * i) % 744)) + port_str[i])
      end
      return str
    end
    # Retrieve the IP and the Port from a code
    # @param _code [String] the code
    # @param offset [Integer] offset to add to the IP section to prevent service collision (Battle/Trade)
    # @return [Array<String, Integer>, nil] ip, port or nil if failure (bad code)
    def self.decode(_code, offset = 0)
      return nil if _code.size != 17
      port = 10_000 * _code[4].to_i +
        1_000 * _code[8].to_i + 100 * _code[12].to_i + 10 * _code[16].to_i + _code[0].to_i
      port -= CodePORT
      return nil if port < 0
      ip = Array.new(4) { |i| self.get_ip_component(_code, i, offset) }
      return nil if ip.include?(nil)
      return ip.join('.'), port
    end
    # Get a part of the IP adress
    # @param _code [String] the code
    # @param i [Integer] index of the Byte of the IP to retrieve
    # @param offset [Integer] offset to add to the IP section to prevent service collision (Battle/Trade)
    # @return [Integer, nil] nil if bad code
    def self.get_ip_component(_code, i, offset)
      ip = _code[i * 4 + 1,3].to_i - (CodeIP[i] + offset * i) % 744
      return nil unless ip.between?(0, 255)
      ip
    end
  end
end
