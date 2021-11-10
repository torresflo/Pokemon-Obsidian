module Battle
  class Visual
    # Animation of HP getting down/up
    class HPAnimation < Yuki::Animation::DiscreetAnimation
      # Create the HP Animation
      # @param scene [Battle::Scene] scene responsive of holding all the battle information
      # @param target [PFM::PokemonBattler] Pokemon getting its HP down/up
      # @param quantity [Integer] quantity of HP the Pokemon is getting
      # @param effectiveness [Integer, nil] optional param to play the effectiveness sound if that comes from using a move
      def initialize(scene, target, quantity, effectiveness = nil)
        @scene = scene
        @target = target
        @target_hp = (target.hp + (quantity == 0 ? -1 : quantity)).clamp(0, target.max_hp)
        time = (quantity.clamp(-target.hp, target.max_hp).abs.to_f / 60).clamp(0.2, 1) # TODO: Add config & option for all those values
        super(time, target, :hp=, target.hp, @target_hp)
        create_sub_animation
        start
        effectiveness_sound(effectiveness) if quantity != 0 && effectiveness
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

        final_hp_refresh
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

      private

      # Function that refreshes the bar to the final value
      def final_hp_refresh
        @target.hp = @target_hp while @target_hp != @target.hp
        @scene.visual.refresh_info_bar(@target)
      end

      # Function that creates the sub animation
      def create_sub_animation
        play_before(Yuki::Animation.send_command_to(self, :final_hp_refresh))
        if @target_hp > 0
          play_before(Yuki::Animation.wait((1 - @time_to_process).clamp(0.25, 1)))
        else
          play_before(Yuki::Animation.wait(0.1))
        end
      end
    end
  end
end
