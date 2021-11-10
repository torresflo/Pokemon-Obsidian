module ProjectCompilation
  module DataBuilder
    module_function

    def start(release_path)
      unless ARGV.include?('skip_battle_event')
        puts 'Building battle events'
        compile_battle_event
      end
      puts 'Building Data'
      DATA_FILES.each do |id, getter|
        make_vd(File.join(release_path, "Data/#{id}.dat"), instance_exec(&getter))
      end
    end

    def make_vd(vd_filename, files)
      vd = Yuki::VD.new(vd_filename, :write)
      files.each do |filename|
        next unless File.exist?(filename)
        puts filename
        basename = filename.start_with?('Data/Buildings/') ? filename.gsub('Data/Buildings/', 'buildings_') : File.basename(filename)
        vd.write_data(basename.downcase, File.binread(filename))
      end
      vd.close
    end

    def get_data_files
      return @map_files, @data_files if @map_files && @data_files
      data_files = Dir['Data/*.*'] + Dir['Data/Buildings/*.rxdata'] + Dir['Data/configs/**/*.rxdata']
      data_files.delete('Data/Scripts.rxdata')
      data_files.delete('Data/PSDK_BOOT.rxdata')
      data_files.delete('Data/PSDK_BOOT.rb')
      data_files.delete('Data/Animations-original.rxdata')
      data_files.delete('Data/Animations.psdk')
      map_files = data_files.grep(%r{^Data/Map})
      data_files -= map_files
      @map_files = map_files
      @data_files = data_files
      return map_files, data_files
    end

    def compile_battle_event
      Dir['Data/Events/Battle/*.rb'].each do |filename|
        id = filename.match(%r"([0-9]{5})[^/]*\.rb")&.[](1)
        next unless id

        puts "Building battle event: #{filename}"
        script = Utils.compile(filename, File.read(filename))
        File.binwrite("Data/Events/Battle/#{id}.yarbc", Marshal.dump(Zlib::Deflate.deflate(script)))
      end
    end
  end
end
