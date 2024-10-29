package scenes;

import jume.assets.Assets;
import jume.assets.TilesetLoader.LoadTilesetOptions;
import jume.ecs.Scene;
import jume.events.SceneEvent;
import jume.graphics.atlas.Atlas;
import jume.graphics.bitmapFont.BitmapFont;
import jume.tilemap.Tileset;

class LoadScene extends Scene {
  @:inject
  var assets: Assets;

  public override function init() {
    final tilesetOptions: LoadTilesetOptions = {
      tileWidth: 21,
      tileHeight: 21,
      margin: 1,
      spacing: 2
    };

    final assetList: Array<AssetItem> = [
      {
        type: Tileset,
        id: 'tiles',
        path: 'assets/tiles.png',
        options: tilesetOptions
      },
      { type: Atlas, id: 'sprites', path: 'assets/sprites' },
      { type: BitmapFont, id: 'kenney_pixel_36', path: 'assets/kenney_pixel_36' }
    ];

    assets.loadAll(assetList, assetsLoaded);
  }

  function assetsLoaded() {
    SceneEvent.send(SceneEvent.CHANGE, GameScene);
  }
}
