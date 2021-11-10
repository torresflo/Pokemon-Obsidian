$sp = ShaderedSprite.new
$sp.set_bitmap('212_30', :poke_front)
$sp.set_position(160, 120)
$sp.set_origin(48, 96)
$sp.z = 100000
$spfront = ShaderedSprite.new
$spfront.set_bitmap('212_30', :poke_front)
$spfront.set_position(160, 120)
$spfront.set_origin(48, 96)
$spfront.z = 100000

$sp.shader = Shader.new(<<~EOVERT, <<~EOFRAG)
const vec4 shadowVect = vec4(0.2, -0.2, 0, 0);

void main()
{
  gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
  gl_FrontColor = gl_Color;
  float invY = 1 - gl_TexCoord[0].y;
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex + shadowVect * invY;
}
EOVERT
uniform sampler2D texture;
const vec4 gray = vec4(0.5, 0.5, 0.5, 0.8);
const vec4 blank = vec4(0, 0, 0, 0);
void main()
{
  vec4 frag = texture2D(texture, gl_TexCoord[0].xy);
  gl_FragColor = mix(blank, gray, frag.a) * gl_Color;
}
EOFRAG

# require 'pokemonsdk/Tests/shader_test3.rb'

=begin
ORIGINAL CODE:
$sp.shader = Shader.new(<<~EOVERT, <<~EOFRAG)
const vec4 textureOffset = vec4(-0.5, -1, 0, 0);
const vec4 shadowVect = vec4(-60, -48, 0, 0);
void main()
{
  gl_TexCoord[0] = gl_TextureMatrix[0] * (gl_MultiTexCoord0 * 2) + textureOffset;
  float invY = 1 - gl_TexCoord[0].y;
  gl_TexCoord[1] = gl_TextureMatrix[0] * (gl_MultiTexCoord0 * 2 + shadowVect * invY) + textureOffset;
  gl_FrontColor = gl_Color;
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
EOVERT
uniform sampler2D texture;

const vec4 gray = vec4(0.5, 0.5, 0.5, 0.8);
void main()
{
  vec2 coords = gl_TexCoord[0].xy;
  vec4 frag = texture2D(texture, coords);
  if (coords != clamp(coords, 0, 1)) { 
    frag.a = 0;
  }
  coords = gl_TexCoord[1].xy;
  float alpha = texture2D(texture, coords).a;
  if (coords != clamp(coords, 0, 1)) {
    alpha = 0;
  }
  gl_FragColor = mix(gray * alpha, frag, frag.a) * gl_Color;
}
EOFRAG
=end
