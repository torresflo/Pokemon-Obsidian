module Yuki
  # Class that helps to read Virtual Directories
  #
  # In reading mode, the Virtual Directories can be loaded to RAM if MAX_SIZE >= VD.size
  #
  # All the filenames inside the Yuki::VD has to be downcased filename in utf-8
  #
  # Note : Encryption is up to the developper and no longer supported on the basic script
  class VD
    # @return [String] the filename of the current Yuki::VD
    attr_reader :filename
    # Is the debug info on ?
    DEBUG_ON = ARGV.include?('debug-yuki-vd')
    # The max size of the file that can be loaded in memory
    MAX_SIZE = 10 * 1024 * 1024 # 10Mo
    # List of allowed modes
    ALLOWED_MODES = %i[read write update]
    # Size of the pointer at the begin of the file
    POINTER_SIZE = 4
    # Unpack method of the pointer at the begin of the file
    UNPACK_METHOD = 'L'
    # Create a new Yuki::VD file or load it
    # @param filename [String] name of the Yuki::VD file
    # @param mode [:read, :write, :update] if we read or write the virtual directory
    def initialize(filename, mode)
      @mode = mode = fix_mode(mode)
      @filename = filename
      send("initialize_#{mode}")
    end

    # Read a file data from the VD
    # @param filename [String] the file we want to read its data
    # @return [String, nil] the data of the file
    def read_data(filename)
      return nil unless @file
      pos = @hash[filename]
      return nil unless pos
      @file.pos = pos
      size = @file.read(POINTER_SIZE).unpack1(UNPACK_METHOD)
      return @file.read(size)
    end

    # Test if a file exists in the VD
    # @param filename [String]
    # @return [Boolean]
    def exists?(filename)
      @hash[filename] != nil
    end

    # Write a file with its data in the VD
    # @param filename [String] the file name
    # @param data [String] the data of the file
    def write_data(filename, data)
      return unless @file
      @hash[filename] = @file.pos
      @file.write([data.bytesize].pack(UNPACK_METHOD))
      @file.write(data)
    end

    # Add a file to the Yuki::VD
    # @param filename [String] the file name
    # @param ext_name [String, nil] the file extension
    def add_file(filename, ext_name = nil)
      sub_filename = ext_name ? "#{filename}.#{ext_name}" : filename
      write_data(filename, File.binread(sub_filename))
    end

    # Get all the filename
    # @return [Array<String>]
    def get_filenames
      @hash.keys
    end

    # Close the VD
    def close
      return unless @file
      if @mode != :read
        pos = [@file.pos].pack(UNPACK_METHOD)
        @file.write(Marshal.dump(@hash))
        @file.pos = 0
        @file.write(pos)
      end
      @file.close
      @file = nil
    end

    private

    # Initialize the Yuki::VD in read mode
    def initialize_read
      @file = File.new(filename, 'rb')
      pos = @file.pos = @file.read(POINTER_SIZE).unpack1(UNPACK_METHOD)
      @hash = Marshal.load(@file)
      load_whole_file(pos) if pos < MAX_SIZE
    rescue Errno::ENOENT
      @file = nil
      @hash = {}
      log_error(format('%<filename>s not found', filename: filename)) if DEBUG_ON
    end

    # Load the VD in the memory
    # @param size [Integer] size of the VD memory
    def load_whole_file(size)
      @file.pos = 0
      data = @file.read(size)
      @file.close
      @file = StringIO.new(data, 'rb+')
      @file.pos = 0
    end

    # Initialize the Yuki::VD in write mode
    def initialize_write
      @file = File.new(filename, 'wb')
      @file.pos = POINTER_SIZE
      @hash = {}
    end

    # Initialize the Yuki::VD in update mode
    def initialize_update
      @file = File.new(filename, 'rb+')
      pos = @file.pos = @file.read(POINTER_SIZE).unpack1(UNPACK_METHOD)
      @hash = Marshal.load(@file)
      @file.pos = pos
    end

    # Fix the input mode in case it's a String
    # @param mode [Symbol, String]
    # @return [Symbol] one of the value of ALLOWED_MODES
    def fix_mode(mode)
      return mode if ALLOWED_MODES.include?(mode)
      r = (mode = mode.downcase).include?('r')
      w = mode.include?('w')
      plus = mode.include?('+')
      return :update if plus || (r && w)
      return :read if r
      return :write
    end
  end
end
