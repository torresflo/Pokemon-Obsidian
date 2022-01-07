module GamePlay
  # Scene responsive of teaching a move to a Pokemon
  #
  # How to call it ?
  #   This scene has a return parameter called `learnt` telling wether the move has been learnt or not.
  #   You might use call_scene like this for this Scene:
  #     call_scene(GamePlay::MoveTeaching, pokemon, move_id) { |scene| do something with scene.learnt }
  class MoveTeaching < BaseCleanUpdate::FrameBalanced
    include UI::MoveTeaching
    include MoveTeachingMixin
    # Create a new Skill Learn scene
    # param pokemon [PFM::Pokemon]
    # param skill [Integer] or [Symbol]
    def initialize(pokemon, skill_id)
      super()
      @pokemon = pokemon
      @skill_id = skill_id
      @skill_learn = PFM::Skill.new(@skill_id)
      @skill_set_not_full = @pokemon.skills_set.size < 4
      @skills = @pokemon.skills_set
      @index = 4
      @learnt = false
      @state = :start
      @running = true
    end
  end
  # Compatibility with old PSDK version
  Skill_Learn = MoveTeaching
end

GamePlay.move_teaching_class = GamePlay::MoveTeaching
