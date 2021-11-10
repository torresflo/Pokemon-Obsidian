module Configs
  class CreditsConfig
    # Get the project title splash (in grahics/titles)
    # @return [String]
    attr_accessor :project_splash
    # Get the chief project title
    # @return [String]
    attr_accessor :chief_project_title
    # Get the chief project name
    # @return [String]
    attr_accessor :chief_project_name
    # Get the other leaders
    # @return [Array<Hash>]
    attr_accessor :leaders
    # Get the game credits
    # @return [String]
    attr_accessor :game_credits
    # Get the credits bgm
    # @return [String]
    attr_accessor :bgm
    # Get the line height of credits
    # @return [Integer]
    attr_accessor :line_height
    # Get the speed of the text scrolling
    # @return [Float]
    attr_accessor :speed
    # Get the spacing between a leader text and the center of the screen
    # @return [Integer]
    attr_accessor :leader_spacing

    # Create a new config
    def initialize
      @project_splash = 'title'
      @chief_project_title = 'Main Supporter'
      @chief_project_name = 'Pokémon Workshop'
      @leaders = [
        { title: 'Creator of PSDK', name: 'Nuri Yuri' }, # 1
        { title: 'Developper of LiteRGSS2', name: 'Scorbutics' }, # 1
        { title: 'Developpers of PSDK', name: 'Aerun, Rey, Palbolsky, Leikt' }, # 2
        { title: 'Lead Graphic Designer of PSDK', name: 'SirMalo' }, # 2
        { title: 'Occasional Contributors of .25', name: 'SoloReprise, buttjuice & Mud' }, # 3
        { title: 'MacOS Supporter', name: 'Lynn Isip' } # 3
      ]
      @game_credits = "# Title\n## Sub Title\n### SubSubTitle\nOne Name\nTwo Column || Names\n\n# Title after empty line"
      @bgm = 'ending'
      @line_height = 12
      @speed = 60.0
      @leader_spacing = 48
    end
  end

  # @!method self.credits_config
  #   @return [CreditsConfig]
  register(:credits_config, 'credits_config', :yml, false, CreditsConfig)
end
