package utils;

import atlas.AtlasConfig;

typedef Config = {
  /**
   * The game name. Will show in the title.
   */
  var name: String;

  /**
   * Debug mode.
   */
  var debug: Bool;

  /**
   * Optional asset folder locations Default is 'assets'.
   */
  var ?assetsFolder: String;

  /**
   * Optional shader folder location when you use custom shaders.
   */
  var ?shaderFolder: String;

  /**
   * Optional source folder locations. Default = 'src'.
   */
  var ?sourceFolders: Array<String>;

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
   * Optional custom main class. default is 'Main'.
   */
  var ?main: String;

  /**
   * Html specific settings.
   */
  var ?html5: {
    /**
     * Custom output script name. Default is 'jume.js'.
     */
    ?scriptName: String,
    /**
     * Path to custom index.html file.
     */
    ?indexPath: String
  };

  /**
   * Export path. Default is 'export'.
   */
  var ?outDir: String;

  /**
   * Sprite atlas config.
   */
  var ?atlases: Array<AtlasConfig>;
}
