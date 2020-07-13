require 'zlib'
def load_data(fn)
  File.open(fn,"rb") do |f| return Marshal.load(f) end
end
SpeEsp = "\xE2\x80\xAF".force_encoding("UTF-8")
GSpeEsp = "\xC2\xA0".force_encoding("UTF-8")
BugStr = "\xEF\xBB\xBF".force_encoding("UTF-8")

def clean(text)
  text.force_encoding("UTF-8")
  text.gsub!(SpeEsp, GSpeEsp)
  text.gsub!(BugStr, '')
  text.force_encoding("UTF-8")
end
Dir['*.dat'].each do |datname|
  texts_arr = Marshal.load(Zlib::Inflate.inflate(load_data(datname)))
  texts_arr.each do |texts|
    texts.each do |text|
      clean(text)
    end
  end
  
  dump_str = Marshal.dump(texts_arr)
  defl_str = Zlib::Deflate.deflate(dump_str)
  f = File.new(datname,"w")
  Marshal.dump(defl_str, f)
  f.close
  #> Pour l'instant pas de save
end
system("pause")