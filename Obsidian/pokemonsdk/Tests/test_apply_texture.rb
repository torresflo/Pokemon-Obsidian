@sp = ShaderedSprite.new
@sp.set_bitmap('001', :poke_front)

@sp.shader = Shader.new(<<~EOS)
uniform sampler2D texture;
uniform sampler2D textureTop;
uniform float yOffset;

void main()
{
  vec2 coords = gl_TexCoord[0].xy;
  vec4 frag = texture2D(texture, coords);
  vec2 coordsTop = vec2(coords.x, mod(coords.y + yOffset, 1));
  vec4 fragTop = texture2D(textureTop, coordsTop);
  gl_FragColor = mix(frag, fragTop, frag.a * fragTop.a);
}
EOS

@sp.shader.set_texture_uniform('textureTop', RPG::Cache.poke_front('006'))

delta_y = 1 / 96.0
value = 0

loop do
  @sp.shader.set_float_uniform('yOffset', value)
  Graphics.update
  value = (value + delta_y) % 1
end

# require 'pokemonsdk/Tests/test_apply_texture.rb'