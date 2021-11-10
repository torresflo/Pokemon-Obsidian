#version 120

uniform vec2 displayCoordinates;
uniform vec2 screenFactor;
uniform vec2 waterOffset;
varying vec2 waterOffsetTex;
varying vec2 waterWaveTex;

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  vec2 screenCoordinates = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  gl_TexCoord[0].xy = screenCoordinates;
  waterOffsetTex = screenCoordinates * screenFactor + displayCoordinates + waterOffset;
  waterWaveTex = (screenCoordinates * screenFactor + displayCoordinates) / 4;
}
