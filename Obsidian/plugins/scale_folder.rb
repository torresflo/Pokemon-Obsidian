rgss_main do
  $scale = ask_scale
  while folder = ask_folder
    scale_folder(folder)
  end
end

def ask_scale
  scale = nil
  while scale.to_f <= 0.001
    print 'What scale factor would you like to apply ? [default = 0.5] : '
    scale = STDIN.gets.chomp
    scale = 0.5 if scale.empty?
    scale = scale.to_f
    if scale <= 0.001
      puts "Scale cannot be less than 0.001 (got #{scale})"
    end
  end
  return scale
end

def ask_folder
  folder = nil
  until folder
    print "Enter folder where .png files should get scaled by #{$scale} : "
    folder_name = STDIN.gets.chomp.gsub(/^"(.*)"$/) { $1 }
    if File.exist?(folder_name)
      folder = folder_name
    elsif folder_name.empty?
      return nil
    else
      puts "Error : `#{folder_name}` doesn't exist!"
    end
  end
  return folder
end

def scale_folder(path)
  path.gsub!("\\", '/')
  Dir["#{path}/*.png"].each do |filename|
    source = Image.new(filename)
    destination = Image.new((source.width * $scale).to_i, (source.height * $scale).to_i)
    destination.stretch_blt!(destination.rect, source, source.rect)
    destination.to_png_file(filename)
    puts "#{filename} scaled !"
  end
end