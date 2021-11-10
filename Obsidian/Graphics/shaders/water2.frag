#version 120

uniform sampler2D texture;
uniform sampler2D waterTexture;
uniform sampler2D stillWaterTexture;
uniform sampler2D displacementTexture;
uniform vec2 screenFactor;
varying vec2 waterOffsetTex;
varying vec2 waterWaveTex;
uniform vec2 waterWave;

void main() {
  vec4 frag = texture2D(texture, gl_TexCoord[0].xy);

  if (frag.a < 0.91 && frag.a > 0.0) {
    vec2 displacement = (texture2D(displacementTexture, mod(mod(waterWaveTex, 0.25) + waterWave, 1)).xy - vec2(0.5)) / screenFactor;
    vec4 frag2 = texture2D(texture, gl_TexCoord[0].xy + displacement);
    if (frag2.a < 0.91) {
      frag = frag2;
    }
    if (frag.a < 0.21) {
      frag = vec4(mix(frag.rgb, texture2D(waterTexture, mod(waterOffsetTex, 1)).rgb, 0.25), 1);
    } else {
      frag.rgb = frag.rgb + (
        texture2D(stillWaterTexture, mod(mod(waterOffsetTex / 2, 0.5), 1)).rgb +
        texture2D(stillWaterTexture, mod(mod(waterOffsetTex / 2, 0.5) + waterWave * vec2(-4, -2), 1)).rgb - vec3(1)) * vec3(0.25);
      frag.a = 1;
    }
  }

  gl_FragColor = frag;
}
