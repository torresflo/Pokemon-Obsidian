module UI
  # UI component showing the controls of the title screen (Play / Credits)
  class TitleControls < SpriteStack
    # Get the index of the selection
    # @return [Integer]
    attr_reader :index
    # Get the play bg button
    # @return [Sprite]
    attr_reader :play_bg
    # Get the credit bg button
    # @return [Sprite]
    attr_reader :credit_bg

    def initialize(viewport)
      super(viewport, 0, 240, default_cache: :title)
      create_sprites
      self.index = 0
      @wait_duration = Configs.scene_title_config.control_wait || 0.5
      create_animation
    end

    # Set the index of the selection
    # @param index [Integer]
    def index=(index)
      @index = index
      @play_bg.visible = index == 0
      @credit_bg.visible = index == 1
    end

    # Update the animation
    def update
      super
      @animation.update
    end

    # Tell if the controls are done transitionning
    # @return [Boolean]
    def done?
      @animation.done?
    end

    private

    # Create all the necessary sprites for the title controls
    def create_sprites
      create_button_shader
      create_play_bg
      create_credits_bg
      create_play_text
      create_credit_text
    end

    # Function that creates the button shader
    def create_button_shader
      @shader = Shader.create(:title_button)
      @shader_time_update = proc { |t| @shader.set_float_uniform('t', t) }
    end

    def create_play_bg
      @play_bg = add_sprite(160, 168, 'shader_bg')
      @play_bg.ox = @play_bg.width / 2
      @play_bg.shader = @shader
    end

    def create_credits_bg
      @credit_bg = add_sprite(160, 192, 'shader_bg')
      @credit_bg.ox = @credit_bg.width / 2
      @credit_bg.shader = @shader
    end

    def create_play_text
      @font_id = 20
      add_text(160, 170, 0, 24, text_get(32, 77).capitalize, 1, 1, color: 9)
    end

    def create_credit_text
      @font_id = 20
      add_text(160, 194, 0, 24, 'Credits', 1, 1, color: 9)
    end

    # Create the animation
    def create_animation
      @animation = Yuki::Animation.wait(@wait_duration)
      @animation.play_before(Yuki::Animation.move_discreet(0.5, self, 0, 240, 0, 0))
      @animation.play_before(Yuki::Animation.send_command_to(self, :create_loop_animation))
      @animation.start
    end

    # Create the loop animation
    def create_loop_animation
      @animation = Yuki::Animation::TimedLoopAnimation.new(2)
      wait = Yuki::Animation.wait(2)
      shader_animation = Yuki::Animation::ScalarAnimation.new(2, @shader_time_update, :call, 0, 1)
      wait.parallel_add(shader_animation)
      @animation.play_before(wait)
      @animation.start
    end
  end
end

Graphics.on_start do
  Shader.register(:title_button, 'graphics/shaders/title_button.frag')
end
