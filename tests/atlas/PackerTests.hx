package atlas;

import utest.Assert;
import utest.Test;

class PackerTests extends Test {
  var config: AtlasConfig;
  var atlas: Atlas;

  // Before each.
  function setup() {
    config = {
      name: 'test',
      saveFolder: 'tests/out',
      folders: ['tests/atlas/testFiles'],
      extrude: 0,
      trimmed: true
    };
    atlas = new Atlas(config);
  }

  function testPackBasic() {
    final packer = new Packer(atlas.rectangles, BASIC, 4096, 4096);
    final success = packer.pack();

    Assert.isTrue(success);
    Assert.equals(282, packer.smallestBounds.width);
    Assert.equals(72, packer.smallestBounds.height);
  }

  function testPackOptimal() {
    final packer = new Packer(atlas.rectangles, OPTIMAL, 4096, 4096);
    final success = packer.pack();

    Assert.isTrue(success);
    Assert.equals(126, packer.smallestBounds.width);
    Assert.equals(120, packer.smallestBounds.height);
  }

  function testPackMaxWidth() {
    final packer = new Packer(atlas.rectangles, OPTIMAL, 100, 4096);
    final success = packer.pack();

    Assert.isTrue(success);
    Assert.equals(90, packer.smallestBounds.width);
    Assert.equals(172, packer.smallestBounds.height);
  }

  function testPackMaxHeight() {
    final packer = new Packer(atlas.rectangles, OPTIMAL, 4096, 100);
    final success = packer.pack();

    Assert.isTrue(success);
    Assert.equals(234, packer.smallestBounds.width);
    Assert.equals(72, packer.smallestBounds.height);
  }

  function testPackDoesNotFit() {
    final packer = new Packer(atlas.rectangles, OPTIMAL, 90, 90);
    final success = packer.pack();

    Assert.isFalse(success);
  }
}
