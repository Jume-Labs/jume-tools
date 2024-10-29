package entities;

import components.CMoveHorizontal;

import jume.assets.Assets;
import jume.ecs.Entity;
import jume.ecs.components.CAnimation;
import jume.ecs.components.CSprite;
import jume.ecs.components.CTransform;
import jume.graphics.animation.Animation;
import jume.graphics.atlas.Atlas;

typedef EBlobOptions = {
  var x: Float;
  var y: Float;
  var leftEdge: Float;
  var rightEdge: Float;
}

class EBlob extends Entity {
  @:inject
  var assets: Assets;

  public function init(options: EBlobOptions): EBlob {
    addComponent(CTransform).init({ x: options.x, y: options.y });

    final atlas = assets.get(Atlas, 'sprites');
    addComponent(CSprite).init({ atlas: atlas, frameName: 'blob_00' });

    final anim = new Animation('walk', atlas, ['blob_00', 'blob_01', 'blob_00', 'blob_02'], 0.15, LOOP);

    final animComponent = addComponent(CAnimation).init([anim]);
    animComponent.play('walk');

    addComponent(CMoveHorizontal).init({
      leftEdge: options.leftEdge,
      rightEdge: options.rightEdge,
      direction: RIGHT,
      speed: 20
    });

    return this;
  }
}
