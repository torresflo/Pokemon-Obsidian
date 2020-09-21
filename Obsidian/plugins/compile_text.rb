# Should be called like this : Game --util=compile_text --script_context=script_index_text_compile.txt
puts "List the lang you want to include in the following langs : #{GameData::Text::Available_Langs.join(',')}"
langs = STDIN.gets.chomp.gsub(/[ \t]+/, '')
GameData::Text::Available_Langs.clear
GameData::Text::Available_Langs.concat(langs.split(','))
GameData::Text.compile
rgss_main {}