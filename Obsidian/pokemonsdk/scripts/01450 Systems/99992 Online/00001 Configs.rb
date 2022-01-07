module Configs
  # Configuration for the PSDK online engine
  class OnlineConfig
    # If the online is enabled
    # @return [Boolean]
    attr_accessor :enabled
    # IP address of the server
    # @return [String]
    attr_accessor :server_ip
    # Port of the server
    # @return [Integer]
    attr_accessor :server_port

    # Create a new config
    def initialize
      @enabled = false
      @server_ip = '127.0.0.1'
      @server_port = 3259
    end
  end

  # @!method self.online_configs
  #   @return [OnlineConfig]
  register(:online_configs, 'online_configs', :yml, true, OnlineConfig)
end
