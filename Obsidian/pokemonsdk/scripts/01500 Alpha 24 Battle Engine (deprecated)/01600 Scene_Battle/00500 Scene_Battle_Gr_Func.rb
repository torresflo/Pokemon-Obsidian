#encoding: utf-8

#noyard
# Description: Animations graphique des combats
class Scene_Battle
  def gr_switch_form(pkm)
    enn=(pkm.position<0)
    sp=(enn ? @enemy_sprites[-pkm.position-1] : @actor_sprites[pkm.position])
    return unless sp
    if pkm.battle_effect.has_substitute_effect?
      bmp=(enn ? RPG::Cache.poke_back("substitute") : RPG::Cache.poke_front("substitute"))
      sp.test_gif_dispose(nil)
    else
      bmp = nil#(enn ? pkm.battler_face : pkm.battler_back)
    end
#    sp.color = Color.new(0,0,0,0)
    if(bmp != sp.bitmap)
      15.times do |i|
        #sp.color.alpha=(255*i/15)
        Graphics.update
        update_animated_sprites
      end
      if bmp
        sp.bitmap = bmp
      else
        sp.test_gif_dispose(nil)
        sp.pokemon = pkm
      end
      15.times do |i|
        #sp.color.alpha=(255-(255*i/15))
        Graphics.update
        update_animated_sprites
      end
    end
    unless pkm.battle_effect.has_substitute_effect?
      # Morphing
      BattleEngine::Abilities.on_launch_ability(pkm)
    end
  end

  #ChargeAnimation = load_data("Data/Animations/charge.dat")
  def animation(launcher, target, skill)

    enn=(launcher.position<0)
    spa=(enn ? @enemy_sprites[-launcher.position-1] : @actor_sprites[launcher.position])
    #/!\ Récupérer les cibles en fonction de la propriété de l'attaque
    enn=(target.position<0)
    spb=(enn ? @enemy_sprites[-target.position-1] : @actor_sprites[target.position])

    if $options.show_animation
      PSP.move_animation(spa, spb, skill.id, launcher.position < 0)
=begin
      @animator = Yuki::Basic_Animator.new(ChargeAnimation, 
        spa, spb) 

      while @animator.update
        Graphics.update unless Input.press?(:B)
      end
      @animator = nil
=end
    end
  end

  def global_animation(id)
    PSP.animation(@actor_sprites[0],id) if $options.show_animation
  end

  def animation_on(target, id)
    enn = (target.position<0)
    spb = (enn ? @enemy_sprites[-target.position-1] : @actor_sprites[target.position])
    PSP.animation(spb,id) if $options.show_animation
  end

  def animation_shiny(target, is_sprite = false)
    unless is_sprite
      enn=(target.position<0)
      spb=spa=(enn ? @enemy_sprites[-target.position-1] : @actor_sprites[target.position])
    else
      spb=spa=target
    end
    if $options.show_animation
      @animator = Yuki::Basic_Animator.new(load_data("Data/Animations/Shiny.dat"), spa, spb)
      while @animator.update
        @viewport.sort_z
        Graphics.update unless Input.press?(:B)
      end
      @animator = nil
    end
  end

  # Start the IdlePokemonAnimation (bouncing)
  # @param pokemon_index [Integer] Index of the Pokemon in the party
  def spc_start_bouncing_animation(pokemon_index)
    sprite = @actor_sprites[pokemon_index]
    bar = @actor_bars[pokemon_index]
    @parallel_animations[Battle::Visual::IdlePokemonAnimation] = Battle::Visual::IdlePokemonAnimation.new(self, sprite, bar)
  end

  # Stop the IdlePokemonAnimation (bouncing)
  def spc_stop_bouncing_animation
    @parallel_animations[Battle::Visual::IdlePokemonAnimation]&.remove
  end
end
