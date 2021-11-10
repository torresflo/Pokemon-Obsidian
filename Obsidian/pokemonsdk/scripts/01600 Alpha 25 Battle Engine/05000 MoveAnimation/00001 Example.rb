ya = Yuki::Animation
# Thunder wave
animation_user = ya.wait(0.1)
animation_target = ya.create_sprite(:viewport, :sprite, Sprite, nil, [:load, '017-Thunder02', :animation], [:set_rect, 0, 0, 192, 192], [:zoom=, 0.5], [:set_origin, 96, 192])
main_t_anim = ya.resolved
animation_target.play_before(main_t_anim)
main_t_anim.play_before(ya.move_sprite_position(0, :sprite, :target, :target))
main_t_anim.play_before(ya.se_play('moves/thunder_wave'))
5.times do
  main_t_anim.play_before(ya.wait(0.05))
  main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 192, 0, 192, 192))
  main_t_anim.play_before(ya.wait(0.05))
  main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 0, 192, 192))
end
main_t_anim.play_before(ya.wait(0.05))
animation_target.play_before(ya.dispose_sprite(:sprite))

Battle::MoveAnimation.register_specific_animation(:thunder_wave, :first_use, animation_user, animation_target)
