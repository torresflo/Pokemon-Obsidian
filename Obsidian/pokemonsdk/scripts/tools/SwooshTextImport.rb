# This script allow to convert all event text to CSV
#
# To get access to this script write :
#   ScriptLoader.load_tool('SwooshTextImport')
#
# To execute this script write :
#   SwooshTextImport.run(path_of_swoosh_text)
module SwooshTextImport
  # Path containg all the texts
  COMMON_PATH = 'common'
  # Mapping between text file and available languages
  LANGUAGE_MAPPING = {
    'ch' => 'ch-simplified.txt',
    'kana' => 'ja-katakana.txt'
  }
  LANGUAGE_MAPPING.default_proc = proc { |hash, key| hash[key] = "#{key}.txt" }
  # Mapping between filename & fileid
  FILE_MAPPING = {
    'monsname' => 0, 'zkn_type' => 1, 'zukan_comment_B' => 2, 'typename' => 3,
    'tokusei' => 4, 'tokuseiinfo' => 5, 'wazaname' => 6, 'wazainfo' => 7,
    'place_name_spe' => 9,
    'itemname' => 12, 'itemname_plural' => 9001 - GameData::Text::CSV_BASE, 'iteminfo' => 13,
    'bag_pocket' => 15, 'boxname' => 16,
    'trainermemo' => 28, # /!\ don't forget to shift the resulting array!
    'shinka_demo' => 31,
    'nuts_name' => 40,
    'strinput' => 43,
    'waza_con' => 49, # Contest move description depending on their data
    'waza_remember' => 50, # Move reminder text
    'dressup' => 51, # Text of the dress show
    'btl_app' => 52, # Battle Menu text
    'bag' => 53, # Swoosh bag (not overwriting 22 for compatibility)
    'pokelist' => 54, # Swoosh party menu (not overwriting 23)
    'mystery' => 55, # Mystery gift UI
    'tamago_demo' => 56, # When pokemon gets out of the egg
    'pokedex' => 57, # Pokedex UI
    'trainer_license_comon' => 58, # Additional text for 34 (TCARD)
    'btl_set' => 59, # 59 is used instead of 19 to prevent unwanted displacement of texts
    'btl_std' => 60, # 60 is used instead of 18 to prevent unwanted displacement of texts
  }

  # List of replacements
  REPLACEMENTS = [
    ['', '$'], [' ', ' '], ['[VAR 0101', '[VAR PKNAME'], ['[VAR 0100', '[VAR TRNAME'], ['[VAR 0102', '[VAR PKNICK'],
    ['[VAR 0106', '[VAR ABILITY'], ['[VAR 010A', '[VAR ITEM2'], ['[VAR 0107', '[VAR MOVE'], ['[VAR 1101', '[VAR NUMBRNCH'],
    ['[VAR 010C', '[VAR PKNICK'], ['[VAR 0200', '[VAR NUM1'], ['[VAR 0201', '[VAR NUM2'], ['[VAR 0202', '[VAR NUM3'],
    ['[VAR 019E', '[VAR TRNAME'], ['[VAR FF00', '[VAR COLOR']
  ]

  module_function

  # Run the text import
  # @param path [String] path containing the common folder with all texts
  def run(path)
    texts = load_texts(path)
    log_info('Cleaning file 28')
    texts.each { |k, v| v.each(&:shift) if k == 28 }
    # This version will not try to merge, it'll just import,
    # if you need merging, please go back to commit 251dbab0f1478d34893a6ce792049c7055980610 on pokemonsdk/project
    write_csv_without_comparison(texts)
  end

  # Load all the text and sort them by file_id by language in GameData::Text::Available_Langs order
  # @param path [String] path containing the common folder with all texts
  # @return [Hash{ Integer => Array<Array<String>> }]
  def load_texts(path)
    files_per_lang = GameData::Text::Available_Langs.map do |lang|
      filename = File.join(path, COMMON_PATH, LANGUAGE_MAPPING[lang])
      next load_and_clean_file(filename)
    end
    log_info('Grouping files per name')
    files_per_lang.map! { |data| data.split("~~~~~~~~~~~~~~~\n")[1..-1].each_slice(2).to_a }
    log_info('Cleaning slices')
    files_per_lang.map! do |slices|
      slices.map! { |slice| [FILE_MAPPING[slice[0].sub('Text File : ', '').strip], slice[1].split("\n")] }
      slices.select! { |slice| slice[0].is_a?(Integer) }
      next slices.to_h
    end
    log_info('Grouping by file_id')
    return files_per_lang[0].keys.map do |key|
      [key, files_per_lang.map { |hash| hash[key] }]
    end.to_h
  end

  # Function that load the file content and clean the chars in it
  # @param filename [String]
  def load_and_clean_file(filename)
    log_info("Loading #{filename}")
    if filename.include?('kana.txt')
      data = File.binread(filename)[2..-1].force_encoding(Encoding::UTF_16LE).encode(Encoding::UTF_8).gsub("\r\n", "\n")
    else
      data = File.read(filename, mode: 'r:bom|utf-8')
    end
    REPLACEMENTS.each { |(s, r)| data.gsub!(s, r) }
    return data
  end

  # Function that writes all the CSV
  # @param texts [Hash{ Integer => Array<Array<String>> }]
  def write_csv_without_comparison(texts)
    texts.each do |file_id, lang_array|
      filename = "Data/Text/Dialogs/#{file_id + GameData::Text::CSV_BASE}.csv"
      log_info("Writing: #{filename}")
      lang_array = lang_array.transpose
      fix_pokedex_description(filename, lang_array) if file_id == 2
      CSV.open(filename, 'w') do |csv|
        csv << GameData::Text::Available_Langs
        lang_array.each { |row| csv << row }
      end
    end
  end

  # Function that ensure Pokedex Description are right
  # @param filename [String]
  # @param lang_array [Array]
  def fix_pokedex_description(filename, lang_array)
    data = CSV.read(filename)
    data.shift
    lang_array.map!.with_index do |row, i|
      (data[i] || row).map.with_index { |v, j| v == 'NewText' ? row[j] : v }
    end
  end
end
