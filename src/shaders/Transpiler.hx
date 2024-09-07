package shaders;

import haxe.Exception;

// Partly ported from:
// https://github.com/visgl/luma.gl/blob/master/modules/shadertools/src/lib/shader-transpiler/transpile-glsl-shader.ts

private final ES100_REPLACEMENTS: Array<GLSLReplacement> = [
  {
    regex: ~/^#version[ \t]+300[ \t]+es/,
    replacement: '#version 100'
  },
  {
    // In GLSL 1 ES these functions are provided by an extension.
    regex: ~/\btexture(2D|2DProj|Cube)Lod\(/g,
    replacement: 'texture$1LodEXT('
  },
  // Overloads in GLSL 3.00 map to individual functions. Note that we cannot
  // differentiate between 2D, 2DProj, Cube without type analysis so we choose the most common variant.
  {
    regex: ~/\btexture\(/g,
    replacement: 'texture2D('
  },
  {
    regex: ~/\btextureLod\(/g,
    replacement: 'texture2DLodEXT('
  }
];

private final ES100_VERTEX_REPLACEMENTS = ES100_REPLACEMENTS.concat([
  {
    // Replace `in` with `attribute`.
    regex: makeVariableTextRegex('in'),
    replacement: 'attribute $1'
  },
  {
    // Replace `out` with `varying`.
    regex: makeVariableTextRegex('out'),
    replacement: 'varying $1'
  }
]);

private final ES100_FRAGMENT_REPLACEMENTS = ES100_REPLACEMENTS.concat([
  {
    // Replace `in` with `varying`.
    regex: makeVariableTextRegex('in'),
    replacement: 'varying $1'
  }
]);

private final ES100_FRAGMENT_OUTPUT_NAME = 'gl_FragColor';

// The fragment out variable that needs to be replaced with 'gl_FragColor'.
private final ES300_FRAGMENT_OUTPUT_REGEX = ~/\bout[ \t]+vec4[ \t]+(\w+)[ \t]*;\n?/;
private final VERSION_REGEX = ~/^#version[ \t]+(\d+)/m;

/**
 * Transpile a WebGL2 shader to a WebGL1 shader.
 * @param source The WebGL2 source.
 * @param type Vertex or Fragment shader.
 * @return The converted shader code.
 */
function transpileShader(source: String, type: ShaderExtension): String {
  final match = VERSION_REGEX.match(source);
  if (match) {
    final version = Std.parseInt(VERSION_REGEX.matched(1));
    if (version != 300) {
      throw new Exception('Only WebGL2 shader version 300 source is supported.');
    }
  } else {
    throw new Exception('Only WebGL2 shader version 300 source is supported.');
  }

  switch (type) {
    case VERTEX:
      source = convertShader(source, ES100_VERTEX_REPLACEMENTS);

    case FRAGMENT:
      source = convertShader(source, ES100_FRAGMENT_REPLACEMENTS);
      source = convertFragmentShader(source);
  }

  return source;
}

/**
 * Convert the shader.
 * @param source The shader source code.
 * @param replacements The list of strings to replace.
 * @return The converted source.
 */
private function convertShader(source: String, replacements: Array<GLSLReplacement>): String {
  for (replace in replacements) {
    source = replace.regex.replace(source, replace.replacement);
  }

  return source;
}

/**
 * Convert a fragment shader.
 * @param source The shader source code.
 * @return The converted source.
 */
private function convertFragmentShader(source: String): String {
  source = convertShader(source, ES100_FRAGMENT_REPLACEMENTS);

  // Replace out with 'gl_FragColor'.
  final match = ES300_FRAGMENT_OUTPUT_REGEX.match(source);
  if (match) {
    final outputName = ES300_FRAGMENT_OUTPUT_REGEX.matched(1);
    source = ES300_FRAGMENT_OUTPUT_REGEX.replace(source, '');
    source = new EReg('\\b${outputName}\\b', 'g').replace(source, ES100_FRAGMENT_OUTPUT_NAME);
  }

  return source;
}

/**
 * Create a regex object that uses variables.
 * @param qualifier The string to find.
 */
private function makeVariableTextRegex(qualifier: Qualifier): EReg {
  // Find 'in' or 'out' variables.
  return new EReg('\\b${qualifier}[ \\t]+(\\w+[ \\t]+\\w+(\\[\\w+\\])?;)', 'g');
}

/**
 * The extensions possible for a shader.
 */
enum abstract ShaderExtension(String) from String to String {
  var VERTEX = 'vert';
  var FRAGMENT = 'frag';
}

/**
 * The search qualifiers.
 */
private enum abstract Qualifier(String) from String to String {
  var IN = 'in';
  var OUT = 'out';
}

/**
 * Find a replace object.
 */
private typedef GLSLReplacement = {
  var regex: EReg;
  var replacement: String;
}
