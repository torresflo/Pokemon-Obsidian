uniform sampler2D texture;
const vec4 gray = vec4(0.4, 0.4, 0.4, 0.3);
const vec4 blank = vec4(0, 0, 0, 0);
void main()
{
  vec4 frag = texture2D(texture, gl_TexCoord[0].xy);
  gl_FragColor = mix(blank, gray, frag.a) * gl_Color;
}