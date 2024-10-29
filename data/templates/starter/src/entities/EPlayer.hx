package entities;

import components.CJump;

import jume.assets.Assets;
import jume.ecs.Entity;
import jume.ecs.components.CSprite;
import jume.ecs.components.CTransform;
import jume.graphics.atlas.Atlas;

typedef EPlayerOptions = {
  var x: Float;
  var y: Float;
}

class EPlayer extends Entity {
  @:inject
  var assets: Assets;

  var jumpComp: CJump;

  public function init(options: EPlayerOptions): EPlayer {
    addComponent(CTransform).init({ x: options.x, y: options.y });

    final atlas = assets.get(Atlas, 'sprites');
    addComponent(CSprite).init({ atlas: atlas, frameName: 'player_idle', anchor: { x: 0, y: 0 } });

    jumpComp = addComponent(CJump).init();

    return this;
  }

  public function jump() {
    jumpComp.jump();
  }
}
