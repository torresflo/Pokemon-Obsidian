const vec4 shadowVect = vec4(0.2, -0.2, 0, 0);

void main()
{
  gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
  gl_FrontColor = gl_Color;
  float invY = 1 - gl_TexCoord[0].y;
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex + shadowVect * invY;
}