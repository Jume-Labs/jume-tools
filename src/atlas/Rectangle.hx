package atlas;

typedef RectangleParams = {
  var x: Int;
  var y: Int;
  var width: Int;
  var height: Int;
  var ?name: String;
}

/**
 * Rectangle class.
 */
class Rectangle {
  /**
   * Filename of the image this rectangle belongs to.
   */
  public final name: String;

  /**
   * The x position of the rectangle in pixels.
   */
  public var x: Int;

  /**
   * The y position of the rectangle in pixels.
   */
  public var y: Int;

  /**
   * The width of the rectangle in pixels.
   */
  public var width: Int;

  /**
   * The height of the rectangle in pixels.
   */
  public var height: Int;

  /**
   * Constructor.
   * @param x The x position.
   * @param y The y position.
   * @param width The width.
   * @param height The height.
   * @param name Optional filename.
   */
  public function new(params: RectangleParams) {
    x = params.x;
    y = params.y;
    width = params.width;
    height = params.height;
    name = params.name ?? '';
  }

  /**
   * Clone this rectangle into a new one.
   * @return The new rectangle.
   */
  public function clone(): Rectangle {
    return new Rectangle({
      x: x,
      y: y,
      width: width,
      height: height,
      name: name
    });
  }

  /**
   * Calculate the area of this rectangle.
   * @return The area in pixels.
   */
  public function area(): Int {
    return width * height;
  }
}
