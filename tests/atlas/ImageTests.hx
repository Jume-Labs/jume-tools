package atlas;

import haxe.io.Bytes;

import utest.Assert;
import utest.Test;

class ImageTests extends Test {
  function testEmptyImage() {
    final imageWidth = 64;
    final imageHeight = 32;
    final image = new Image({ width: imageWidth, height: imageHeight });
    final bytes = image.getPixels();

    Assert.equals(imageWidth, image.width);
    Assert.equals(imageHeight, image.height);

    Assert.equals(imageWidth * imageHeight * 4, bytes.length);
    for (i in 0...bytes.length) {
      Assert.equals(0, bytes.get(i));
    }
  }

  function testGetAndSetPixel() {
    final color = new Color(255, 100, 80, 20);
    final transparentColor = new Color(0, 0, 0, 0);
    final image = new Image({ width: 32, height: 32 });
    final currentColor = image.getPixel(10, 10);
    Assert.isTrue(currentColor.equals(transparentColor));
    image.setPixel(10, 10, color);
    final newColor = image.getPixel(10, 10);
    Assert.isTrue(newColor.equals(color));
  }

  function testImageFromBytes() {
    final width = 32;
    final height = 32;
    // Light orange.
    final color = new Color(255, 255, 127, 50);
    final bytes = Bytes.alloc(width * height * 4);
    var pos = 0;
    // Make every pixel orange.
    for (i in 0...(width * height)) {
      bytes.set(pos, color.a);
      bytes.set(pos + 1, color.r);
      bytes.set(pos + 2, color.g);
      bytes.set(pos + 3, color.b);
      pos += 4;
    }
    final image = new Image({ width: width, height: height }, bytes);
    Assert.equals(width, image.width);
    Assert.equals(height, image.height);
    for (y in 0...height) {
      for (x in 0...width) {
        final pixel = image.getPixel(x, y);
        Assert.isTrue(pixel.equals(color));
      }
    }
  }

  function testReturnPixelsFromImage() {
    final width = 32;
    final height = 32;
    // Light orange.
    final color = new Color(255, 255, 127, 50);
    final bytes = Bytes.alloc(width * height * 4);
    var pos = 0;
    // Make every pixel orange.
    for (i in 0...(width * height)) {
      bytes.set(pos, color.a);
      bytes.set(pos + 1, color.r);
      bytes.set(pos + 2, color.g);
      bytes.set(pos + 3, color.b);
      pos += 4;
    }
    final image = new Image({
      width: width,
      height: height
    }, bytes);
    Assert.equals(width, image.width);
    Assert.equals(height, image.height);
    final pixels = image.getPixels();

    for (i in 0...bytes.length) {
      Assert.equals(pixels.get(i), bytes.get(i));
    }
  }

  function testImageFromFile() {
    final path = 'tests/atlas/testFiles/blue_box.png';
    final image = Image.fromFile(path, false, 0);
    final darkBlue = new Color(255, 68, 132, 159);
    Assert.equals(48, image.width);
    Assert.equals(46, image.height);
    var pixel = image.getPixel(6, 5);
    Assert.isTrue(pixel.equals(darkBlue));
    pixel = image.getPixel(41, 40);
    Assert.isTrue(pixel.equals(darkBlue));
  }

  function testTrimImage() {
    final path = 'tests/atlas/testFiles/purple_box.png';
    final image = Image.fromFile(path, true, 0);
    Assert.equals(48, image.width);
    Assert.equals(12, image.height);
    Assert.equals(66, image.sourceWidth);
    Assert.equals(34, image.sourceHeight);
  }

  function testExtrudeImage() {
    final path = 'tests/atlas/testFiles/purple_box.png';
    final image = Image.fromFile(path, true, 1);
    final darkPurple = new Color(255, 142, 68, 159);
    final normalPurple = new Color(255, 203, 97, 227);
    final transparent = new Color(0, 0, 0, 0);
    Assert.equals(50, image.width);
    Assert.equals(14, image.height);
    for (y in 0...image.height) {
      for (x in 0...image.width) {
        final color = image.getPixel(x, y);
        // Transparent corners when extruding 1 pixel.
        if ((x == 0 && (y == 0 || y == image.height - 1))
          || (x == image.width - 1 && (y == 0 || y == image.height - 1))) {
          Assert.isTrue(color.equals(transparent));
          // Dark borders 2 pixels wide because of the extrusion.
        } else if (x == 0 || x == 1 || x == image.width - 1 || x == image.width - 2 || y == 0 || y == 1
          || y == image.height - 1 || y == image.height - 2) {
          Assert.isTrue(color.equals(darkPurple));
          // The rest is the normal purple color.
        } else {
          Assert.isTrue(color.equals(normalPurple));
        }
      }
    }
  }

  function testInsertImage() {
    final image = new Image({ width: 40, height: 40 });
    final color = new Color(255, 200, 100, 50);
    final transparent = new Color(0, 0, 0, 0);
    for (y in 0...image.height) {
      for (x in 0...image.width) {
        final pixel = image.getPixel(x, y);
        Assert.isTrue(pixel.equals(transparent));
      }
    }
    final other = new Image({ width: 20, height: 20 });
    for (y in 0...other.height) {
      for (x in 0...other.width) {
        other.setPixel(x, y, color);
      }
    }
    image.insertImage(other, 10, 15);
    for (y in 0...image.height) {
      for (x in 0...image.width) {
        final pixel = image.getPixel(x, y);
        if (x < 10 || x >= 30 || y < 15 || y >= 35) {
          Assert.isTrue(pixel.equals(transparent));
        } else {
          Assert.isTrue(pixel.equals(color));
        }
      }
    }
  }
}
