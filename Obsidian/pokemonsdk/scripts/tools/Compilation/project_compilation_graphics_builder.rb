module ProjectCompilation
  class GraphicsBuilder
    def initialize(origin_vd, target_vd, path, no_recursive)
      puts "Loading #{path}"
      @files = {}
      load_all_original_files(origin_vd)
      load_files_from_path(path, no_recursive)
      puts "Saving #{path}"
      save(target_vd)
    end

    def save(target_vd)
      vd = Yuki::VD.new(target_vd, :write)
      @files.each do |filename, data|
        vd.write_data(filename, data)
      end
      vd.close
      vd = nil
      @files = nil
      GC.start
    end

    def load_all_original_files(origin_vd)
      vd = Yuki::VD.new(origin_vd, :read)
      vd.get_filenames.each do |filename|
        @files[filename.downcase] = vd.read_data(filename)
      end
      vd.close
      vd = nil
    end

    def load_files_from_path(path, no_recursive)
      load_all_from_path(path, path)
      return if no_recursive
      load_recursive_from_path(path, path)
    end

    def load_recursive_from_path(path, current_path)
      Dir["#{current_path}/*/"].each do |sub_path|
        real_sub_path = sub_path[0...-1]
        load_all_from_path(path, real_sub_path)
        load_recursive_from_path(path, real_sub_path)
      end
    end

    def load_all_from_path(base_path, path)
      Dir["#{path}/*.png"].each do |filename|
        @files[filename.downcase.sub(%r{^#{base_path}/}i, '').sub(/\.[^.]+$/, '')] = File.binread(filename)
      end
      Dir["#{path}/*.gif"].each do |filename|
        @files[filename.downcase.sub(%r{^#{base_path}/}i, '')] = File.binread(filename)
      end
    end

    def self.start(origin_vd, target_vd, path, no_recursive)
      new(origin_vd, target_vd, path, no_recursive)
    end
  end
end
