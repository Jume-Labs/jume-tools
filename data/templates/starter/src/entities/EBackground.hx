package entities;

import jume.ecs.components.CSprite;
import jume.graphics.atlas.Atlas;
import jume.ecs.components.CTransform;
import jume.assets.Assets;
import jume.ecs.Entity;

class EBackground extends Entity {
  @:inject
  var assets: Assets;

  public function init(): EBackground {
    addComponent(CTransform).init();

    final atlas = assets.get(Atlas, 'sprites');
    addComponent(CSprite).init({ atlas: atlas, frameName: 'background', anchor: { x: 0, y: 0 } });

    return this;
  }
}
