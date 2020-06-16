# This script allow to convert all event text to CSV
#
# To get access to this script write :
#   ScriptLoader.load_tool('EventText2CSV')
#
# To execute this script write :
#   EventText2CSV.run
#
# Note : Environment variable TEXT_EVENT_OFFSET change the base ID of csv file (1000 by default)
module EventText2CSV
  module_function

  # Start the convertion
  def run
    @offset = (ENV['TEXT_EVENT_OFFSET'] || 1000).to_i
    print("Enter the langs you want to use [#{GameData::Text::Available_Langs.join(',')}]: ")
    langs = STDIN.gets.chomp.split(',').collect(&:strip)
    @langs = langs.empty? ? GameData::Text::Available_Langs : langs
    Dir['Data/Map*.rxdata'].each do |filename|
      map_id = filename.gsub(%r{^Data/Map}i, '').to_i
      next if map_id == 0

      process_map(filename, @offset + map_id)
    end
  end

  # Process a Map conversion
  # @param filename [String] filename of the map to process
  # @param csv_id [Integer] ID of the CSV file to process
  def process_map(filename, csv_id)
    csv_indexes, csv_header, csv_rows = load_csv(csv_id)
    map = load_data(filename)
    processing_message = nil
    processing_message_command = nil
    map.events.each_value do |event|
      event.pages.each do |page|
        page.list.each do |command|
          processing_message, processing_message_command = process_message(
            command, processing_message, processing_message_command, csv_id, csv_indexes, csv_rows
          )
          process_choice(command, csv_id, csv_indexes, csv_rows) if command.code == 102
        end
      end
    end
    save_csv(csv_id, csv_header, csv_rows)
    save_data(map, filename)
  end

  # Function that process a message
  def process_message(command, processing_message, processing_message_command, csv_id, csv_indexes, csv_rows)
    if command.code != 401 && processing_message_command
      processing_message_command.parameters[0] = "#{csv_id}, #{csv_rows.size} #{processing_message_command.parameters[0]}"
      push_text_to_csv(csv_indexes, csv_rows, processing_message)
      processing_message = processing_message_command = nil
    end
    if command.code == 101
      text = command.parameters[0].dup.force_encoding(Encoding::UTF_8)
      return text, command unless text.match?(/^([0-9]+),( |)([0-9]+)/)
    elsif command.code == 401 && processing_message_command
      processing_message << "\\nl" << command.parameters[0].dup.force_encoding(Encoding::UTF_8)
    end
    return processing_message, processing_message_command
  end

  # Function that process a choice
  def process_choice(command, csv_id, csv_indexes, csv_rows)
    command.parameters[0].map! do |choice|
      text = choice.dup.force_encoding(Encoding::UTF_8)
      next(text) if text.match?(/^([0-9]+),( |)([0-9]+)/)
      push_text_to_csv(csv_indexes, csv_rows, text)
      next("#{csv_id}, #{csv_rows.size - 1} #{text}")
    end
  end

  # Function that push a text to a csv file
  def push_text_to_csv(csv_indexes, csv_rows, text)
    new_row = Array.new((csv_rows.first || csv_indexes).size)
    csv_indexes.each { |i| new_row[i] = text if new_row.size > i }
    csv_rows << new_row
  end

  # Load a CSV file
  # @param csv_id [Integer]
  # @return [Array<Array>]
  def load_csv(csv_id)
    filename = csv_filename(csv_id)
    return [(0...@langs.size).to_a, @langs, []] unless File.exist?(filename)

    rows = CSV.read(filename)
    header = rows.shift
    indexes = (0...rows.size).to_a
    indexes.keep_if { |index| @langs.include?(header[index].to_s.strip) }
    return [indexes, header, rows]
  end

  # Save a CSV file
  # @param csv_id [Integer]
  # @param csv_header [Array<String>]
  # @param csv_rows [Array<Array>]
  def save_csv(csv_id, csv_header, csv_rows)
    csv_rows.insert(0, csv_header)
    filename = csv_filename(csv_id)
    CSV.open(filename, 'w') do |csv|
      csv_rows.each { |row| csv << row }
    end
  end

  # Return the filename of a csv file
  # @param csv_id [Integer]
  # @return [String]
  def csv_filename(csv_id)
    format('Data/Text/Dialogs/%<file_id>d.csv', file_id: csv_id)
  end
end
