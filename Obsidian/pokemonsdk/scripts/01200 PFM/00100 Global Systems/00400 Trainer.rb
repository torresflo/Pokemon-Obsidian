module PFM
  # The actor trainer data informations
  #
  # Main object stored in $trainer and $pokemon_party.trainer
  # @author Nuri Yuri
  class Trainer
    # Time format
    TIME_FORMAT = '%02d:%02d'
    # Name of the trainer as a boy (Default to Palbolsky)
    # @return [String]
    attr_accessor :name_boy
    # Name of the trainer as a girl (Default to Yuri)
    # @return [String]
    attr_accessor :name_girl
    # If the player is playing the girl trainer
    # @return [Boolean]
    attr_accessor :playing_girl
    # The internal ID of the trainer as a boy
    # @return [Integer]
    attr_accessor :id_boy
    # The internal ID of the trainer as a girl. It's equal to id_boy ^ 0x28F4AB4C
    # @return [Integer]
    attr_accessor :id_girl
    # The time in second when the Trainer object has been created (computer time)
    # @return [Integer]
    attr_accessor :start_time
    # The time the player has played as this Trainer object
    # @return [Integer]
    attr_accessor :play_time
    # The badges this trainer object has collected
    # @return [Array<Boolean>]
    attr_accessor :badges
    # The ID of the current region in which the trainer is
    # @return [Integer]
    attr_accessor :region
    # The game version in which this object has been saved or created
    # @return [Integer]
    attr_accessor :game_version
    # The current version de PSDK (update management). It's saved like game_version
    # @return [Integer]
    attr_accessor :current_version
    # Create a new Trainer
    def initialize
      @name_boy = default_male_name
      @name_girl = default_female_name
      $game_switches[Yuki::Sw::Gender] = @playing_girl = false
      $game_variables[Yuki::Var::Player_ID] = @id_boy = rand(0x3FFFFFFF)
      @id_girl = (@id_boy ^ 0x28F4AB4C)
      @start_time = Time.new.to_i
      @play_time = 0
      @badges = Array.new(6 * 8, false)
      @region = 0
      @game_version = PSDK_CONFIG.game_version
      @current_version = PSDK_Version rescue 0
      @time_counter = 0
      load_time
    end

    # Return the name of the trainer
    # @return [String]
    def name
      return @playing_girl ? @name_girl : @name_boy
    end

    # Change the name of the trainer
    # @param value [String] the new value of the trainer name
    def name=(value)
      if @playing_girl
        @name_girl = value
      else
        @name_boy = value
      end
      $game_actors[1].name = value
    end

    # Return the id of the trainer
    # @return [Integer]
    def id
      return @playing_girl ? @id_girl : @id_boy
    end

    # Redefine some variable RMXP uses with the right values
    def redefine_var
      $game_variables[Yuki::Var::Player_ID] = id
      $game_actors[1].name = name
      # redefinir les badges
    end

    # Load the time counter with the current time
    def load_time
      @time_counter = Time.new.to_i
    end

    # Return the time counter (current time - time counter)
    # @return [Integer]
    def time_counter
      counter = Time.new.to_i - @time_counter
      return counter < 0 ? 0 : counter
    end

    # Update the play time and reload the time counter
    # @return [Integer] the play time
    def update_play_time
      @play_time += time_counter
      load_time
      return @play_time
    end

    # Return the number of badges the trainer got
    # @return [Integer]
    def badge_counter
      @badges.count { |badge| badge == true }
    end

    # Set the got state of a badge
    # @param badge_num [1, 2, 3, 4, 5, 6, 7, 8] the badge
    # @param region [Integer] the region id (starting by 1)
    # @param value [Boolean] the got state of the badge
    def set_badge(badge_num, region = 1, value = true)
      region -= 1
      badge_num -= 1
      if (region * 8) >= @badges.size
        log_error('Le jeu ne prévoit pas de badge pour cette région. PSDK_ERR n°000_006')
      elsif badge_num < 0 || badge_num > 7
        log_error('Le numéro de badge indiqué est invalide, il doit être entre 1 et 8. PSDK_ERR n°000_007')
      else
        @badges[(region * 8) + badge_num] = value
      end
    end

    # Has the player got the badge ?
    # @param badge_num [1, 2, 3, 4, 5, 6, 7, 8] the badge
    # @param region [Integer] the region id (starting by 1)
    # @return [Boolean]
    def badge_obtained?(badge_num, region = 1)
      region -= 1
      badge_num -= 1
      if (region * 8) >= @badges.size
        log_error('Le jeu ne prévoit pas de badge pour cette région. PSDK_ERR n°000_006')
      elsif badge_num < 0 || badge_num > 7
        log_error('Le numéro de badge indiqué est invalide, il doit être entre 1 et 8. PSDK_ERR n°000_007')
      else
        return @badges[(region * 8) + badge_num]
      end
      return false
    end
    alias has_badge? badge_obtained?

    # Set the gender of the trainer
    # @param playing_girl [Boolean] if the trainer will be a girl
    def define_gender(playing_girl)
      @playing_girl = playing_girl
      $game_switches[Yuki::Sw::Gender] = playing_girl
      $game_variables[Yuki::Var::Player_ID] = id
      $game_actors[1].name = name
    end
    alias set_gender define_gender

    # Return the play time text (without updating it)
    # @return [String]
    def play_time_text
      time = @play_time
      hours = time / 3600
      minutes = (time - 3600 * hours) / 60
      return format(TIME_FORMAT, hours, minutes)
    end

    private

    # Return the default male name
    # @return [String]
    def default_male_name
      ext_text(9000, 2)
    end

    # Return the default female name
    # @return [String]
    def default_female_name
      ext_text(9000, 3)
    end
  end

  class Pokemon_Party
    # The informations about the player and the game
    # @return [PFM::Trainer]
    attr_accessor :trainer
    on_player_initialize(:trainer) { @trainer = PFM::Trainer.new }
    on_expand_global_variables(:trainer) do
      # Variable containing the Trainer (card) information
      $trainer = @trainer
    end
  end
end
