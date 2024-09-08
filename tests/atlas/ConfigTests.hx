package atlas;

import atlas.AtlasConfig.AtlasList;
import atlas.AtlasConfig.setDefaultConfigValues;

import utest.Assert;
import utest.Test;

class ConfigTests extends Test {
  function testDefaultValues() {
    final config: AtlasConfig = {
      name: 'Test',
      saveFolder: 'out',
    };

    final data: AtlasList = {
      atlases: [config]
    };
    setDefaultConfigValues(data);

    Assert.equals(1, config.folders.length);
    Assert.equals(0, config.files.length);
    Assert.isTrue(config.trimmed);
    Assert.equals(1, config.extrude);
    Assert.equals(PackMethod.OPTIMAL, config.packMethod);
    Assert.isFalse(config.folderInName);
    Assert.equals(4096, config.maxWidth);
    Assert.equals(4096, config.maxHeight);
    Assert.isFalse(config.noData);
  }
}
