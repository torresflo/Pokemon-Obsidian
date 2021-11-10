#encoding: utf-8

# Class that manage the IO
class IO
  # Time to wait for the IO.select function
  SLP_TIME = 0.00001
  # Test if the IO contain data that can be read
  # @return [Boolean] if data can be read from the IO
  def readable?
    return IO.select([self], nil, nil, SLP_TIME) != nil
  end
end
# Class that manage TCP incoming connections
class TCPServer
  # Alias to detect if the Server has incoming connection
  # @return [Boolean] if data can be read from the IO
  alias accepting? readable?
end
