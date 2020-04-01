class Game_Player < Game_Character
    def particle_push_sand
        super unless cycling?
    end
end