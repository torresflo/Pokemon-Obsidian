#encoding: utf-8

#> Prevent the game from launching
$GAME_LOOP = proc {}


#<====>
# sanitize function
# Credits : http://gavinmiller.io/2016/creating-a-secure-sanitization-function/
def sanitize(filename)
  # Bad as defined by wikipedia: https://en.wikipedia.org/wiki/Filename#Reserved_characters_and_words
  # Also have to escape the backslash
  bad_chars = [ '/', '\\', '?', '%', '*', ':', '|', '"', '<', '>', '.', ' ' ]
  bad_chars.each do |bad_char|
    filename.gsub!(bad_char, '_')
  end
  filename.gsub!(/[éèë]/i, 'e')
  filename.gsub!(/[âà]/i, 'a')
  filename.gsub!(/[ïìî]/i, 'i')
  filename.gsub!(/[ùû]/i, 'u')
  filename
end
#<====>

# Function that remove all the PSDK (xxx00 name) script from a path)
# @param path [String] path containing the scripts
def clean_path(path)
  Dir[File.join(path, '*.rb')].each do |filename|
    File.delete(filename) if filename =~ /^[0-9]{3}00 .*/
  end
end

scripts = load_data(format('%s/Data/Scripts.rxdata', PSDK_PATH))
base_path = format('%s/scripts', PSDK_PATH)
Dir.mkdir(base_path) unless Dir.exist?(base_path)

path_index = 1
script_index = 0
current_path = base_path
clean_path(current_path)

scripts.each do |script|
  script_index += 1
  script_name = script[1].force_encoding(Encoding::UTF_8)
  # New script path (organization)
  if script_name =~ /^__.*__/
    current_path = script_name.gsub(/__(.*)__/) { $1 }
    current_path = File.join(base_path, format('%05d %s', path_index * 100, sanitize(current_path)))
    Dir.mkdir(current_path) unless Dir.exist?(current_path)
    clean_path(current_path)
    path_index += 1
    script_index = 0
    next
  end
  script_content = Zlib::Inflate.inflate(script[2]).force_encoding(Encoding::UTF_8)
  next if script_content.size < 10
  script_content.gsub!(/\r\n[ ]+\r\n/, "\r\n\r\n")
  script_content = "#encoding: utf-8\r\n\r\n#{script_content}\r\n"
  File.open(File.join(current_path, name = format('%05d %s.rb', script_index * 100, sanitize(script_name))), 'wb') do |f|
    puts name
    f << script_content
  end
end