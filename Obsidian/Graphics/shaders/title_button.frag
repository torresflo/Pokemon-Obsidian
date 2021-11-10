uniform float t;

const vec4 COLORS[7] = vec4[](
  vec4(1.0000, 0.1490, 0.2196, 1.0),
  vec4(1.0000, 0.4196, 0.1882, 1.0),
  vec4(1.0000, 0.6353, 0.0078, 1.0),
  vec4(0.0078, 0.8157, 0.5686, 1.0),
  vec4(0.0039, 0.5020, 0.9843, 1.0),
  vec4(0.4824, 0.2118, 0.8549, 1.0),
  vec4(1.0000, 0.1490, 0.2196, 1.0) // Re-adding the first color to avoid mod() operation after 'colorIndex + 1'
);
const float PI = 3.1415;

void main() {
  vec2 tc = gl_TexCoord[0].xy;
  float circleX = mod((tc.x - t) * 6.0, 1.0);
  float colorIndex = mod((tc.x - t) * 6.0, 6.0);
  vec4 frag = mix(
    COLORS[int(floor(colorIndex))],
    COLORS[int(floor(colorIndex)) + 1],
    fract(colorIndex)
  );
  float circleRadius = pow(sin(tc.x * PI), 3);
  frag.a = 1.0 - (sqrt(pow((tc.y * 2.0 - 1.0) / circleRadius, 2) + pow(circleX * 2.0 - 1.0, 2)));
  gl_FragColor = frag;
}