module GamePlay
  class Load
    private

    # Function responsive of loading all the existing saves
    # @return [Array<PFM::Pokemon_Party>]
    def load_all_saves
      save_index = Save.save_index
      pokemon_party = $pokemon_party
      # Get the base filename
      Save.save_index = 0
      base_filename = Save.save_filename
      # No multi save => get only the current save
      return [Save.load(base_filename)] if Configs.save_config.single_save?

      all_saves = Dir["#{base_filename}*"].reject { |i| i.end_with?('.bak') }.map { |i| i.sub(base_filename, '').gsub(/[^0-9]/, '').to_i }
      all_saves.reject! { |i| i > Configs.save_config.maximum_save_count } unless Configs.save_config.unlimited_saves?
      last_save = all_saves.max || 0
      return last_save.times.map do |i|
        Save.save_index = i + 1
        next Save.load(no_load_parameter: true)
      end
    ensure
      Save.save_index = save_index
      $pokemon_party = pokemon_party
    end
  end
end
