PARGV.parse

# Load data from a file
# @param filename [String] name of the file where to load the data
# @param utf8 [Boolean] if the utf8 conversion should be done
# @return [Object]
def load_data(filename, utf8 = false)
  if filename.start_with?('Data/Map')
    return load_data_vd(filename, 'Data/1.dat', utf8)
  elsif filename.start_with?('Data/Text')
    return load_data_vd(filename, 'Data/2.dat', utf8)
  elsif filename.start_with?('Data/PSDK')
    return load_data_vd(filename, 'Data/3.dat', utf8)
  elsif filename.start_with?('Data/Animations/')
    return load_data_vd(filename, 'Data/4.dat', utf8)
  elsif filename.start_with?('Data/Events/Battle/')
    return load_data_vd(filename.split('/').last, 'Data/5.dat', false)
  elsif filename.start_with?('Data/')
    filename = filename.gsub('Data/Buildings/', 'buildings_') if filename.start_with?('Data/Buildings/')
    return load_data_vd(filename, 'Data/0.dat', utf8)
  end
  Marshal.load(File.binread(filename))
end

::Kernel::Loaded = {}

# Load the file from the Yuki::VD file
# @param filename [String] name of the file where to load the data
# @param vdfilename [String] name of the Yuki::VD file
# @param utf8 [Boolean] if the utf8 conversion should be done
def load_data_vd(filename, vdfilename, utf8 = false)
  ::Kernel::Loaded[vdfilename] = Yuki::VD.new(vdfilename, :read) unless ::Kernel::Loaded.key?(vdfilename)
  return Marshal.load(::Kernel::Loaded[vdfilename].read_data(File.basename(filename).downcase)) unless utf8
  return Marshal.load(
    ::Kernel::Loaded[vdfilename].read_data(File.basename(filename).downcase),
    proc do |o|
      o.force_encoding(Encoding::UTF_8) if o.class == String
      next(o)
    end
  )
end

class File
  class << self
    alias old_exist? exist?
    def exist?(filename)
      if filename.start_with?('Data/Buildings')
        ::Kernel::Loaded['Data/0.dat'] ||= Yuki::VD.new('Data/0.dat', :read)
        return ::Kernel::Loaded['Data/0.dat'].exists?(filename.gsub('Data/Buildings/', 'buildings_')) == true
      elsif filename.start_with?('Data/Events/Battle')
        ::Kernel::Loaded['Data/5.dat'] ||= Yuki::VD.new('Data/5.dat', :read)
        return ::Kernel::Loaded['Data/5.dat'].exists?(filename.split('/').last) == true
      end
      return old_exist?(filename)
    end
  end
end


# Save data to a file
# @param data [Object] data to save to a file
# @param filename [String] name of the file
def save_data(data, filename)
  File.binwrite(filename, Marshal.dump(data))
  return nil
end
