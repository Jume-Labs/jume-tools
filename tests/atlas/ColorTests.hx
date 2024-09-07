package atlas;

import utest.Assert;
import utest.Test;

class ColorTests extends Test {
  function testConstructColor() {
    final color = new Color(255, 40, 60, 80);

    Assert.equals(255, color.a);
    Assert.equals(40, color.r);
    Assert.equals(60, color.g);
    Assert.equals(80, color.b);
  }
}
