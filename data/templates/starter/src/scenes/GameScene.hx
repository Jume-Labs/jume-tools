package scenes;

import systems.SInput;

import entities.EBackground;
import entities.EBlob;
import entities.EJumpText;
import entities.EPlayer;
import entities.ETilemap;

import jume.ecs.Scene;
import jume.ecs.systems.SRender;
import jume.ecs.systems.SUpdate;

class GameScene extends Scene {
  public override function init() {
    addSystem(SUpdate).init();
    addSystem(SRender).init();
    addSystem(SInput).init();

    addEntity(EBackground).init();
    addEntity(ETilemap).init();

    addEntity(EPlayer).init({ x: 90, y: 253 });

    addEntity(EBlob).init({
      x: 300,
      y: 184,
      leftEdge: 248,
      rightEdge: 352
    });

    addEntity(EJumpText).init();
  }
}
