package;

import haxe.Timer;

import utils.Commands.build;
import utils.Commands.buildHelp;
import utils.Commands.cleanOutputDir;
import utils.Commands.copyAssets;
import utils.Commands.copyShaders;
import utils.Commands.createProject;
import utils.Commands.generateAtlas;
import utils.Commands.generateHxml;
import utils.Commands.getOutputFolder;
import utils.Commands.help;
import utils.Commands.setupAlias;
import utils.Utils.getConfigPath;
import utils.Utils.getVersion;
import utils.Utils.readConfig;

class Run {
  public static function main() {
    final args = Sys.args();
    final workingDir = args.pop();
    Sys.setCwd(workingDir);
    handleFlags(workingDir, args);
  }

  static function handleFlags(workingDir: String, args: Array<String>) {
    if (args.length == 2 && args[0] == 'create') {
      final projectPath = createProject(workingDir, args[1]);
      if (projectPath != null) {
        Sys.setCwd(projectPath);
        final configPath = getConfigPath(projectPath, args);
        final config = readConfig(configPath);
        build(config, {
          clean: false,
          debug: true,
          noHxml: false,
          noShaders: false,
          noAssets: false,
          noAtlas: false
        }, Timer.stamp());
      }
      Sys.exit(0);
    } else if (args.length >= 1 && args[0] == 'build') {
      args.shift();

      if (args.contains('--help')) {
        buildHelp();
        Sys.exit(0);
      }

      Sys.println('Exporting Jume project...');
      final configPath = getConfigPath(workingDir, args);
      final config = readConfig(configPath);

      final clean = args.contains('--clean');
      final debug = args.contains('--debug') || config.debug;

      final codeOnly = args.contains('--code-only');
      final noAtlas = args.contains('--no-atlas') || codeOnly;
      final noAssets = args.contains('--no-assets') || codeOnly;
      final noShaders = args.contains('--no-shaders') || codeOnly;
      final noHxml = args.contains('--no-hxml') || codeOnly;

      build(config, {
        clean: clean,
        debug: debug,
        noAtlas: noAtlas,
        noAssets: noAssets,
        noHxml: noHxml,
        noShaders: noShaders
      }, Timer.stamp());

      Sys.exit(0);
    } else if (args.length == 2 && args[0] == 'atlas') {
      generateAtlas(args[1]);
      Sys.exit(0);
    } else if (args.length == 1) {
      switch (args[0]) {
        case 'help':
          help();
          Sys.exit(0);

        case 'setup':
          setupAlias();
          Sys.exit(0);

        case 'alias':
          setupAlias();
          Sys.exit(0);

        case 'atlas':
          generateAtlas();
          Sys.exit(0);

        case 'assets':
          generateAtlas();
          final configPath = getConfigPath(workingDir, args);
          final config = readConfig(configPath);
          final outputFolder = getOutputFolder(config);
          copyAssets(config, outputFolder);
          Sys.exit(0);

        case 'hxml':
          final configPath = getConfigPath(workingDir, args);
          final config = readConfig(configPath);
          final outputFolder = getOutputFolder(config);
          generateHxml(config, outputFolder);
          Sys.exit(0);

        case 'clean':
          final configPath = getConfigPath(workingDir, args);
          final config = readConfig(configPath);
          cleanOutputDir(config);
          Sys.exit(0);

        case 'shaders':
          final configPath = getConfigPath(workingDir, args);
          final config = readConfig(configPath);
          final outputFolder = getOutputFolder(config);
          copyShaders(config, outputFolder);
          Sys.exit(0);
      }
    }

    Sys.println('Jume CLI.');
    Sys.println('version ${getVersion()}.');
    Sys.println('Use \'jume help\' for a list of commands.');
    Sys.exit(0);
  }
}
