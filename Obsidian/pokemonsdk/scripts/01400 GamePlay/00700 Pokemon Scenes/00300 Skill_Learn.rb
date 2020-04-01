#encoding: utf-8

#noyard
module GamePlay
  class Skill_Learn < Base
    Skill_Learn1 = "Skill_Learn1"
    Skill_Learn2 = "Skill_Learn2"
    Gender = ["battlebar_a", "battlebar_m", "battlebar_f"]
    include UI
    attr_accessor :learnt
    def initialize(pokemon, skill_id)
      super(false, 20_000)
      @viewport = Viewport.create(:main, 19_000)
      @viewport.visible = false
      @background = Sprite.new(@viewport).set_bitmap(Skill_Learn1, :interface)
      init_info_pokemon
      @skill_list = Array.new(5)
      4.times do |i|
        @skill_list[i] = init_skill(34 + 128 * (i % 2), i > 1 ? 146 : 98)#, 126, 46, 3)
      end
      @skill_list[4] = init_skill(98, 194)#, 126, 46, 3)
      init_skill_descr
      @selector = Sprite.new(@viewport).set_bitmap(Skill_Learn1, :interface)
      @pokemon = pokemon
      @skill_learn = PFM::Skill.new(skill_id)
      @skills = @pokemon.skills_set
      @index = 0
      @phase = 0
      @running = true
      @learnt = false
    end

    def main_begin
      super
      message_start
    end

    def main_end
      super
      if(@__last_scene.class == Party_Menu)
        $scene = @__last_scene.__last_scene
      end
      Graphics.transition if $game_temp.in_battle
    end

    def update
      return unless super
      if (@phase == 0)
        if (Input.trigger?(:UP))
          return if (@index < 2 or @index == 5)
          @index -= 2
          draw_selector
          draw_skill_descr
        elsif (Input.trigger?(:DOWN))
          return if (@index > 3)
          (@index == 2 or @index == 3) ? @index = 4 : @index += 2
          draw_selector
          draw_skill_descr
        elsif (Input.trigger?(:LEFT))
          return if (@index == 0 or @index == 4)
          @index -= 1
          draw_selector
          draw_skill_descr
        elsif (Input.trigger?(:RIGHT))
          return if (@index == 3 or @index == 5)
          @index += 1
          draw_selector
          draw_skill_descr
        elsif (Input.trigger?(:A))
          if (@index < 4)
            @skill_select = @index
            change_phase
          else
            message_end
          end
        elsif (Input.trigger?(:B))
          message_end
        end
      else
        if (Input.trigger?(:LEFT))
          @index = 0 if @index == 1
          draw_selector
        elsif (Input.trigger?(:RIGHT))
          @index = 1 if @index == 0
          draw_selector
        elsif (Input.trigger?(:A))
          @index == 0 ? forget : change_phase
        elsif (Input.trigger?(:B))
          change_phase
        end
      end
    end

    def message_start
      @message_window.visible = true if $game_temp.in_battle
      if (@pokemon.skills_set.size < 4)
        @pokemon.learn_skill(@skill_learn.id)
        display_message(parse_text(22, 106, ::PFM::Text::PKNICK[0] => @pokemon.given_name,
          ::PFM::Text::MOVE[1] => @skill_learn.name))
        @learnt = true
        @running = false
      else
        c = display_message(parse_text(22, 99, ::PFM::Text::PKNICK[0] => @pokemon.given_name,
          ::PFM::Text::MOVE[1] => @skill_learn.name), 1, text_get(23, 85), text_get(23, 86))
        if (c == 0)
          display_message_and_wait(parse_text(22, 100))
          #@message_window.visible = false if $game_temp.in_battle
          if (@viewport.visible == false)
            Graphics.freeze
            draw_selector
            draw_info_pokemon
            draw_skills
            draw_skill_descr
            @viewport.visible = true
            Graphics.transition
          end
        elsif (c == 1)
          message_end
        end
      end
    end

    def message_end
      c = display_message(parse_text(22, 102, ::PFM::Text::PKNICK[0] => @pokemon.given_name,
          ::PFM::Text::MOVE[1] => @skill_learn.name), 1, text_get(23, 85), text_get(23, 86))
      if (c == 0)
        display_message_and_wait(parse_text(22, 103, ::PFM::Text::PKNICK[0] => @pokemon.given_name,
          ::PFM::Text::MOVE[1] => @skill_learn.name))
        @running = false
      elsif (c == 1)
        message_start
      end
    end

    def forget
      old_skill = @skills[@skill_select]
      @pokemon.replace_skill_index(@skill_select, @skill_learn.id)
      display_message_and_wait(parse_text(22, 101, ::PFM::Text::PKNICK[0] => @pokemon.given_name,
        ::PFM::Text::MOVE[1] => old_skill.name, ::PFM::Text::MOVE[2] => @skill_learn.name))
      @learnt = true
      @running = false
    end

    def change_phase
      @index = 0
      if (@phase == 0)
        @background.bitmap = RPG::Cache.interface(Skill_Learn2)
        @selector.bitmap = RPG::Cache.interface(Skill_Learn2)
        5.times do |i|
          @skill_list[i].visible = false
        end
        @skill_descr.set_position(41, 75)
        @phase = 1
      else
        @background.bitmap = RPG::Cache.interface(Skill_Learn1)
        @selector.bitmap = RPG::Cache.interface(Skill_Learn1)
        5.times do |i|
          @skill_list[i].visible = true
        end
        @skill_descr.set_position(82, 12)
        @phase = 0
      end
      draw_selector
      draw_skill_descr
    end

    def draw_selector
      if (@phase == 0)
        if (@index == 5)
          @selector.src_rect.set(329, 200, 38, 37)
        else
          @selector.src_rect.set(323, 98, 126, 46)
        end
        case @index
        when 0, 1, 2, 3
          @selector.x = 34 + 128 * (@index % 2)
          @index > 1 ? @selector.y = 146 : @selector.y = 98
        when 4
          @selector.x = 98
          @selector.y = 194
        when 5
          @selector.x = 250
          @selector.y = 202
        end
      else
        if (@index == 0)
          @selector.src_rect.set(328, 151, 206, 38)
          @selector.x = 34
          @selector.y = 202
        else
          @selector.src_rect.set(329, 200, 38, 37)
          @selector.x = 250
          @selector.y = 202
        end
      end
    end

    def init_info_pokemon
      stack = @info_pokemon = SpriteStack.new(@viewport)
      stack.push(10 + 16, 22 + 16, nil, type: PokemonIconSprite).mirror = true
      stack.push(0, 28, nil, type: GenderSprite)
      stack.add_text(15, 2, 70, 16, :given_name, type: SymText, color: 8)
      stack.push(46, 26, nil, type: Type1Sprite)
      stack.push(46, 44, nil, type: Type2Sprite)
    end

    def draw_info_pokemon
      @info_pokemon.data = @pokemon
    end

    def init_skill(x, y)
      stack = SpriteStack.new(@viewport, x, y)
      stack.push(9, 24, nil, type: TypeSprite)
      stack.add_text(25, 6, 85, 16, :name, 1, type: SymText, color: 8)
      stack.add_text(70, 23, 20, 16, text_get(24, 27), color: 8)
      stack.add_text(81, 23, 40, 16, :pp_text, 1, type: SymText, color: 8)
      stack.visible = false
      return stack
    end

    def draw_skills
      5.times do |i|
        i == 4 ? skill = @skill_learn : skill = @skills[i]
        @skill_list[i].visible = (@skill_list[i].data = skill) != nil
      end
    end

    def init_skill_descr
      stack = @skill_descr_selected = SpriteStack.new(@viewport, 41, 75)
      stack.push(132, 90, nil, type: TypeSprite)
      stack.add_text(10, 89, 85, 16, :name, type: SymText, color: 8)
      stack.add_text(180, 89, 20, 16, text_get(24, 27), color: 8)
      stack.add_text(193, 89, 40, 16, :pp_text, type: SymText, color: 8)
      stack.add_text(76, 139, 60, 16, text_get(24, 36), color: 8)
      stack.visible = false
      stack = @skill_descr = SpriteStack.new(@viewport, 82, 12)
      stack.push(31, 21, nil, type: CategorySprite)
      stack.add_text(68, 44, 20, 16, :power_text, 1,  type: SymText)
      stack.add_text(68, 68, 20, 16, :accuracy_text, 1,  type: SymText)
      stack.add_text(97, 2, 138, 16, :description,  type: SymMultilineText) #140 -> 138
      stack.visible = false
    end

    def draw_skill_descr
      @skill_descr_selected.visible = false if @skill_descr_selected.visible
      @skill_descr.visible = false if @skill_descr.visible
      if (@phase == 0)
        return if @index == 5
        @index == 4 ? skill = @skill_learn : skill = @skills[@index]
      else
        return if @index == 1
        skill = @skills[@skill_select]
        @skill_descr_selected.visible = (@skill_descr_selected.data = skill) != nil
      end
      @skill_descr.visible = (@skill_descr.data = skill) != nil
    end

    def create_graphics
      # Skipped to prevent glitches
    end
  end
end
