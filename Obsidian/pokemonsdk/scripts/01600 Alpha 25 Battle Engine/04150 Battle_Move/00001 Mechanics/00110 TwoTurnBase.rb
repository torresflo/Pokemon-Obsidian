module Battle
  class Move
    class TwoTurnBase < Basic
      include Mechanics::TwoTurn

      private

      # List of move that can hit a Pokemon when he's out of reach
      #   CAN_HIT_BY_TYPE[oor_type] = [move db_symbol list]
      CAN_HIT_BY_TYPE = [
        %i[spikes toxic_spikes stealth_rock], # Phantom Force & Shadow Force
        %i[earthquake fissure magnitude spikes toxic_spikes stealth_rock], # Dig
        %i[gust whirlwind thunder swift sky_uppercut twister smack_down hurricane thousand_arrows spikes toxic_spikes stealth_rock], # Fly & Bounce
        %i[surf whirlpool spikes toxic_spikes stealth_rock], # Dive
        nil # Others moves
      ]

      # Out of reach moves to type
      #   OutOfReach[sb_symbol] => oor_type
      TYPES = { dig: 1, fly: 2, dive: 3, bounce: 2, phantom_force: 0, shadow_force: 0 }

      # Return the list of the moves that can reach the pokemon event in out_of_reach, nil if all attack reach the user
      # @return [Array<Symbol>]
      def can_hit_moves
        CAN_HIT_BY_TYPE[TYPES[db_symbol] || 4]
      end

      # List all the text_id used to announce the waiting turn in TwoTurnBase moves
      ANNOUNCES = {
        dig: 538, fly: 529, dive: 535, bounce: 544,
        phantom_force: 541, shadow_force: 541,
        skull_bash: 556, razor_wind: 547, freeze_shock: 866,
        ice_burn: 869, sky_attack: 550
      }

      # Move db_symbol to a list of stat and power
      # @return [Hash<Symbol, Array<Array[Symbol, Power]>]
      MOVE_TO_STAT = {
        skull_bash: [[:dfe, 1]]
      }

      # Move db_symbol to a list of stat and power change on the user
      # @return [Hash<Symbol, Array<Array[Symbol, Power]>]
      def stat_changes_turn1(user, targets)
        MOVE_TO_STAT[db_symbol]
      end

      # Display the message and the animation of the turn
      # @param user [PFM::PokemonBattler]
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      def proceed_message_turn1(user, targets)
        txt_id = ANNOUNCES[db_symbol]
        @scene.display_message_and_wait(parse_text_with_pokemon(19, txt_id, user)) if txt_id
      end
    end
    Move.register(:s_2turns, TwoTurnBase)
  end
end
