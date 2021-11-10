# load 'pokemonsdk/Tests/test_animation_waiter.rb'
sprite = Sprite.new(vp = Viewport.create(:main, 15000))
sprite.load('001', :icon)
animation = Yuki::Animation.move(1, sprite, 0, 0, 20, 20)
animation.play_before(Yuki::Animation.wait_signal { $test == 5 })
animation.play_before(Yuki::Animation.move(1, sprite, 20, 20, 0, 0))
animation.start
until animation.done?
  animation.update
  $test = 5 if Mouse.trigger?(:LEFT)
  Graphics.update
end
vp.dispose
$test = nil