package scenes;

import jume.graphics.Color;

import entities.EBox;

import jume.view.View;
import jume.ecs.systems.SRender;
import jume.ecs.systems.SUpdate;
import jume.ecs.Scene;

class GameScene extends Scene {
  @:inject
  var view: View;

  public override function init() {
    addSystem(SUpdate).init();
    addSystem(SRender).init();

    addEntity(EBox).init(view.viewCenterX, view.viewCenterY, 100, Color.ORANGE);
  }
}
