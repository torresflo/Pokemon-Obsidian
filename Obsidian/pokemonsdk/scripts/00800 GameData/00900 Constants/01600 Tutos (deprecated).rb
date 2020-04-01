module GameData
  # Variable that contain a list of tutorial actions for battle
  # @deprecated will change in the future, its an old example
  Tutos = [
    [[:@action_selector, false]],
    [[:msg], [:@action_selector, true], [:@Actions_Counter, -30], :RIGHT, :DOWN, :LEFT, :UP, :A,
     [:@skill_selector, false], [:@atk_index, 0]],
    [[:msg], [:@action_selector, true], [:@Actions_Counter, -30], :A, [:@atk_index, 0]],
    [[:msg], [:@skill_selector, true], [:@Actions_Counter, -30], [:select_atk_caract, 3]],
    [[:msg], [:@Actions_Counter, -30], [:select_atk_caract, 1]],
    [[:msg]],
    [[:msg, 'Que doit faire \\v[298] ?'], [:@action_selector, true]]
  ]
end
