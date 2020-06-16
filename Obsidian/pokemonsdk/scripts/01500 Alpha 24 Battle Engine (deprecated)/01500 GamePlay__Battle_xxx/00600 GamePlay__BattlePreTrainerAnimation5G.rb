#encoding: utf-8

#noyard
module GamePlay
  class BattlePreTrainerAnimation5G

    BALL_Animation = [0, 270, 0, 225, 0, 180, 0, 135, 1, 90, 1, 45, 1, 0, 1, 315, 2, 270, 2, 225, 2,180, 2, 135, 2, 90, 2, 45, 2, 0, 2, 30, 2, 60, 2, 90, 3, 90, 3, 135, 3, 180, 3,225, 3, 270, 3, 315, 3, 0, 3, 0, 3, 0, 4, 0, 4, 0, 4, 0, 4, 0, 4, 0, 5, 0]
    #===
    #>initialize 
    # Initialisatation du module
    #---
    #E : viewport : Viewport sur lequel les sprites seront affichés
    #===
    def initialize(viewport, screenshot)
      @viewport = viewport
      @unlocked = false
      @actors_ground = ::GamePlay::BattleGrounds.new(@viewport, true)
      @actors_ground.x -= 320
      @actors_ground.y += 320
      @enemies_ground = ::GamePlay::BattleGrounds.new(@viewport, false)
      @enemies_ground.x -= 320
      @enemies_ground.y += 320
      #> $game_temp.enemy_battler[0]
      @enemy_sprite = Sprite.new(@viewport).set_bitmap($game_temp.enemy_battler[0], :battler)
                                           .set_position(185 - 320, 94 + 320).set_origin_div(2, 1)
      @enemy_sprite.x += @enemy_sprite.ox
      @actor_sprite = Sprite.new(@viewport).set_bitmap($game_actors[1].battler_name, :battler)
                                           .set_position(40 - 320, 174 + 320).set_origin_div(2, 1)
      @actor_sprite.x += @actor_sprite.ox
      #>Transition d'entrée /!\ Ne dois pas être géré par le système automatique
      @screen = Sprite.new(viewport)
      @screen.zoom = Graphics.width / screenshot.width.to_f
      @screen.bitmap = screenshot
      viewport.color.set(255, 255, 255, 0)
      @counter = 0
    end

    #===
    #>Mise à jour de la scène
    # Retours : 
    #   true = transition en cours
    #   false = transition terminée
    #===
    def update
      if(@screen)
        update_map_transition
        return true
      end
      if(@counter < 30)
        @viewport.color.alpha -= 9
      elsif(@counter < 62)
        @actors_ground.add_xy(10, -10)
        @enemies_ground.add_xy(10, -10)
        @enemy_sprite.add_xy(10, -10)
        @actor_sprite.add_xy(10, -10)
      elsif(@unlocked) #> Rien ne se passera
        return false
      else
        return false
      end
      @counter += 1
      return true
    end

    #===
    #>Mise à jour de la transition de map
    #===
    def update_map_transition
      if @counter < 60
        if ((@counter / 15) & 0x01) == 0
          @viewport.color.alpha += 17
        else
          @viewport.color.alpha -= 17
        end
      elsif @counter < 120
        #@screen.bitmap.radial_blur(3, 2) if (@counter % 4) == 0
        dz = 1/60.0
        @viewport.color.set(60, 60, 60, 0)
        @counter = 120
        Yuki::Transitions.weird_transition(59, bitmap: @screen.bitmap) do |i, sp|
          if i >= 30
            sp.zoom = sp.zoom_x + dz
          end
          if i >= 40
            @viewport.color.alpha += 10
          end
        end
        #@viewport.color.alpha += 5 if @counter >= 69
      else
        @screen.bitmap.dispose
        @screen.dispose
        @screen = nil
        return @counter = 0
      end
      @counter += 1
    end

    #===
    #>Déverrouillage pour finir l'animation
    #===
    def unlock
      @unlocked = true
    end
    #===
    #>Lancement des balles
    #===
    def launch_balls
      enemies = BattleEngine.get_enemies
      actors = BattleEngine.get_actors
      ball_sprites = Array.new
      delta_ball = 40
      max = $game_temp.vs_type
      tbls = [BattleSprite::E_Pos, BattleSprite::A_Pos]
      max.times do |i|
        index = max == 2 ? i : 2
        sp = ball_sprites[i] = Sprite.new(@viewport).
          set_coordinates(tbls[0][index][0] + 48, tbls[0][index][1] - 60, 20).
          set_origin(32, 32)
        sp.bitmap = RPG::Cache.ball(enemies[i].ball_sprite) if enemies[i]
        sp = ball_sprites[i + max] = Sprite.new(@viewport).
          set_coordinates(tbls[1][index][0] + 48, tbls[1][index][1] - 60, 3).
          set_origin(32, 32)
        sp.bitmap = RPG::Cache.ball(actors[i].ball_sprite) if actors[i]
      end
      (BALL_Animation.size/2).times do |i|
        ball_sprites.each do |sp|
          sp.src_rect.set(0,BALL_Animation[i*2]*64,64,64)
          sp.angle = BALL_Animation[i*2+1]
          sp.y += 5 if i >= 20 and i < 30
        end
        @enemy_sprite.add_xy(10, -10)
        @actor_sprite.add_xy(-10, 10)
        update
        Graphics.update
      end
      @viewport.flash(Color.new(255,255,255), 30)
      ball_sprites.each { |sp| sp.dispose if sp }
    end
    #===
    #>dispose
    # Effacement de tout le stuff affiché par la scene
    #===
    def dispose
      @actors_ground.dispose
      @enemies_ground.dispose
    end
  end
end

