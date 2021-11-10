module Battle
  class Move
    # Metronome move
    class Metronome < Move
      CANNOT_BE_SELECTED_MOVES = %i[
        after_you assist baneful_bunker beak_blast belch bestow celebrate chatter copycat counter covet crafty_shield destiny_bound detect
        diamond_storm endure feint fleur_cannon focus_punch follow_me freeze_shock helping_hand hold_hands hyperspace_fury hyperspace_hole ice_burn
        instruct king_s_shield light_of_ruin mat_block me_first metronome mimic mind_blown mirror_coat mirror_move nature_power photon_geyser
        plasma_fists protect quash quick_guard rage_powder relic_song secret_sword shell_trap sketch sleep_talk snarl snatch snore spectral_thief
        spiky_shield spotlight steam_eruption struggle switcheroo techno_blast thousand_arrows thousand_waves thief transform trick v_create
        wide_guard
      ]

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        skill = GameData::Skill.all.reject { |i| CANNOT_BE_SELECTED_MOVES.include?(i.db_symbol) }.sample(random: @logic.generic_rng)
        move = Battle::Move[skill.be_method].new(skill.id, 1, 1, @scene)
        def move.usage_message(user)
          @scene.visual.hide_team_info
          scene.display_message_and_wait(parse_text(18, 126, '[VAR MOVE(0000)]' => name))
          PFM::Text.reset_variables
        end

        def move.move_usable_by_user(user, targets)
          return true
        end
        use_another_move(move, user)
      end
    end
    Move.register(:s_metronome, Metronome)
  end
end
