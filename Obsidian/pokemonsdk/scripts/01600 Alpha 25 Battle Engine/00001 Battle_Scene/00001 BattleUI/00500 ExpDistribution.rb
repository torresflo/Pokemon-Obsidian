module BattleUI
  # UI element showing the exp distribution
  class ExpDistribution < UI::SpriteStack
    include UI
    include ExpDistributionAbstraction

    # Create a new exp distribution
    # @param viewport [Viewport]
    # @param scene [Battle::Scene]
    # @param exp_data [Hash{ PFM::PokemonBattler => Integer }] info about experience each pokemon should receive
    def initialize(viewport, scene, exp_data)
      super(viewport)
      @scene = scene
      @pokemon = find_expable_pokemon
      @originals = map_to_original_with_forms(@pokemon)
      @exp_data = exp_data.dup
      @done = false
      create_sprites
    end

    def update
      if @statistics
        update_statistics
      else
        @animation.update
      end
      @bars.each(&:update)
    end

    def done?
      return @done
    end

    def start_animation
      animations = @exp_data.map do |pokemon, exp|
        create_exp_animation_for(pokemon, exp)
      end.compact
      return restore_form_to_originals.then { align_exp(@pokemon) } if (@done = animations.empty?)

      # @type [Yuki::Animation::TimedAnimation]
      @animation = Yuki::Animation.se_play('exp_sound')
      animations.each { |(animation, _)| @animation.parallel_add(animation) }
      @animation.play_before(Yuki::Animation.send_command_to(Audio, :se_stop))
      animations.each do |(_, pokemon)|
        @animation.play_before(Yuki::Animation.send_command_to(self, :show_level_up, pokemon)) if pokemon
      end
      @animation.play_before(Yuki::Animation.send_command_to(self, :start_animation))
      @animation.start
      @animation.update
    end

    private

    def update_statistics
      @bars.each(&:update)
      return if $game_temp.message_window_showing
      return unless Input.trigger?(:A) || Mouse.trigger?(:LEFT)

      @statistics.go_out
      @scene.visual.animations << @statistics
      @scene.visual.wait_for_animation
      @bars.each { |bar| bar.leveling_up = false }
      @statistics.dispose
      @statistics = nil
    end

    def create_sprites
      push_sprite(BlurScreenshot.new(@scene))
      # @type [Array<PokemonInfo>]
      @bars = @pokemon.map.with_index do |pokemon, index|
        push_sprite(PokemonInfo.new(@viewport, index, @originals[index], @exp_data[pokemon].to_i))
      end
    end

    # Function that shows level up of a Pokemon
    # @param pokemon [PFM::PokemonBattler]
    def show_level_up(pokemon)
      super(pokemon) do |original, list|
        Audio.me_play('audio/me/rosa_levelup')
        index = @pokemon.index(pokemon)
        @bars[index].leveling_up = true if index
        @statistics = Statistics.new(@viewport, original, list[0], list[1])
        @statistics.go_in
        @scene.visual.animations << @statistics
        @bars[index].data = original if index
      end
      @scene.visual.scene_update_proc { update_statistics } while @statistics
    end

    # Function that create an exp animation for a specific pokemon
    # @param pokemon [PFM::PokemonBattler]
    # @param exp [Integer] total exp he should receive
    # @return [Array(Yuki::Animation::TimedAnimation, PFM::PokemonBattler), nil]
    def create_exp_animation_for(pokemon, exp)
      original = pokemon.original
      return nil if exp <= 0 || original.max_level == original.level

      target_exp = original.exp + exp
      next_exp_value = original.exp_lvl.clamp(0, target_exp)
      @exp_data[pokemon] -= next_exp_value - original.exp

      # actually create the animation
      original_exp = original.exp
      exp_rate = original.exp_rate
      original.exp = next_exp_value
      time_to_process = ((original.exp_rate - exp_rate) * 2).clamp(0, (next_exp_value - original_exp).abs / 60.0)
      animation = Yuki::Animation::DiscreetAnimation.new(time_to_process, original, :exp=, original_exp, next_exp_value)
      return [animation, original.exp == original.exp_lvl ? pokemon : nil]
    end

    # UI element showing the basic information
    class PokemonInfo < UI::SpriteStack
      # The information of the Exp Bar
      EXP_BAR_INFO = [79, 2, 0, 0, 1]
      # Tell if the pokemon is leveling up or not
      # @return [Boolean]
      attr_reader :leveling_up
      # Coordinate where the UI element is supposed to show
      COORDINATES = [[17, 10], [162, 20], [17, 50], [162, 60], [17, 90], [162, 100]]
      # Create a new Pokemon Info
      # @param viewport [Viewport]
      # @param index [Integer]
      # @param pokemon [PFM::Pokemon]
      # @param exp_received [Integer]
      def initialize(viewport, index, pokemon, exp_received)
        super(viewport, *COORDINATES[index])
        @exp_received = exp_received
        @leveling_up = false
        create_sprites
        create_animation
        self.data = pokemon
      end

      # Update the animation
      def update
        @animation.update
        @exp_bar.data = @pokemon
      end

      # Set the data shown by the UI element
      # @param pokemon [PFM::Pokemon]
      def data=(pokemon)
        @pokemon = pokemon
        super(pokemon)
        @gender.x = @x + 42 + @name.real_width
        @level_up_arrow.visible = leveling_up
      end

      # Set if the Pokemon is leveling up or not
      # @param leveling_up [Boolean]
      def leveling_up=(leveling_up)
        @leveling_up = leveling_up
        self.data = @pokemon
      end

      private

      def create_sprites
        @background = add_background('battle/expbar')
        @name = add_text(37, 3, 0, 16, :given_name, color: 10, type: UI::SymText)
        @gender = add_sprite(5, 6, NO_INITIAL_IMAGE, type: UI::GenderSprite)
        with_font(20) do
          @level = add_text(37, 18, 0, 13, :level_text2, color: 10, type: UI::SymText)
          @exp_obtained = add_text(116, 18, 0, 13, "+#{@exp_received}", 2, color: 10) if @exp_received > 0
        end
        create_exp_bar
        @level_up_arrow = add_sprite(124, 7, 'battle/exp_level_up', 3, 1, type: SpriteSheet)
        @pokemon_icon = add_sprite(1, 2, NO_INITIAL_IMAGE, false, type: UI::PokemonIconSprite)
      end

      def create_exp_bar
        @exp_bar = push_sprite UI::Bar.new(@viewport, @x + 37, @y + 29, RPG::Cache.interface('battle/bars_exp_distrib'), *EXP_BAR_INFO)
        @exp_bar.data_source = :exp_rate
      end

      def create_animation
        animation = Yuki::Animation::TimedLoopAnimation.new(1)
        animation.play_before(Yuki::Animation::DiscreetAnimation.new(1, @level_up_arrow, :sx=, 0, 2))
        animation.start
        @animation = animation
      end
    end

    # UI element showing the new statistics
    class Statistics < UI::SpriteStack
      include GoingInOut
      # Get the animation handler
      # @return [Yuki::Animation::Handler{ Symbol => Yuki::Animation::TimedAnimation}]
      attr_reader :animation_handler
      # Position of the sprite when it's in
      IN_POSITION = [0, 144]
      # Create a new Statistics UI
      # @param viewport [Viewport]
      # @param pokemon [PFM::Pokemon] Pokemon that is currently leveling up
      # @param list0 [Array<Integer>] old basis stats
      # @param list1 [Array<Integer>] new basis stats
      def initialize(viewport, pokemon, list0, list1)
        super(viewport, 0, viewport.rect.height)
        @animation_handler = Yuki::Animation::Handler.new
        @list0 = list0
        @list1 = list1
        create_sprites
        @__in_out = :out
        self.data = pokemon
      end

      # Tell if the animation is done
      # @return [Boolean]
      def done?
        @animation_handler.done?
      end

      # Update the animation
      def update
        @animation_handler.update
      end

      private

      def create_sprites
        @background = add_background('battle/exp_stats_bar')
        @name = add_text(160, 9, 0, 16, :given_name, 1, color: 0, type: UI::SymText)
        @gender = add_sprite(220, 11, NO_INITIAL_IMAGE, type: UI::GenderSprite)
        create_stats_texts
      end

      # Create all the stats texts
      def create_stats_texts
        6.times do |i|
          ox = 156 * (i / 3)
          oy = 19 * (i % 3)
          add_text(13 + ox, 31 + oy, 0, 16, text_get(22, 121 + i), color: 10)
          add_text(130 + ox, 31 + oy, 0, 16, @list1[i].to_s, 2, color: 0)
          add_text(139 + ox, 31 + oy, 0, 16, "+#{@list1[i] - @list0[i]}", color: 16)
        end
      end

      # Creates the go_in animation
      # @return [Yuki::Animation::TimedAnimation]
      def go_in_animation
        return Yuki::Animation.move_discreet(0.1, self, x, @viewport.rect.height, *IN_POSITION)
      end

      # Creates the go_out animation
      # @return [Yuki::Animation::TimedAnimation]
      def go_out_animation
        return Yuki::Animation.move_discreet(0.1, self, *IN_POSITION, x, @viewport.rect.height)
      end
    end
  end
end
