#encoding: utf-8
module Kernel
  module_function
  alias old_require require
  def require(file)
    old_require file
  rescue LoadError
    file = String.new(file)
    file << '.rb' unless file.include?('.rb')
    $LOAD_PATH.each do |path|
      filename = "#{path.encode(Encoding::UTF_8)}/#{file}"
      if File.exist?(filename)
        return old_require(filename)
      end
    end
  end
end
# Replace binary updates
(Dir["plugins/*.update"] + Dir["ruby_builtin_dlls/*.update"]).each do |filename_u|
  filename = filename_u.gsub('.update','')
  File.delete(filename) if File.exist?(filename)
  File.rename(filename_u, filename)
end