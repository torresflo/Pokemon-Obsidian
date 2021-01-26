class Game_Player
    RotomSwitchID = 152
    def character_name
        if $game_switches && $game_switches[RotomSwitchID] == true
            @_return_character_name = "479_0"
        else
            @_return_character_name = nil 
        end
        return (@_return_character_name || @character_name)
    end
end