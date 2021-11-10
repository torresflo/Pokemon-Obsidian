module Battle
  class Visual
    # Waiting animation if 0 HP are dealt
    class FakeHPAnimation < Yuki::Animation::TimedAnimation
      # Create the HP Animation
      # @param scene [Battle::Scene] scene responsive of holding all the battle information
      # @param target [PFM::PokemonBattler] Pokemon getting its HP down/up
      # @param effectiveness [Integer, nil] optional param to play the effectiveness sound if that comes from using a move
      def initialize(scene, target, effectiveness = nil)
        @scene = scene
        @target = target
        time = 1
        super(time)
        start
        effectiveness_sound(effectiveness) if effectiveness
      end

      # Update the animation
      def update
        super
        @scene.visual.refresh_info_bar(@target)
      end

      # Detect if the animation if done
      # @return [Boolean]
      def done?
        return false unless super

        @scene.visual.refresh_info_bar(@target)
        return true
      end

      # Play the effectiveness sound
      def effectiveness_sound(effectiveness)
        if effectiveness == 1
          Audio.se_play('Audio/SE/hit')
        elsif effectiveness > 1
          Audio.se_play('Audio/SE/hitplus')
        else
          Audio.se_play('Audio/SE/hitlow')
        end
      end
    end
  end
end
