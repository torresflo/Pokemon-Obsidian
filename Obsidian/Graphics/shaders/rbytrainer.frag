uniform sampler2D texture;
uniform float t;

const vec4 black = vec4(0, 0, 0, 1);
const vec4 trans = vec4(0, 0, 0, 0);

void main() {
  vec2 tc = gl_TexCoord[0].xy;
  vec4 frag = texture2D(texture, gl_TexCoord[0].xy);
  float comparisonT = frag.r + frag.g / 256.0;

  if (comparisonT < t) {
    frag = black;
  } else {
    frag = trans;
  }

  gl_FragColor = frag;
}