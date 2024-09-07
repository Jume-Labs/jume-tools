package;

import atlas.AtlasTests;
import atlas.ColorTests;
import atlas.ConfigTests;
import atlas.ImageTests;
import atlas.PackerTests;
import atlas.RectangleTests;
import atlas.SaveTests;

import shaders.TranspilerTests;

import utest.Runner;
import utest.ui.Report;

class Test {
  public static function main() {
    final runner = new Runner();

    Report.create(runner);
    runner.addCase(new AtlasTests());
    runner.addCase(new ColorTests());
    runner.addCase(new ConfigTests());
    runner.addCase(new ImageTests());
    runner.addCase(new PackerTests());
    runner.addCase(new RectangleTests());
    runner.addCase(new SaveTests());

    runner.addCase(new TranspilerTests());
    runner.run();
  }
}
