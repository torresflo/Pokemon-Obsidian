#encoding: utf-8
require 'zlib'
require 'csv'
languages = ['de','en','es','fr','it','kana','ko']

begin
  text_files = languages.map do |lang|
    next [
      lang,
      Marshal.load(Zlib::Inflate.inflate(Marshal.load(File.binread("#{lang}.dat"))))
    ]
  end.to_h

  Dir['Dialogs/1000*.csv'].each do |filename|
    id_file = filename.sub('Dialogs/', '').to_i - 100_000
    rows = CSV.read(filename)
    lang_row = rows.shift
    lang_row.each_with_index do |lang, i|
      next unless text_files[lang]
      text_files[lang][id_file] = rows.map { |row| row[i].to_s }
    end
  end

  text_files.each do |lang, data|
    File.binwrite(
      "#{lang}.dat",
      Marshal.dump(Zlib::Deflate.deflate(Marshal.dump(data)))
    )
  end
rescue Exception
  p $!,$!.message, $!.backtrace
  system("pause")
end
  