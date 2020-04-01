# Class that helps doing stuff related to Directories
class Dir
  # Make a new dir by following the path
  # @param path [String] the new path to create
  # @example Dir.mkdir!("a/b/c") will create a, a/b and a/b/c.
  def self.mkdir!(path)
    total_path = ''
    path.split(%r{[/\\]}).each do |dirname|
      next if dirname.empty?
      total_path << dirname
      Dir.mkdir(total_path) unless Dir.exist?(total_path)
      total_path << '/'
    end
  end
end

Dir.mkdir!('Data/Text/Dialogs') # Alpha 23.17 fix
