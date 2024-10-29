package entities;

import jume.assets.Assets;
import jume.ecs.Entity;
import jume.ecs.components.CText;
import jume.ecs.components.CTransform;
import jume.graphics.bitmapFont.BitmapFont;
import jume.view.View;

class EJumpText extends Entity {
  @:inject
  var assets: Assets;

  @:inject
  var view: View;

  public function init(): EJumpText {
    addComponent(CTransform).init({ x: view.viewCenterX, y: 80 });

    final font = assets.get(BitmapFont, 'kenney_pixel_36');
    addComponent(CText).init({ font: font, text: 'Press Space to Jump' });

    return this;
  }
}
