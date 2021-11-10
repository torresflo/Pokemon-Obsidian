module Battle
  class Logic
    # Handler responsive of answering properly Pokemon catching requests
    class CatchHandler < ChangeHandlerBase
      include Hooks
      # Modifier applied to the formula depending of the Status
      # @return [Hash{ Integer => Integer }]
      STATUS_MODIFIER = safe_const(:STATUS_MODIFIER) do
        {
          GameData::States::POISONED => 1.5,
          GameData::States::PARALYZED => 1.5,
          GameData::States::BURN => 1.5,
          GameData::States::ASLEEP => 2.5,
          GameData::States::FROZEN => 2.5,
          GameData::States::TOXIC => 1.5
        }
      end
      BALL_RATE_CALCULATION = {}

      # ID of the catching text in the text database
      # @return [Array<Array<Integer>>]
      TEXT_CATCH = [[18, 63], [18, 64], [18, 65], [18, 66], [18, 67], [18, 68]]
      # DB_Symbol of each Ultra-Beast
      # @return [Array<Symbol>]
      ULTRA_BEAST = %i[nihilego buzzwole pheromosa xurkitree celesteela kartana guzzlord poipole naganadel stakataka blacephalon]
      # Function that try to catch the targeted Pokemon
      # @param target [PFM::PokemonBattler]
      # @param pkm_ally [PFM::PokemonBattler]
      # @param ball [GameData::BallItem] db_symbol of the used ball
      def try_to_catch_pokemon(target, pkm_ally, ball)
        log_data("# FR: try_to_catch_pokemon(#{target}, #{pkm_ally}, #{ball})")
        @bounces = -1
        @scene.message_window.blocking = true
        @scene.message_window.wait_input = true
        exec_hooks(Battle::Logic::CatchHandler, :ball_blocked, binding)
        catching_procedure(target, pkm_ally, ball)
        show_message_and_animation(target, ball, @bounces, caught?)
        return caught?
      rescue Hooks::ForceReturn => e
        log_data("# FR: try_to_catch_pokemon #{e.data} from #{e.hook_name} (#{e.reason})")
        return e.data
      end

      # Tells if the Pokemon is caught
      # @return [Boolean]
      def caught?
        return @bounces == 3 || @critical_capture
      end

      class << self
        # Define a new ball rate calculation in BALL_RATE_CALCULATION
        # @param ball_name [Symbol] the DB_symbol of the ball
        # @yieldparam target [PFM::PokemonBattler]
        # @yieldparam pkm_ally [PFM::PokemonBattler]
        # @yieldreturn [Integer] the new catch_rate
        def add_ball_rate_calculation(ball_name, &block)
          BALL_RATE_CALCULATION[ball_name] = block if block
        end
      end

      add_ball_rate_calculation(:dive_ball) do |target, _pkm_ally|
        next (target.rareness * 3.5) if $scene.battle_info.fishing
        next (target.rareness * 3.5) if $game_player.surfing?

        next target.rareness
      end

      add_ball_rate_calculation(:dusk_ball) do |target, _pkm_ally|
        next (target.rareness * 3.5) if $env.cave?
        next (target.rareness * 3.5) if $env.night?

        next target.rareness
      end

      add_ball_rate_calculation(:fast_ball) do |target, _pkm_ally|
        next target.rareness * (target.base_spd >= 100 ? 4 : 1)
      end

      add_ball_rate_calculation(:heavy_ball) do |target, _pkm_ally|
        modifier = target.rareness
        weight = GameData::Pokemon[target.id].weight
        if weight.between?(0, 204.7)
          modifier -= 20
        elsif weight.between?(204.8, 307.1)
          modifier += 20
        elsif weight.between?(307.2, 409.5)
          modifier += 30
        elsif weight >= 409.6
          modifier += 40
        end
        next modifier.clamp(1, 255)
      end

      add_ball_rate_calculation(:level_ball) do |target, pkm_ally|
        e_level = target.level
        p_level = pkm_ally.level
        if (e_level * 4) <= p_level
          next target.rareness * 8
        elsif (e_level * 2) <= p_level
          next target.rareness * 4
        elsif e_level < p_level
          next target.rareness * 2
        end

        next target.rareness
      end

      add_ball_rate_calculation(:love_ball) do |target, pkm_ally|
        if target.id == pkm_ally.id
          next target.rareness * 8 if (target.gender != pkm_ally.gender) && [target.gender, pkm_ally.gender].none? { |pkm| pkm.gender == 0 }
        end
        next target.rareness
      end

      add_ball_rate_calculation(:lure_ball) do |target, _pkm_ally|
        next target.rareness * ($scene.battle_info.fishing ? 3 : 1)
      end

      add_ball_rate_calculation(:moon_ball) do |target, _pkm_ally|
        data = GameData::Pokemon[target.id].special_evolution
        next target.rareness * (data[:stone] == 81 ? 4 : 1)
      end

      add_ball_rate_calculation(:nest_ball) do |target, _pkm_ally|
        if target.level >= 30
          next target.rareness
        elsif target.level >= 20
          next target.rareness * 2
        else
          next target.rareness * 3
        end
      end

      add_ball_rate_calculation(:net_ball) do |target, _pkm_ally|
        check = [target.type1, target.type2, target.type3].any? { |type| [3, 12].include? type }
        next target.rareness * (check ? 3 : 1)
      end

      add_ball_rate_calculation(:quick_ball) do |target, _pkm_ally|
        next target.rareness * ($game_temp.battle_turn == 0 ? 4 : 1)
      end

      add_ball_rate_calculation(:repeat_ball) do |target, _pkm_ally|
        next target.rareness * ($pokedex.has_captured?(target.id) ? 3 : 1)
      end

      add_ball_rate_calculation(:timer_ball) do |target, _pkm_ally|
        if $game_temp.battle_turn > 30
          next target.rareness * 4
        elsif $game_temp.battle_turn >= 21
          next target.rareness * 3
        elsif $game_temp.battle_turn >= 11
          next target.rareness * 2
        else
          next target.rareness
        end
      end

      private

      # Function that calculate the modified rate for the capture
      # @param target [PFM::PokemonBattler]
      # @param pkm_ally [PFM::PokemonBattler]
      # @param ball [GameData::BallItem] db_symbol of the used ball
      def catching_procedure(target, pkm_ally, ball)
        a = final_rate(target, pkm_ally, ball)
        return if check_critical_capture(a)

        if a >= 255
          @bounces = 3
        else
          4.times do |i|
            log_debug("bounce no.#{i}")
            break unless check_bounce(a)
          end
        end
      end

      # Get the right catch rate of the target depending on the ball used
      # @param target [PFM::PokemonBattler]
      # @param pkm_ally [PFM::PokemonBattler]
      # @param ball [GameData::BallItem] db_symbol of the used ball
      def catch_rate(target, pkm_ally, ball)
        return (target.rareness * 0.1) if ULTRA_BEAST.include?(target.db_symbol) && ball != :beast_ball
        return (target.rareness * 5) if ULTRA_BEAST.include?(target.db_symbol) && ball == :beast_ball
        return BALL_RATE_CALCULATION[ball.db_symbol].call(target, pkm_ally) if BALL_RATE_CALCULATION.keys.include?(ball.db_symbol)

        return target.rareness
      end

      # Calculate the final_rate 'a'() (6G formula from here : https://bulbapedia.bulbagarden.net/wiki/Catch_rate#Capture_method_.28Generation_VI.29)
      # @param target [PFM::PokemonBattler]
      # @param pkm_ally [PFM::PokemonBattler]
      # @param ball [GameData::BallItem] db_symbol of the used ball
      def final_rate(target, pkm_ally, ball)
        rate = catch_rate(target, pkm_ally, ball)
        log_debug("Catch rate = #{rate}")
        bonus_ball = ball.catch_rate
        log_debug("Bonus ball = #{bonus_ball}")
        bonus_status = STATUS_MODIFIER[target.status] || 1
        log_debug("Status modifier = #{bonus_status}")
        a = (((3 * target.max_hp) - (2 * target.hp)) * rate * bonus_ball / (3 * target.max_hp).to_f * bonus_status).floor
        log_debug("Final rate = #{a}")
        exec_hooks(Battle::Logic::CatchHandler, :special_rate_modifier, binding)
        return a
      end

      # Check if a Critical capture ensue
      # @return [Boolean]
      def check_critical_capture(a)
        count = $pokedex.pokemon_captured
        if count > 600
          a *= 2.5
        elsif count >= 451
          a *= 2
        elsif count >= 301
          a *= 1.5
        elsif count >= 151
          a *= 1
        elsif count >= 31
          a *= 0.5
        else
          a *= 0
        end
        c = a / 6
        log_debug("c = #{c}")
        if logic.generic_rng.rand(0..255) < c
          @critical_capture = true
          @bounces = 1
        end
      end

      def check_bounce(a)
        b = (65_536 / ((255 / a.to_f)**0.1875)).floor
        check = logic.generic_rng.rand(0..65_535)
        if check < b
          log_debug("Success as #{check} is inferior to #{b}")
          @bounces += 1
          log_debug("@bounces = #{@bounces}")
          return true
        end
        log_debug("Failure as #{check} is superior to #{b}")
        return false
      end

      def show_message_and_animation(target, ball, nb_bounce, caught)
        @scene.visual.show_catch_animation(target, ball, nb_bounce, caught)
        @scene.display_message_and_wait(parse_text(*TEXT_CATCH[(nb_bounce + 1) % 4], PFM::Text::PKNAME[0] => target.name)) unless caught
        return caught
      end

      Hooks.register(Battle::Logic::CatchHandler, :ball_blocked, 'Check if the initial rareness of the Pokemon is 0') do |hook_binding|
        if hook_binding[:target].rareness == 0
          # @scene.visual.ball_deflect_animation(target, ball)
          @scene.display_message_and_wait(parse_text(18, 69)) #TODO Write the text for a Pokémon with rareness 0
          force_return(false)
        end
      end

      Hooks.register(Battle::Logic::CatchHandler, :ball_blocked, 'Check if catching is forbidden in this battle') do |_hook_binding|
        if $game_switches[Yuki::Sw::BT_NoCatch]
          # @scene.visual.ball_deflect_animation(target, ball)
          @scene.display_message_and_wait(parse_text(18, 69)) #TODO Write the text for forbidding catching in this battle
          force_return(false)
        end
      end

      Hooks.register(Battle::Logic::CatchHandler, :ball_blocked, 'Check if the battle is a Trainer battle') do |hook_binding|
        if logic.battle_info.trainer_battle? && hook_binding[:ball].db_symbol != :rocket_ball
          # @scene.visual.ball_deflect_animation(target, ball)
          @scene.display_message_and_wait(parse_text(18, 69)) #TODO Write the text for a Pokémon owned by a Trainer that can't be caught
          force_return(false)
        end
      end
    end
  end
end
