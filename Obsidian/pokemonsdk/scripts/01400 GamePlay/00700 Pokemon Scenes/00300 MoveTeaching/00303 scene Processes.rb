module GamePlay
  class MoveTeaching
    # Actions of the scene
    # Array containing the Yes No texts of a choice
    CHOICE_TEXTS = [
      [23, 85], # Yes
      [23, 86] # No
    ]
    # Array containing the texts of the scene
    LEARNING_TEXTS = [
      [22, 99], # Pkmn wants to learn xxx
      [22, 100], # Which move should be forgotten?
      [22, 101], # 1, 2... Tadaa! Pkmn forget how to use xxx!
      [22, 102], # Give up on learning the move xxx?
      [22, 103], # Pkmn did not learn xxx.
      [22, 106], # Pkmn learned xxx!
      [11, 313] # You're good with having it forget xxx?
    ]

    private

    # Message starting with the scene
    # @return [Boolean] false to ensure mouse is skipped
    def message_start
      @state = :asking
      @message_window.visible = true # if $game_temp.in_battle
      # If the skill set of the Pokemon is not full it learns the move
      if @skill_set_not_full
        @pokemon&.learn_skill(@skill_id)
        # Pkmn learned xxx!
        display_learned_move_message
        @learnt = true
        @running = false
        battle_check
      # If the skill set is full, choice to forget or not an existing one
      else
        # Pkmn wants to learn xxx
        c = display_learning_move_question
        if c == 0
          show_ui
          which_move
        elsif c == 1
          message_end
        end
      end
      return false
    end

    # Shows "Pkmn learned xxx!"
    def display_learned_move_message
      display_message(
        parse_text(*LEARNING_TEXTS[5], ::PFM::Text::PKNICK[0] => @pokemon.given_name, ::PFM::Text::MOVE[1] => @skill_learn.name)
      )
    end

    # Shows "Pkmn want to learn xxxx. Do you want to forget a move?"
    # @return [Integer] 0 = yes, 1 = no
    def display_learning_move_question
      return display_message(
        parse_text(*LEARNING_TEXTS[0], ::PFM::Text::PKNICK[0] => @pokemon.given_name, ::PFM::Text::MOVE[1] => @skill_learn.name),
        1, text_get(*CHOICE_TEXTS[0]), text_get(*CHOICE_TEXTS[1])
      )
    end

    # Message ending with the scene
    def message_end
      # Give up on learning the move xxx?
      c = display_give_up_question
      if c == 0
        display_give_up_message
        @running = false
        battle_check
      elsif c == 1
        show_ui
        which_move
      end
    end

    # Shows the give up on this move choice
    # @return [Integer] 0 = yes, 1 = no
    def display_give_up_question
      return display_message(
        parse_text(*LEARNING_TEXTS[3], ::PFM::Text::PKNICK[0] => @pokemon.given_name, ::PFM::Text::MOVE[1] => @skill_learn.name),
        1, text_get(*CHOICE_TEXTS[0]), text_get(*CHOICE_TEXTS[1])
      )
    end

    # Shows the give up message
    def display_give_up_message
      display_message_and_wait(
        parse_text(*LEARNING_TEXTS[4], ::PFM::Text::PKNICK[0] => @pokemon.given_name, ::PFM::Text::MOVE[1] => @skill_learn.name)
      )
    end

    # Replace the skill with the new one
    def forget
      # You're good with having it forget xxx?
      c = display_forget_question
      if c == 0
        display_move_forgotten_new_move_learnt
        @pokemon.replace_skill_index(@index, @skill_learn.id)
        @learnt = true
        @running = false
        battle_check
      elsif c == 1
        @skill_set[@index].forget = false
        which_move
      end
    end

    # Display "You're good with having it forget xxx?"
    # @return [Integer] 0 = yes, 1 = no
    def display_forget_question
      return display_message(
        parse_text(*LEARNING_TEXTS[6], ::PFM::Text::MOVE[0] => @skills[@index].name),
        1, text_get(*CHOICE_TEXTS[0]), text_get(*CHOICE_TEXTS[1])
      )
    end

    # Display the move forgotten message
    def display_move_forgotten_new_move_learnt
      display_message_and_wait(
        parse_text(
          *LEARNING_TEXTS[2],
          ::PFM::Text::PKNICK[0] => @pokemon.given_name,
          ::PFM::Text::MOVE[1] => @skills[@index].name,
          ::PFM::Text::MOVE[2] => @skill_learn.name
        )
      )
    end

    # Method displaying the Which move should be forgotten? message
    def which_move
      @state = :move_choice
      return display_message_and_wait(parse_text(*LEARNING_TEXTS[1]))
    end

    # If the scene is called during a battle
    def battle_check
      Graphics.transition if $game_temp.in_battle
    end

    # Displays the UI
    def show_ui
      @skill_set[4].data = @skill_learn
      @pokemon.skills_set.each_with_index do |skill, index|
        @skill_set[index].data = skill
      end
      @pokemon_infos.data = @pokemon
      self.ui_visibility = true
      swap_buttons(@index)
    end
  end
end
