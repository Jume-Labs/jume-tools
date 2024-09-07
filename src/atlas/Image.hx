package atlas;

import haxe.io.Bytes;

import sys.io.File;

/**
 * This class holds image data and can manipulate it.
 */
class Image {
  /**
   * The width of the image in pixels.
   */
  public var width(default, null): Int;

  /**
   * The height of the image in pixels.
   */
  public var height(default, null): Int;

  /**
   * Should the empty border sprites be removed.
   */
  public var trimmed(default, null): Bool;

  /**
   * The amount of pixels the borders should be extruded by.
   */
  public var extrude(default, null): Int;

  /**
   * Trimmed x offset in pixels.
   */
  public var sourceX(default, null): Int = 0;

  /**
   * Trimmed y offset in pixels.
   */
  public var sourceY(default, null): Int = 0;

  /**
   * The original image width before trimming and extruding in pixels.
   */
  public var sourceWidth(default, null): Int;

  /**
   * The original image height before trimming and extruding in pixels.
   */
  public var sourceHeight(default, null): Int;

  /**
   * The image data.
   */
  var data: Bytes;

  /**
   * The amount of bytes per pixel.
   */
  final stride = 4;

  /**
   * Create an image from a file.
   * @param path The file path.
   * @param trim Trim or not.
   * @param extrude Amount to be extruded.
   * @return The created image.
   */
  public static function fromFile(path: String, trim: Bool, extrude: Int): Image {
    var file = File.read(path);
    var data = new format.png.Reader(file).read();
    var pixelData = format.png.Tools.extract32(data);
    format.png.Tools.reverseBytes(pixelData);
    var header = format.png.Tools.getHeader(data);

    return new Image({
      width: header.width,
      height: header.height
    }, pixelData, trim, extrude);
  }

  /**
   * Create a new Image instance.
   * @param size The width and height of the image in pixels.
   * @param data Optional image data. 
   * @param trim If true remove transparent borders.
   * @param extrude The amount of pixels to extrude from the edges.
   */
  public function new(size: Size, ?data: Bytes, trim = false, extrude = 0) {
    width = size.width;
    height = size.height;
    sourceWidth = width;
    sourceHeight = height;
    trimmed = trim;
    this.extrude = extrude;

    this.data = Bytes.alloc(width * height * stride);
    if (data == null) {
      this.data.fill(0, width * height * stride, 0);
    } else {
      this.data.blit(0, data, 0, data.length);
      if (trimmed) {
        trimTransparentPixels();
      }

      if (extrude > 0) {
        extrudeEdges(extrude);
      }
    }
  }

  /**
   * Insert an image into this image.
   * @param image The image to insert.
   * @param xPos The x position to insert in pixels.
   * @param yPos The y position to insert in pixels.
   */
  public function insertImage(image: Image, xPos: Int, yPos: Int) {
    // Copy the image pixel by pixel.
    for (y in 0...image.height) {
      for (x in 0...image.width) {
        setPixel(xPos + x, yPos + y, image.getPixel(x, y));
      }
    }
  }

  /**
   * Return the image pixels in bytes.
   */
  public function getPixels(): Bytes {
    return data;
  }

  /**
   * Get the color of a pixel.
   * @param x The x position in pixels.
   * @param y The y position in pixels.
   * @return The pixel color.
   */
  public function getPixel(x: Int, y: Int): Color {
    var start = (y * width + x) * stride;

    return return new Color(data.get(start), data.get(start + 1), data.get(start + 2), data.get(start + 3));
  }

  /**
   * Set a pixel in this image.
   * @param x The x position in pixels.
   * @param y The y position in pixels.
   * @param color The color to set.
   */
  public function setPixel(x: Int, y: Int, color: Color) {
    var start = (y * width + x) * stride;
    data.set(start, color.a);
    data.set(start + 1, color.r);
    data.set(start + 2, color.g);
    data.set(start + 3, color.b);
  }

  /**
   * Extrude the edges of the image.
   * @param amount The amount of pixels to extrude out.
   */
  function extrudeEdges(amount: Int) {
    var original = new Image({ width: width, height: height }, data);

    // Total width and height adjusted by the amount to extrude on both sides.
    width += amount * 2;
    height += amount * 2;

    var size = width * height * stride;
    data = Bytes.alloc(size);
    data.fill(0, stride, 0);
    insertImage(original, amount, amount);
    var color: Color;
    for (y in amount...original.height + amount) {
      // Extrude the left.
      color = getPixel(amount, y);
      for (x in 0...amount) {
        setPixel(x, y, color);
      }

      // Extrude the right.
      color = getPixel(width - amount - 1, y);
      for (x in width - amount - 1...width) {
        setPixel(x, y, color);
      }
    }

    for (x in amount...original.width + amount) {
      // Extrude the top.
      color = getPixel(x, amount);
      for (y in 0...amount) {
        setPixel(x, y, color);
      }

      // Extrude the bottom.
      color = getPixel(x, height - amount - 1);
      for (y in height - amount - 1...height) {
        setPixel(x, y, color);
      }
    }
  }

  /**
   * Remove transparent borders to make the image smaller in the atlas.
   * Moves in from each side until a non transparent pixel is found.
   */
  function trimTransparentPixels() {
    var temp = new Image({ width: width, height: height }, data);

    var leftOffset = 0;
    var rightOffset = 0;
    var topOffset = 0;
    var bottomOffset = 0;

    // From the left side in.
    for (x in 0...width) {
      if (!isColumnEmpty(temp, x)) {
        break;
      }
      leftOffset++;
    }

    // From the right side in.
    var x = width - 1;
    while (x >= 0) {
      if (!isColumnEmpty(temp, x)) {
        break;
      }
      rightOffset++;
      x--;
    }

    // From the top in.
    for (y in 0...height) {
      if (!isRowEmpty(temp, y)) {
        break;
      }
      topOffset++;
    }

    // From the bottom in.
    var y = height - 1;
    while (y >= 0) {
      if (!isRowEmpty(temp, y)) {
        break;
      }
      bottomOffset++;
      y--;
    }

    width = temp.width - leftOffset - rightOffset;
    height = temp.height - topOffset - bottomOffset;

    // allocate the image data with the new size.
    data = Bytes.alloc(width * height * stride);
    var pos = 0;
    var color: Color;

    // Update the bytes with the trimmed sprite.
    for (y in topOffset...topOffset + height) {
      for (x in leftOffset...leftOffset + width) {
        color = temp.getPixel(x, y);
        data.set(pos, color.a);
        data.set(pos + 1, color.r);
        data.set(pos + 2, color.g);
        data.set(pos + 3, color.b);
        pos += stride;
      }
    }
    sourceX = leftOffset;
    sourceY = topOffset;
  }

  /**
   * Check if a column of pixels in an image is empty.
   * @param image The image to check.
   * @param column The column index to check.
   * @return True if the column only contains transparent pixels.
   */
  function isColumnEmpty(image: Image, column: Int): Bool {
    for (y in 0...image.height) {
      if (image.getPixel(column, y).a != 0) {
        return false;
      }
    }

    return true;
  }

  /**
   * Check if a row of pixels in an image is empty.
   * @param image The image to check.
   * @param row The row index to check.
   * @return True if the row only contains transparent pixels.
   */
  function isRowEmpty(image: Image, row: Int): Bool {
    for (x in 0...image.width) {
      if (image.getPixel(x, row).a != 0) {
        return false;
      }
    }

    return true;
  }
}
