#encoding: utf-8

#noyard
module GamePlay
  class BattlePreTrainerAnimation
    Files = ["battle_bg","battle_deg","battle_halo1","battle_halo2","black_out0"]
    Angle = -3 #Angle de déplacement en degres
    DX = -Math::cos(Angle * Math::PI / 180)
    DY = Math::sin(Angle * Math::PI / 180)
    DegrOffset = 90
    MaxDelta = 120
    BALL_Animation = [0, 270, 0, 225, 0, 180, 0, 135, 1, 90, 1, 45, 1, 0, 1, 315, 2, 270, 2, 225, 2,180, 2, 135, 2, 90, 2, 45, 2, 0, 2, 30, 2, 60, 2, 90, 3, 90, 3, 135, 3, 180, 3,225, 3, 270, 3, 315, 3, 0, 3, 0, 3, 0, 4, 0, 4, 0, 4, 0, 4, 0, 4, 0, 5, 0]
    #===
    #>initialize 
    # Initialisatation du module
    #---
    #E : viewport : Viewport sur lequel les sprites seront affichés
    #===
    def initialize(viewport, screenshot)
      @unlocked = false
      @bg_delta = 0

      @background = Sprite.new(viewport)
        .set_origin(320, 240)
        .set_bitmap(Files[0], :transition)
      @background.angle = Angle

      @degrade = Sprite.new(viewport)
        .set_origin(0, DegrOffset)
        .set_position(0, DegrOffset)
        .set_bitmap(Files[1], :transition)
      @degrade.zoom_y = 0.10
      @degrade.opacity = 255 * @degrade.zoom_y

      @halo1 = Sprite.new(viewport).set_bitmap(Files[2], :transition)
      @halo2 = Sprite.new(viewport)
        .set_origin(-640, 0)
        .set_bitmap(Files[3], :transition)
      @halo3 = Sprite.new(viewport)
        .set_origin(-640, 0)
        .set_position(640, 0)
        .set_bitmap(Files[3], :transition)

      @battler = ::Sprite.new(viewport)
        .set_bitmap($game_temp.enemy_battler[0] + "_sma", :battler)
      @battler.x = -@battler.bitmap.width / 4
      @battler2 = ::Sprite.new(viewport)
        .set_bitmap($game_temp.enemy_battler[0] + "_big", :battler)
      @battler.ox = @battler2.ox = @battler.bitmap.width/2
      @battler2.x = 160
      @battler2.opacity = 0

      #>Compteur de la vitesse
      @spd_counter = 0
      @unlock_counter = -20
      @degrade_unfinished = true #>Pour déterminer si on dézoome ou pas
      @battler_wait = 0
      #>Transition d'entrée
      @screen = ::Sprite.new(viewport)
      @screen.bitmap = screenshot
      @screen.zoom = Graphics.width / screenshot.width.to_f
      @blackouts = Array.new(6) { |i| ::RPG::Cache.transition(Files[4]+(5-i).to_s) }
      2.times { @blackouts << @blackouts[5] }
      @blackout_counter = 0
    end

    #===
    #>Mise à jour de la scène
    #===
    def update
      if(@screen)
        update_map_transition
        return true
      end
      #>Déplacement du fond
      @background.set_position(@bg_delta * DX + 160, @bg_delta * DY + 120)
      @bg_delta += spd_calculation
      @bg_delta -= MaxDelta if @bg_delta >= MaxDelta
      #Déplacement des halos
      @halo2.ox += 21
      @halo3.ox += 21
      if(@halo2.ox >= 640)
        @halo2.ox-= 640 
        @halo3.ox-= 640 
      end
      #Mise à jour du dégradé
      if(@degrade_unfinished and @degrade.zoom_y < 1.25)
        @degrade.zoom_y += 0.05
        if @degrade.zoom_y >= 1.25
          @degrade.zoom_y = 1.25
          @degrade_unfinished = false
        end
        @degrade.opacity = 500*@degrade.zoom_y
      elsif(@degrade.zoom_y > 1)
        @degrade.zoom_y -= 0.05
        @degrade.zoom_y = 1 if @degrade.zoom_y <= 1
      end
      #>Mise à jour du battler
      if(@battler.x < 160)
        @battler.x += 7
        @battler.x = 160 if(@battler.x >= 160)
      elsif(@battler_wait < 20)
        @battler_wait += 1
      elsif(@battler.opacity > 0)
        @battler.opacity -= 10
        @battler2.opacity += 10
      elsif(@unlocked and @battler2.x < 480)
        if(@unlock_counter < 0)
          @battler2.x -= 2
          @unlock_counter += 1
        else
          @battler2.x += 15
          @battler2.opacity -= 10
        end
      else
        return false
      end
      return true
    end

    #===
    #>Mise à jour de la transition de map
    #===
    def update_map_transition
      @blackout_counter += 1
      generate_blackout_matrix unless @blackout_matrix
      @blackouts.size.times do |i|
        x = 10 - @blackout_counter / 3 + i
        next if x >= 10 or x < 0
        bmp = @blackouts[i]
        8.times { |y| @blackout_matrix[x][y].bitmap = bmp }
      end
      dispose_map_transition if(@blackout_counter >= 100)
    end
    # Generate the blackout matrix
    def generate_blackout_matrix
      viewport = Viewport.create(:main, 10_000)
      delta = 32
      @blackout_matrix = Array.new(10) do |x|
        Array.new(8) do |y|
          Sprite.new(viewport).set_position(x * delta, y * delta)
        end
      end
    end
    # Dispose the map transition
    def dispose_map_transition
      @screen.bitmap.dispose
      @screen.dispose
      @screen = nil
      @blackouts = nil
      @blackout_matrix[0][0].viewport.dispose
      @blackout_matrix = nil
    end
    #===
    #>Déverrouillage pour finir l'animation
    #===
    def unlock
      @unlocked = true
    end
    #===
    #>Variateur de vitesse
    #===
    def spd_calculation
      @spd_counter += 1
      if(@spd_counter >= 600)
        @spd_counter -= 600
      end
      return (2.5 - Math::cos(Math::PI * @spd_counter / 300))
    end
    #===
    #>Lancement des balles
    #===
    def launch_balls
      enemies = BattleEngine.get_enemies
      ball_sprites = Array.new
      delta_ball = 20
      $game_temp.vs_type.times do |i|
        sp = ball_sprites[i] = Sprite.new(@background.viewport)
        sp.x = 340 + i*delta_ball - ($game_temp.vs_type - 1) * delta_ball
        sp.z = 20
        sp.bitmap = RPG::Cache.ball(enemies[i].ball_sprite) if enemies[i]
        sp.ox = 32
        sp.oy = 32
      end
      delta_x = 180.0 / (BALL_Animation.size / 2)
      delta_angle = Math::PI / (BALL_Animation.size / 2)
      r_y = 80
      angle = 0
      (BALL_Animation.size/2).times do |i|
        y = 120 - Math::sin(angle) * r_y
        ball_sprites.each do |sp|
          sp.src_rect.set(0,BALL_Animation[i*2]*64,64,64)
          sp.angle = BALL_Animation[i*2+1]
          sp.x -= delta_x
          sp.y = y
        end
        update
        Graphics.update
        angle += delta_angle
      end
      @background.viewport.flash(Color.new(255,255,255), 30)
      ball_sprites.each { |sp| sp.dispose }
    end
    #===
    #>dispose
    # Effacement de tout le stuff affiché par la scene
    #===
    def dispose
      @background.dispose
      @background = nil
      @degrade.dispose
      @degrade = nil
      @halo1.dispose
      @halo1 = nil
      @halo2.dispose
      @halo2 = nil
      @halo3.dispose
      @halo3 = nil
      @battler.dispose
      @battler = nil
      @battler2.dispose
      @battler2 = nil
    end
  end
end

