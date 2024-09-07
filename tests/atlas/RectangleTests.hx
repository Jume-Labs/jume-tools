package atlas;

import utest.Assert;
import utest.Test;

class RectangleTests extends Test {
  function testConstructRectangle() {
    final rect = new Rectangle(10, 20, 30, 40);

    Assert.equals(10, rect.x);
    Assert.equals(20, rect.y);
    Assert.equals(30, rect.width);
    Assert.equals(40, rect.height);
  }

  function testClone() {
    final rect = new Rectangle(1, 2, 3, 4);
    final clone = rect.clone();

    Assert.notEquals(clone, rect);

    Assert.equals(1, rect.x);
    Assert.equals(2, rect.y);
    Assert.equals(3, rect.width);
    Assert.equals(4, rect.height);

    Assert.equals(1, rect.x);
    Assert.equals(2, rect.y);
    Assert.equals(3, rect.width);
    Assert.equals(4, rect.height);
  }

  function testArea() {
    final rect = new Rectangle(0, 0, 50, 30);

    Assert.equals(1500, rect.area());
  }
}
