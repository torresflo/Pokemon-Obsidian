class Scene_Title
  private

  # Function that creates the PSDK splash
  def psdk_splash_initialize
    @background = Sprite.new(@viewport)
    @background.opacity = 0
    @background.load('splash', :title)
    @current_state = :title_animation
    create_splash_animation('nintendo')
  end

  # Function that initialize the next splash
  def next_splash_initialize
    @background.bitmap.dispose unless @background.bitmap.disposed?
    splashes = Configs.scene_title_config.additional_splashes
    if splashes.size > @splash_counter
      @background.load(splashes[@splash_counter], :title)
      @splash_counter += 1
      create_splash_animation
    else
      @current_state = :title_animation # Just to be sure
      create_title_animation
    end
  end

  # Function that create a splash animation
  # @param se_filename [String] filename of the SE to play
  def create_splash_animation(se_filename = nil)
    if se_filename
      @splash_animation = Yuki::Animation.se_play(se_filename)
      @splash_animation.play_before(Yuki::Animation.opacity_change(0.4, @background, 0, 255))
    else
      @splash_animation = Yuki::Animation.opacity_change(0.4, @background, 0, 255)
    end
    @splash_animation.play_before(Yuki::Animation.wait(1.0))
    @splash_animation.play_before(Yuki::Animation.opacity_change(0.4, @background, 255, 0))
    @splash_animation.play_before(Yuki::Animation.send_command_to(self, :next_splash_initialize))
    @splash_animation.start
  end
end
