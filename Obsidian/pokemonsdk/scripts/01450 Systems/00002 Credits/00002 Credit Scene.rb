module GamePlay
  # Scene responsive of showing credits
  class CreditScene < BaseCleanUpdate
    def initialize
      super(true)
      @config = Configs.credits_config
    end

    def update_inputs
      return false unless @animation && !@animation.done?

      @running = false if Input.trigger?(:A)
    end

    def update_mouse(*)
      @running = false if Mouse.trigger?(:LEFT)
    end

    def update_graphics
      return @animation.update if @animation && !@animation.done?

      @animation &&= nil
      @scroller.update
      @running = false if @scroller.done?
    end

    def main_end
      super
      $scene = Scheduler.get_boot_scene
    end

    private

    def create_graphics
      super
      @vp_width2 = @viewport.rect.width / 2
      @vp_height2 = @viewport.rect.height / 2
      create_splash
      create_director
      create_leaders
      create_scroller
      create_animation
    end

    def create_splash
      @splash = Sprite.new(@viewport)
      @splash.load(@config.project_splash, :title)
      @splash.set_position(@vp_width2, @vp_height2)
      @splash.set_origin(@splash.width / 2, @splash.height / 2)
      @splash.zoom = 3
      @splash.opacity = 0
    end

    def create_director
      @director = UI::SpriteStack.new(@viewport)
      @director.with_font(title_font_id) do
        @director.add_text(@vp_width2, @vp_height2 - @config.line_height, 0, @config.line_height, @config.chief_project_title, 1, 1,
                           color: title_color)
      end
      @director.add_text(@vp_width2, @vp_height2, 0, @config.line_height, @config.chief_project_name, 1, color: name_color)
      @director.visible = false
    end

    def create_leaders
      y1 = @vp_height2 - @config.leader_spacing - @config.line_height
      y2 = @vp_height2 - @config.leader_spacing
      y3 = @vp_height2 + @config.leader_spacing - @config.line_height
      y4 = @vp_height2 + @config.leader_spacing
      # @type [Array<UI::SpriteStack>]
      @leaders = @config.leaders.each_slice(2).map do |(lead1, lead2)|
        stack = UI::SpriteStack.new(@viewport)
        stack.with_font(title_font_id) { stack.add_text(@vp_width2, y1, 0, @config.line_height, lead1[:title].to_s, 1, 1, color: title_color) }
        stack.add_text(@vp_width2, y2, 0, @config.line_height, lead1[:name].to_s, 1, color: name_color)
        next stack unless lead2

        stack.with_font(title_font_id) do
          stack.add_text(@vp_width2, y3, 0, @config.line_height, lead2[:title].to_s, 1, 1, color: title_color)
        end
        stack.add_text(@vp_width2, y4, 0, @config.line_height, lead2[:name].to_s, 1, color: name_color)
        next stack
      end
      @leaders.each { |stack| stack.visible = false }
    end

    def create_scroller
      @scroller = UI::TextScroller.new(@viewport, @config.game_credits.each_line.to_a.compact, @config.line_height, @config.speed)
    end

    def create_animation
      ya = Yuki::Animation
      anim = ya.wait(0.25)
      anim.play_before(ya.send_command_to(Audio, :bgm_stop))
      anim.play_before(ya.bgm_play(*@config.bgm))
      anim.play_before(create_splash_animation)
      anim.play_before(create_director_animation)
      anim.play_before(create_leaders_animation)
      anim.play_before(ya.send_command_to(@scroller, :start))
      @animation = anim
      @animation.start
    end

    # Create the splash animation
    # @return [Yuki::Animation::TimedAnimation]
    def create_splash_animation
      ya = Yuki::Animation
      anim = ya.opacity_change(0.25, @splash, 0, 255)
      anim.parallel_play(Yuki::Animation::ScalarAnimation.new(0.25, @splash, :zoom=, 3, 1))
      anim.play_before(ya.wait(1.5))
      anim2 = ya.opacity_change(0.25, @splash, 255, 0)
      anim2.parallel_play(Yuki::Animation::ScalarAnimation.new(0.25, @splash, :zoom=, 1, 3))
      anim.play_before(anim2)
      return anim
    end

    # Create the director animation
    # @param stack [UI::SpriteStack]
    # @return [Yuki::Animation::TimedAnimation]
    def create_director_animation(stack = @director)
      ya = Yuki::Animation
      anim = ya.wait(0.1)
      anim.play_before(ya.send_command_to(stack, :visible=, true))
      anim.play_before(ya.wait(2))
      anim.play_before(ya.send_command_to(stack, :visible=, false))
      anim.play_before(ya.wait(0.15))
      return anim
    end

    # Create the leaders animation
    # @return [Yuki::Animation::TimedAnimation]
    def create_leaders_animation
      anims = @leaders.map { |stack| create_director_animation(stack) }
      first_anim = anims.shift
      return ya.wait(0.1) unless first_anim

      anims.each { |anim| first_anim.play_before(anim) }
      return first_anim
    end

    def title_color
      11
    end

    def title_font_id
      20
    end

    def name_color
      10
    end
  end
end
