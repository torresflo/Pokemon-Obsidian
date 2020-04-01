class Interpreter
  # Call the move reminder UI with the choosen Pokemon and a specific mode (0 by default)
  # @param pokemon [PFM::Pokemon]
  # @param mode [Integer] see {GamePlay::Move_Reminder#initialize}
  # @return [Boolean] if the Pokemon learnt a move or not
  def move_reminder(pokemon = $actors[$game_variables[::Yuki::Var::Party_Menu_Sel]], mode = 0)
    Graphics.freeze
    scene = GamePlay::Move_Reminder.new(pokemon, mode)
    scene.main
    Graphics.transition
    @wait_count = 2
    return scene.return_data
  end
  alias maitre_capacites move_reminder

  # Detect if the move reminder can remind a move to the selected pokemon
  # @param mode [Integer] see {GamePlay::Move_Reminder#initialize}
  # @return [Boolean] if the scene can be called
  def can_move_reminder_be_called?(mode = 0)
    var = $game_variables[::Yuki::Var::Party_Menu_Sel]
    return false if var < 0 || var >= $actors.size
    return $actors[var].remindable_skills(mode).any?
  end
  alias maitre_capacites_appelable? can_move_reminder_be_called?
end
