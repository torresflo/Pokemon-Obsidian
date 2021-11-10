$sp = ShaderedSprite.new
$sp.set_bitmap('001', :poke_front)
# @sp.opacity = 200
$sp.z = 100000

$sp.shader = Shader.new(<<~EOVERT, <<~EOFRAG)
void main()
{
  // gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
  gl_TexCoord[0] = gl_Vertex * 2;
  // gl_FrontColor = gl_Color;
  gl_FrontColor = gl_Vertex * 2;
  // gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  gl_Position = gl_Vertex;
}
EOVERT
uniform sampler2D texture;

void main()
{
  vec2 coords = gl_TexCoord[0].xy;
  vec4 frag = texture2D(texture, coords);
  // gl_FragColor = frag * gl_Color;
  gl_FragColor = gl_Color + vec4(frag.rgb * frag.a, 0);
}
EOFRAG

# require 'pokemonsdk/Tests/shader_test1.rb'
=begin
Learning:
Center of the screen is 0, 0
Top right of the screen is 1, 1
Top left of texture is 0, 0
Bottom right of texture is 1, 1
Additional: gl_MultiTexCoord0 contains coords in actual texture size
=end