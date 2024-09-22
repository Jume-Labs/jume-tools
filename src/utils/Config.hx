package utils;

import haxe.Exception;

import atlas.AtlasConfig;

typedef Config = {
  /**
   * Asset folder locations.
   */
  var assetsFolder: String;

  /**
   * Shader folder location when you use custom shaders.
   */
  var shaderFolder: String;

  /**
   * Source folder locations.
   */
  var sourceFolders: Array<String>;

  /**
   * Custom main class. default is 'Main'.
   */
  var main: String;

  /**
   * Export path.
   */
  var outDir: String;

  /**
   * Haxelib libraries used.
   */
  var ?libraries: Array<{name: String, ?version: String }>;

  /**
   * Haxe defines used.
   */
  var ?defines: Array<String>;

  /**
   * Haxe parameters used.
   */
  var ?parameters: Array<String>;

  /**
   * Custom output script name. Default is 'jume.js'.
   */
  var ?scriptName: String;

  /**
   * Path to custom index.html file.
   */
  var ?indexPath: String;

  /**
   * Debug mode.
   */
  var ?debug: Bool;

  /**
   * Sprite atlas config.
   */
  var ?atlases: Array<AtlasConfig>;
}

function validateConfig(config: Config) {
  Sys.println('validating config...');
  trace(config);
  if (config.assetsFolder == null) {
    throwMissingField('assetsFolder');
  }

  if (config.shaderFolder == null) {
    throwMissingField('shaderFolder');
  }

  if (config.sourceFolders == null) {
    throwMissingField('sourceFolders');
  }

  if (config.main == null) {
    throwMissingField('main');
  }

  if (config.outDir == null) {
    throwMissingField('outDir');
  }

  config.debug ??= false;
}

private function throwMissingField(field: String) {
  trace('throw ${field}');
  throw new Exception('Missing "${field}" field in config file.');
}
