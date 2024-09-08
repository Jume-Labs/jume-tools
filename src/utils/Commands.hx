package utils;

import atlas.Atlas;

import haxe.Timer;
import haxe.io.Path;

import shaders.Transpiler.ShaderExtension;
import shaders.Transpiler.transpileShader;

import sys.FileSystem;
import sys.io.File;

import utils.Utils.copyDir;
import utils.Utils.deleteDir;
import utils.Utils.getHaxelibPath;

using StringTools;

typedef BuildOptions = {
  var clean: Bool;
  var debug: Bool;
  var noAtlas: Bool;
  var noAssets: Bool;
  var noShaders: Bool;
  var noHxml: Bool;
}

/**
 * Build the project.
 * @param config 
 * @param options
 * @param buildStart
 */
function build(config: Config, options: BuildOptions, buildStart: Float) {
  config.debug = options.debug;

  if (options.clean) {
    cleanOutputDir(config);
  }

  final outputFolder = getOutputFolder(config);

  if (!FileSystem.exists(outputFolder)) {
    FileSystem.createDirectory(outputFolder);
  }

  if (!options.noAtlas && !options.noAssets) {
    generateAtlas();
  }

  if (!options.noAssets) {
    copyAssets(config, outputFolder);
    copyTemplate(config, outputFolder);
  }

  if (!options.noShaders) {
    copyShaders(config, outputFolder);
  }

  if (!options.noHxml) {
    generateHxml(config, outputFolder);
  }

  Sys.println('Compiling haxe...');
  runCommand('hxml', 'haxe', ['html5.hxml']);

  final buildTime = Timer.stamp() - buildStart;
  Sys.println('Export completed in ${Math.floor(buildTime * 100) / 100.0} seconds.');
}

/**
 * Copy the assets to the output folder.
 * @param config 
 * @param outputFolder 
 */
function copyAssets(config: Config, outputFolder: String) {
  final folder = getAssetsFolder(config);
  if (FileSystem.exists(folder)) {
    final output = Path.join([outputFolder, folder]);
    if (!FileSystem.exists(output)) {
      FileSystem.createDirectory(output);
    }
    copyDir(folder, output);
    Sys.println('Copying asset folder...');
  } else {
    Sys.println('Asset folder ${folder} not found.');
  }
}

/**
 * Generate a sprite atlas from the jume.toml config.
 * @param outPath The path to store the atlas in.
 */
function generateAtlas(?path: String) {
  if (path == null) {
    path = Path.join([Sys.getCwd(), 'jume.toml']);
  }

  if (FileSystem.exists(path)) {
    Atlas.fromToml(path);
  } else {
    Sys.println('No jume.toml file found. Cannot generate atlas.');
  }
}

/**
 * Copy and transpile the shaders.
 * @param config 
 * @param outputFolder 
 */
function copyShaders(config: Config, outputFolder: String) {
  Sys.println('Copying shaders...');

  final shaderFolders = [];
  if (config.shaderFolder != null) {
    shaderFolders.push(config.shaderFolder);
  }

  if (shaderFolders.length == 0) {
    return;
  }

  outputFolder = Path.join([outputFolder, 'shaders']);
  FileSystem.createDirectory(outputFolder);

  for (folder in shaderFolders) {
    final shaderFiles = FileSystem.readDirectory(folder);
    for (shader in shaderFiles) {
      final extension = Path.extension(shader);
      if (extension == ShaderExtension.VERTEX || extension == ShaderExtension.FRAGMENT) {
        final content = File.getContent(Path.join([folder, shader]));
        File.saveContent(Path.join([outputFolder, shader]), content);

        // Convert the WebGL2 shader to WebGL1 for older browsers.
        final gl1 = transpileShader(content, extension);
        final gl1Name = '${Path.withoutExtension(shader)}.gl1.${extension}';
        File.saveContent(Path.join([outputFolder, gl1Name]), gl1);
      }
    }
  }
}

/**
 * Clean the output directory.
 * @param config 
 */
function cleanOutputDir(config: Config) {
  var dir = 'export';
  if (config.outDir != null) {
    dir = config.outDir;
  }

  Sys.println('Cleaning export folder...');
  deleteDir(dir);
}

/**
 * Create a new Jume project from the starter template.
 * @param path 
 * @param name 
 * @return String
 */
function createProject(path: String, name: String): String {
  final projectFolder = Path.join([path, name]);

  Sys.println('Creating new project at ${projectFolder}');

  if (FileSystem.exists(projectFolder)) {
    Sys.println('folder ${projectFolder} already exists');
    return null;
  }

  final jumePath = getHaxelibPath('jume-tools');

  final templatePath = Path.join([jumePath, '../tools/data/templates/starter']);
  FileSystem.createDirectory(projectFolder);

  // Copy the template files.
  copyDir(templatePath, projectFolder);

  // Create empty 'assets' folder.
  final assetsPath = Path.join([projectFolder, 'assets']);
  FileSystem.createDirectory(assetsPath);

  return projectFolder;
}

function help() {
  Sys.println('');
  Sys.println('The following commands are available:');
  Sys.println('jume setup                  Install the \'jume\' command line command.');
  Sys.println('jume create [project_name]  Create a starter project in the current directory.');
  Sys.println('jume build [options]        Build the project. Use \'jume build --help\' to see the options.');
  Sys.println('jume atlas [config]         Generate just the sprite atlas. Can take an optional config file.');
  Sys.println('jume assets                 Generate the sprite atlas and copy the assets to the output folder.');
  Sys.println('jume hxml                   Update the haxe hxml files. This is also done during build.');
  Sys.println('jume clean                  Clean the output folder.');
  Sys.println('jume shaders                Copy the shaders to the output folder. This is also done during build.');
  Sys.println('jume help                   Show this list.');
}

function buildHelp() {
  Sys.println('');
  Sys.println('The following build options are available:');
  Sys.println('--debug       Create a debug build. Can also be set in the config file');
  Sys.println('--clean       Clean the output folder.');
  Sys.println('--no-atlas    Skip generating sprite atlases.');
  Sys.println('--no-assets   Skip copying the assets.');
  Sys.println('--no-shaders  Skip shader transpilation and copying.');
  Sys.println('--no-hxml     Skip hxml file generation.');
  Sys.println('--code-only   Only compile the haxe code.');
}

/**
 * Install the 'jume' command.
 * @return Bool
 */
function setupAlias(): Bool {
  while (true) {
    Sys.println('');
    Sys.println('Do you want to install the "jume" command? [y/n]?');

    switch (Sys.stdin().readLine()) {
      case 'n', 'No':
        return false;
      case 'y', 'Yes':
        break;

      default:
    }
  }

  final platform = Sys.systemName();
  final binPath = platform == 'Mac' ? '/usr/local/bin' : '/usr/bin';

  if (platform == 'Windows') {
    var haxePath = Sys.getEnv('HAXEPATH');
    if (haxePath == null || haxePath == '') {
      haxePath = 'C:\\HaxeToolkit\\haxe\\';
    }

    final destination = Path.join([haxePath, 'jume.bat']);
    final source = Path.join([getHaxelibPath('jume-tools'), '../data/bin/jume.bat']);

    if (FileSystem.exists(source)) {
      File.copy(source, destination);
    } else {
      throw 'Could not find the aeons alias script.';
    }
  } else {
    final source = Path.join([getHaxelibPath('jume-tools'), '../data/bin/jume.sh']);
    if (FileSystem.exists(source)) {
      Sys.command('sudo', ['cp', source, binPath + '/jume']);
      Sys.command('sudo', ['chmod', '+x', binPath + '/jume']);
    } else {
      throw 'Could not find the jume alias script.';
    }
  }
  Sys.println('The "jume" command has been added to path.');

  return true;
}

/**
 * Generate the haxe build file from je config file.
 * @param config 
 * @param outputFolder 
 */
function generateHxml(config: Config, outputFolder: String) {
  Sys.println('Generating hxml config...');

  var fileData = '';
  var foundJume = false;
  if (config.libraries != null) {
    for (lib in config.libraries) {
      if (lib.name == 'jume') {
        foundJume = true;
      }

      if (lib.version != null) {
        fileData += '--library ${lib.name}:${lib.version}\n';
      } else {
        fileData += '--library ${lib}\n';
      }
    }
  }

  if (!foundJume) {
    fileData = '--library jume\n' + fileData;
  }

  if (config.sourceFolders == null) {
    config.sourceFolders = ['src'];
  }

  for (folder in config.sourceFolders) {
    final path = Path.join([Sys.getCwd(), folder]);
    if (FileSystem.exists(path)) {
      fileData += '-cp ${path}\n';
    } else {
      Sys.println('Path ${path} not found. Not adding it to hxml.');
    }
  }
  fileData += '\n';

  if (config.defines != null) {
    for (define in config.defines) {
      fileData += '-D ${define}\n';
    }
    fileData += '\n';
  }

  if (config.parameters != null) {
    for (parameter in config.parameters) {
      fileData += '${parameter}\n';
    }
    fileData += '\n';
  }

  if (config.debug) {
    fileData += '--debug\n';
    fileData += '\n';
  }

  var scriptName = 'jume.js';
  if (config.html5 != null) {
    if (config.html5.scriptName != null) {
      scriptName = config.html5.scriptName;
    }
  }
  fileData += '-js ${Path.join([Sys.getCwd(), outputFolder, scriptName])}\n';
  fileData += '\n';

  final mainClass = config.main != null ? config.main : 'Main';
  fileData += '-main ${mainClass}\n';

  final hxmlPath = 'hxml';
  if (!FileSystem.exists(hxmlPath)) {
    FileSystem.createDirectory(hxmlPath);
  }
  File.saveContent(Path.join([hxmlPath, 'html5.hxml']), fileData);
}

/**
 * Copy the starter template and fill the placeholders.
 * @param config 
 * @param outFolder 
 */
function copyTemplate(config: Config, outFolder: String) {
  Sys.println('Copying export template...');

  var templatePath: String;
  if (config.html5 != null && config.html5.indexPath != null) {
    templatePath = config.html5.indexPath;
  } else {
    final jumePath = getHaxelibPath('jume-tools');
    templatePath = Path.join([jumePath, '../data/html/index.html']);
  }
  var template = File.getContent(templatePath);

  final scriptName = config.html5 != null && config.html5.scriptName != null ? config.html5.scriptName : 'jume.js';
  template = setPlaceholder(template, 'script_name', scriptName);

  File.saveContent(Path.join([outFolder, 'index.html']), template);
}

/**
 * Get the output folder.
 * @param config 
 * @return String
 */
function getOutputFolder(config: Config): String {
  // Default export location.
  var output = 'export';

  // Custom export location.
  if (config.outDir != null) {
    output = config.outDir;
  }

  return output;
}

/**
 * Update a placeholder in a template.
 * @param content 
 * @param placeholder 
 * @param replacement 
 * @return String
 */
private function setPlaceholder(content: String, placeholder: String, replacement: String): String {
  return content.replace('{{ ${placeholder} }}', replacement);
}

/**
 * Get the assets folder location.
 * @param config 
 * @return String
 */
private function getAssetsFolder(config: Config): String {
  var assetFolder = 'assets';

  if (config.assetsFolder != null) {
    assetFolder = config.assetsFolder;
  }

  return assetFolder;
}

/**
 * Run a Sys command and restore the working directory after.
 * @param path The path to run the command in.
 * @param command The command to run.
 * @param args A list of command parameters.
 * @param throwErrors Show this throw errors.
 * @return The command status. 0 is success.
 */
private function runCommand(path: String, command: String, args: Array<String>, throwErrors = true): Int {
  var currentPath = '';
  if (path != null && path != '') {
    currentPath = Sys.getCwd();

    try {
      Sys.setCwd(path);
    } catch (e:Dynamic) {
      Sys.println('Cannot set current working directory to ${path}.');
    }
  }

  var result = Sys.command(command, args);
  if (currentPath != '') {
    Sys.setCwd(currentPath);
  }

  if (result != 0 && throwErrors) {
    Sys.exit(1);
  }

  return result;
}
