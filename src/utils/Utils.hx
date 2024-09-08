package utils;

import haxe.Json;
import haxe.io.Path;

import haxetoml.TomlParser;

import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

using StringTools;

/**
 * Get the path to the config. Will also check for the '--config' flag to load a config file from a user defined path.
 * @param workingDir The current working directory.
 * @param args The command line arguments.
 * @return The path to the config.
 */
function getConfigPath(workingDir: String, args: Array<String>): String {
  var configPath = Path.join([workingDir, 'jume.toml']);
  if (args.contains('--config')) {
    final index = args.indexOf('--config');
    if (args.length > index + 1) {
      final path = args[index + 1];
      configPath = Path.join([workingDir, path]);
    }
  }

  return configPath;
}

/**
 * Read the toml config file.
 * @param path The path to the config.
 * @return The Config or null if the file is not found.
 */
function readConfig(path: String): Config {
  if (FileSystem.exists(path)) {
    final content = File.getContent(path);
    final config: Config = TomlParser.parseString(content, {});

    return config;
  }

  Sys.println('No config file found at ${path}.');
  Sys.exit(1);

  return null;
}

/**
 * Recursive copy a directory.
 * @param source
 * @param destination
 */
function copyDir(source: String, destination: String) {
  final files = FileSystem.readDirectory(source);
  for (file in files) {
    final sourcePath = Path.join([source, file]);
    final destinationPath = Path.join([destination, file]);
    if (FileSystem.isDirectory(sourcePath)) {
      FileSystem.createDirectory(destinationPath);
      copyDir(sourcePath, destinationPath);
    } else {
      File.copy(sourcePath, destinationPath);
    }
  }
}

/**
 * Recursive delete a directory.
 * @param dir
 */
function deleteDir(dir: String) {
  final files = FileSystem.readDirectory(dir);
  for (file in files) {
    final filePath = Path.join([dir, file]);
    if (FileSystem.isDirectory(filePath)) {
      deleteDir(filePath);
    } else {
      FileSystem.deleteFile(filePath);
    }
  }
  FileSystem.deleteDirectory(dir);
}

/**
 * Find the location of a haxelib library.
 * @param name The library to find.
 * @return The location path.
 */
function getHaxelibPath(name: String): String {
  final proc = new Process('haxelib', ['path', name]);
  var result = '';

  try {
    var previous = '';
    while (true) {
      final line = proc.stdout.readLine();
      if (line.startsWith('-D $name')) {
        result = previous;
        break;
      }
      previous = line;
    }
  } catch (e:Dynamic) {}

  proc.close();

  return result;
}

/**
 * Get the haxelib version.
 * @return String
 */
function getVersion(): String {
  try {
    final libPath = getHaxelibPath('jume');
    final haxelib = Path.join([libPath, '../haxelib.json']);
    final json = Json.parse(File.getContent(haxelib));

    return json.version;
  } catch (err) {
    return '0.0.0';
  }
}
