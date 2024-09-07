package shaders;

import shaders.Transpiler.transpileShader;

import utest.Assert;
import utest.Test;

class TranspilerTests extends Test {
  final vertexSource = [
    '#version 300 es',
    'in vec3 vertexPosition;',
    'in vec4 vertexColor;',
    'in vec2 vertexUV;',
    'uniform mat4 projectionMatrix;',
    'out vec4 fragColor;',
    'out vec2 fragUV;',
    'void main() {',
    ' gl_Position = projectionMatrix * vec4(vertexPosition, 1.0);',
    ' fragColor = vertexColor;',
    ' fragUV = vertexUV;',
    '}',
  ].join('\n');

  final fragmentSource = [
    '#version 300 es',
    'precision mediump float;',
    'uniform sampler2D tex;',
    'in vec4 fragColor;',
    'out vec4 FragColor;',
    'in vec2 fragUV;',
    'void main() {',
    ' vec4 texColor = texture(tex, fragUV) * fragColor;',
    ' texColor.rgb *= fragColor.a;',
    ' FragColor = texColor;',
    '}',
  ].join('\n');

  final vertexResult = [
    '#version 100',
    'attribute vec3 vertexPosition;',
    'attribute vec4 vertexColor;',
    'attribute vec2 vertexUV;',
    'uniform mat4 projectionMatrix;',
    'varying vec4 fragColor;',
    'varying vec2 fragUV;',
    'void main() {',
    ' gl_Position = projectionMatrix * vec4(vertexPosition, 1.0);',
    ' fragColor = vertexColor;',
    ' fragUV = vertexUV;',
    '}',
  ].join('\n');

  final fragmentResult = [
    '#version 100',
    'precision mediump float;',
    'uniform sampler2D tex;',
    'varying vec4 fragColor;',
    'varying vec2 fragUV;',
    'void main() {',
    ' vec4 texColor = texture2D(tex, fragUV) * fragColor;',
    ' texColor.rgb *= fragColor.a;',
    ' gl_FragColor = texColor;',
    '}',
  ].join('\n');

  function testTranspileVertexShader() {
    final result = transpileShader(vertexSource, VERTEX);

    Assert.equals(vertexResult, result);
  }

  function testTranspileFragmentShader() {
    final result = transpileShader(fragmentSource, FRAGMENT);

    Assert.equals(fragmentResult, result);
  }
}
