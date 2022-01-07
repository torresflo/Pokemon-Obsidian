module Yuki
  # Module that display various transitions on the screen
  module Transitions
    # The number of frame the transition takes to display
    NB_Frame = 60

    module_function

    # Show a circular transition (circle reduce it size or increase it)
    # @param direction [-1, 1] -1 = out -> in, 1 = in -> out
    # @note A block can be yield if given, its parameter is i (frame) and sp1 (the screenshot)
    def circular(direction = -1)
      sp1 = ShaderedSprite.new($scene.viewport || Graphics.window)
      sp1.bitmap = Texture.new(Graphics.width, Graphics.height)
      sp1.shader = shader = Shader.create(:yuki_circular)
      shader.set_float_uniform('xfactor', sp1.bitmap.width.to_f / (h = sp1.bitmap.height))
      0.upto(NB_Frame) do |i|
        yield(i, sp1) if block_given?
        j = (direction == 1 ? i : NB_Frame - i)
        shader.set_float_uniform('r4', (r = (j / NB_Frame.to_f))**2)
        shader.set_float_uniform('r3', ((r * h - 10) / h)**2)
        shader.set_float_uniform('r2', ((r * h - 20) / h)**2)
        shader.set_float_uniform('r1', ((r * h - 30) / h)**2)
        Graphics.update
      end
      sp1.shader = shader = nil
      dispose_sprites(sp1)
    end

    # Hash that give the angle according to the direction of the player
    Directed_Angles = {
      -8 => 0, 8 => 180,
      -4 => 90, 4 => 270,
      -2 => 180, 2 => 0,
      -6 => 270, 6 => 90
    }
    Directed_Angles.default = 0
    # Hash that give x factor (* w/2)
    Directed_X = {
      -8 => 1, 8 => 1,
      -4 => -2, 4 => 0,
      -2 => 1, 2 => 1,
      -6 => 4, 6 => 2
    }
    Directed_X.default = 0
    # Hash that give the y factor (* w/2)
    Directed_Y = {
      -8 => -2, 8 => 0,
      -4 => 1, 4 => 1,
      -2 => 4, 2 => 2,
      -6 => 1, 6 => 1
    }
    Directed_Y.default = 0
    # Transition that goes from up -> down or right -> left
    # @param direction [-1, 1] -1 = out -> in, 1 = in -> out
    # @note A block can be yield if given, its parameter is i (frame) and sp1 (the screenshot)
    def directed(direction = -1)
      w = Graphics.width
      w2 = w * 2.0
      gp = $game_player
      dx = gp.direction.between?(4, 6) ? w2 / NB_Frame : 0
      dy = dx == 0 ? w2 / NB_Frame : 0
      dx *= -1 if gp.direction == 6
      dy *= -1 if gp.direction == 2
      d = gp.direction * direction
      sp1 = ShaderedSprite.new($scene.viewport || Graphics.window)
      sp1.bitmap = Texture.new(w, w2.to_i)
      sp1.shader = Shader.create(:yuki_directed)
      sp1.shader.set_float_array_uniform('yval', Array.new(10) { |i| (w + 10 * i) / w2 })
      # Processing
      sp1.set_origin(w / 2, w)
      sp1.angle = Directed_Angles[d]
      sp1.set_position(Directed_X[d] * w / 2, Directed_Y[d] * w / 2)
      NB_Frame.times do |i|
        yield(i, sp1) if block_given?
        sp1.set_position(sp1.x + dx, sp1.y + dy)
        Graphics.update
      end
      sp1.shader = nil
      dispose_sprites(sp1)
    end

    # Display a weird transition (for battle)
    # @param nb_frame [Integer] the number of frame used for the transition
    # @param radius [Float] the radius (in texture uv) of the transition effect
    # @param max_alpha [Float] the maxium alpha value for the transition effect
    # @param min_tau [Float] the minimum tau value of the transition effect
    # @param delta_tau [Float] the derivative of tau between the begining and the end of the transition
    def weird_transition(nb_frame = 60, radius = 0.25, max_alpha = 0.5, min_tau = 0.07, delta_tau = 0.07, bitmap: nil)
      sp = ShaderedSprite.new($scene.viewport || Graphics.window)
      sp.bitmap = bitmap || $scene.snap_to_bitmap
      sp.zoom = Graphics.width / sp.bitmap.width.to_f
      sp.shader = shader = Shader.create(:yuki_weird)
      sp.set_origin(sp.bitmap.width / 2, sp.bitmap.height / 2)
      sp.set_position(Graphics.width / 2, Graphics.height / 2)
      shader.set_float_uniform('radius', radius)
      0.step(nb_frame) do |i|
        yield(i, sp) if block_given?
        shader.set_float_uniform('alpha', max_alpha * i / nb_frame)
        shader.set_float_uniform('tau', min_tau + (delta_tau * i / nb_frame))
        Graphics.update
      end
      sp.shader = shader = nil
      bitmap ? sp.dispose : dispose_sprites(sp)
    end

    # Display a BW in->out Transition
    # @param transition_sprite [Sprite] a screenshot sprite
    def bw_zoom(transition_sprite)
      60.times do
        transition_sprite.zoom_x = (transition_sprite.zoom_y *= 1.005)
        Graphics.update
      end
      30.times do
        transition_sprite.zoom_x = (transition_sprite.zoom_y *= 1.01)
        transition_sprite.opacity -= 9
        Graphics.update
      end
      transition_sprite.bitmap.dispose
      transition_sprite.dispose
    end

    # Dispose the sprites
    # @param args [Array<Sprite>]
    def dispose_sprites(*args)
      args.each do |sprite|
        next unless sprite
        sprite.bitmap.dispose
        sprite.dispose
      end
    end
  end
end
