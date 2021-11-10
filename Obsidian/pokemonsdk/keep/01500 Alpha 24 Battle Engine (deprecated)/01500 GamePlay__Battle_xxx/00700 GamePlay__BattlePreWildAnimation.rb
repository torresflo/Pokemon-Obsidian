#encoding: utf-8

#noyard
module GamePlay
  class BattlePreWildAnimation < BattlePreTrainerAnimation
    Functions = [
    [:grass_init, :grass_update, :grass_dispose],
    [:nothing_init, :nothing_update, :nothing_dispose]
    ]
    #===
    #>initialize 
    # Initialisatation du module
    #---
    #E : viewport : Viewport sur lequel les sprites seront affichés
    #===
    def initialize(viewport, screenshot)
      @unlocked = false
      @viewport = viewport
      @viewport.color.set(255, 255, 255, 0)
      if($env.tall_grass? or $env.very_tall_grass?)
        id = 0
      else
        id = 1
      end
      @functions = Functions[id]

      @ground = GamePlay::BattleGrounds.new(viewport, false)
      @delta_x = delta_x = 160 - @ground.x
      @delta_y = delta_y = 120 - @ground.y
      @ground.x += delta_x
      @ground.y += delta_y
      i = 0
      sprite = nil
      pkmn = nil
      @enemies = Array.new($game_temp.vs_type) do |i|
        pkmn = $scene.enemy_party.actors[i]
        pkmn.position = -i-1
        sprite = BattleSprite.new(viewport, pkmn)
        sprite.x += delta_x
        sprite.y += delta_y
        # sprite.color.alpha = 255
        next(sprite)
      end
      @delta_x /= 30.0
      @delta_y /= 30.0
      send(@functions[0])
      #>Transition d'entrée
      @screen = ::Sprite.new(viewport)
      @screen.zoom = Graphics.width / screenshot.width.to_f
      @screen.bitmap = screenshot
      @counter = 0
    end
    #===
    #>Mise à jour de la scène
    #===
    def update
      if(@screen)
        update_map_transition
        return true
      else
        return send(@functions[1])
      end
    end
    #===
    #>Mise à jour de la transition de map
    #===
    def update_map_transition
      if(@counter == 0)
        @viewport.flash(Color.new(255,255,255,128), 30)
      elsif(@counter >= 56)
        Graphics.brightness = 255
        @screen.bitmap.dispose
        @screen.dispose
        @screen = nil
        @counter = 0
        send(@functions[1])
      elsif(@counter >= 30)
        # @screen.color.alpha += 20
        Graphics.brightness -= 20
      end
      @viewport.update if @screen
      @counter += 1
    end
    #===
    #>dispose
    # Effacement de tout le stuff affiché par la scene
    #===
    def dispose
      send(@functions[2])
      i = nil
      @enemies.each do |i|
        i.dispose
      end
      @ground.dispose
    end
    #===
    #>repos_enemy
    # Repositionnement des enemis au bon endroit
    #===
    def repos_enemy
      @enemies.each do |i|
        i.x -= @delta_x
        i.y -= @delta_y
      end
      @ground.x -= @delta_x
      @ground.y -= @delta_y
    end
    #===
    #>recolorise_enemy
    # Recolorisation de l'enemy
    # 
    #===
    def recolorise_enemy
      @enemies.each do |i|
        # i.color.alpha -= 10
      end
    end
    #===
    #>Dummy
    #===
    def nothing_init

    end
    def nothing_update
      if(@counter <= 90)
        if(@counter > 60)
          i = $scene.message_window
          i.visible = true unless i.visible
          i.opacity = 255*(@counter - 59)/30
        end
      elsif(@counter <= 120)
        recolorise_enemy
      elsif(@unlocked)
        if(@counter <= 150)
          repos_enemy
        else
          return false
        end
      else
        return false
      end  
      @counter += 1
      return true
    end
    def nothing_dispose
    end
    #====
    #>Transition de l'herbe
    #===
    def grass_init
      #Herbe du fond
      @layer1 = Sprite.new(@viewport)
      @layer1.bitmap = RPG::Cache.transition("ecd_poke03")
      @layer1.y = 240 - 128
      @layer11 = Sprite.new(@viewport)
      @layer11.bitmap = @layer1.bitmap
      #Herbe de devant
      @layer2 = Sprite.new(@viewport)
      @layer2.bitmap = RPG::Cache.transition("ecd_poke01")
      @layer22 = Sprite.new(@viewport)
      @layer22.bitmap = RPG::Cache.transition("ecd_poke02")
      @layer22.x = @layer11.x = 256
      @layer22.y = @layer2.y = @layer11.y = @layer1.y
      @layer2.ox = @layer22.ox = 512
      @layer11.ox = @layer1.ox = -320
      #>Fond noir qui se déplace
      @black = Sprite.new(@viewport)
      @black.bitmap = Texture.new(448, 240)
      @black.bitmap.fill_rect(128,0,320,240, Color.new(0,0,0))
      bmp = RPG::Cache.transition("ecd_z01")
      @black.bitmap.blt(0,0, bmp, bmp.rect)
      @black.ox = 128

      @black.z = 99999
      @layer1.z = 101
      @layer11.z = 102
      @layer2.z = 103
      @layer22.z = 104
      @black.visible = @layer2.visible = @layer22.visible = @layer1.visible = 
      @layer11.visible = false
    end

    def grass_update
      if(@counter == 0)
        @black.visible = @layer2.visible = @layer22.visible = @layer1.visible = 
        @layer11.visible = true
      elsif(@counter <= 30)
        @black.ox -= 16
        @layer2.ox = (@layer22.ox -= 16) 
        @layer11.ox = (@layer1.ox += 16)
      elsif(@counter <= 90)
        @layer2.ox = (@layer22.ox -= 8) 
        @layer11.ox = (@layer1.ox += 8)
        if(@counter > 60)
          @layer2.opacity = @layer22.opacity = @layer11.opacity = (@layer1.opacity -= 9)
          i = $scene.message_window
          i.visible = true unless i.visible
          i.opacity = 255*(@counter - 59)/30
        end
      elsif(@counter <= 120)
        recolorise_enemy
      elsif(@unlocked)
        if(@counter <= 150)
          repos_enemy
        else
          return false
        end
      else
        return false
      end  
      @counter += 1
      return true
    end

    def grass_dispose
      @black.bitmap.dispose
      @black.dispose
      @layer1.dispose
      @layer11.dispose
      @layer2.dispose
      @layer22.dispose
    end

    def get_sprite(i)
      @enemies[i]
    end
  end
end

