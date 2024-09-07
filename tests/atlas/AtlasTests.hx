package atlas;

import utest.Assert;
import utest.Test;

using StringTools;

class AtlasTests extends Test {
  var config: AtlasConfig;

  // Before all.
  function setupClass() {
    config = {
      name: 'test',
      saveFolder: 'tests/out',
      folders: ['tests/atlas/testFiles'],
      trimmed: true,
      extrude: 1
    };
  }

  function testPackAtlas() {
    final atlas = new Atlas(config);
    final success = atlas.pack();

    Assert.isTrue(success);
    Assert.equals(132, atlas.packedImage.width);
    Assert.equals(126, atlas.packedImage.height);
  }

  function testFolderNames() {
    config.folderInName = true;

    final atlas = new Atlas(config);
    final success = atlas.pack();

    Assert.isTrue(success);
    for (rect in atlas.packedRectangles) {
      Assert.isTrue(rect.name.startsWith('testFiles_'));
    }
  }
}
