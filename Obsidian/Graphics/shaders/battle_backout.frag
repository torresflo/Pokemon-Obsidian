uniform sampler2D texture;
uniform float time;
uniform sampler2D bk0;
uniform sampler2D bk1;
uniform sampler2D bk2;
uniform sampler2D bk3;
uniform sampler2D bk4;
uniform sampler2D bk5;
const vec2 bkDistr = vec2(10, 8);
const vec4 blank = vec4(0, 0, 0, 0);
void main()
{
  vec4 bkfrag;
  vec2 bkCoord = mod(gl_TexCoord[0].xy * bkDistr, 1);
  float currentTime = time * (bkDistr.x + 6);
  float currentPos = ceil((1 - gl_TexCoord[0].x) * bkDistr.x);
  if (currentTime >= currentPos) {
    float texIndex = floor(currentTime - currentPos);
    if (texIndex < 1) {
      bkfrag = texture2D(bk5, bkCoord);
    } else if (texIndex < 2) {
      bkfrag = texture2D(bk4, bkCoord);
    } else if (texIndex < 3) {
      bkfrag = texture2D(bk3, bkCoord);
    } else if (texIndex < 4) {
      bkfrag = texture2D(bk2, bkCoord);
    } else if (texIndex < 5) {
      bkfrag = texture2D(bk1, bkCoord);
    } else {
      bkfrag = texture2D(bk0, bkCoord);
    }
  } else {
    bkfrag = blank;
  }
  vec4 frag = texture2D(texture, gl_TexCoord[0].xy);
  gl_FragColor = vec4(mix(frag, bkfrag, round(bkfrag.a * 6) / 6).rgb, 1);
}
