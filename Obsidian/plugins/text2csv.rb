require 'csv'
require 'zlib'

Available_Langs = %w[en fr it de es ko kana].freeze
CSV_BASE = 100_000

def write_csv(id, lines)
  CSV.open("Data/Text/Dialogs/#{CSV_BASE + id}.csv", 'wb') do |csv|
    csv << Available_Langs
    lines.each { |line| csv << line }
  end
end

def read_text_file(lang)
  Marshal.load(Zlib::Inflate.inflate(load_data("Data/Text/#{lang}.dat")))
end

def generate_csv
  texts = Available_Langs.collect { |lang| read_text_file(lang) }
  range = 0...texts.size

  texts.first.size.times do |id|
    lines = Array.new(texts.first[id].size) do |line_id|
      range.collect { |lang_id| texts.dig(lang_id, id, line_id) }
    end
    write_csv(id, lines)
    lines = nil
    GC.start
  end
end

generate_csv

rgss_main { 0 }