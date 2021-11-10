module Battle
  module Effects
    class Item
      class Drives < Item
        # Function called when we try to get the definitive type of a move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler] expected target
        # @param move [Battle::Move]
        # @param type [Integer] current type of the move (potentially after effects)
        # @return [Integer, nil] new type of the move
        def on_move_type_change(user, target, move, type)
          return if user != @target
          return unless user.db_symbol == :genesect && move.be_method == :s_techno_blast

          return new_move_type
        end

        private

        # Give the new move type if the drive works
        # @return [Integer]
        def new_move_type
          return GameData::Types::WATER
        end
      end

      class ShockDrive < Drives
        private

        # Give the new move type if the drive works
        # @return [Integer]
        def new_move_type
          return GameData::Types::ELECTRIC
        end
      end

      class BurnDrive < Drives
        private

        # Give the new move type if the drive works
        # @return [Integer]
        def new_move_type
          return GameData::Types::FIRE
        end
      end

      class ChillDrive < Drives
        private

        # Give the new move type if the drive works
        # @return [Integer]
        def new_move_type
          return GameData::Types::ICE
        end
      end

      register(:douse_drive, Drives)
      register(:shock_drive, ShockDrive)
      register(:burn_drive, BurnDrive)
      register(:chill_drive, ChillDrive)
    end
  end
end
