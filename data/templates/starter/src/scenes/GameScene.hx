package scenes;

import entities.EBackground;
import entities.EBlob;
import entities.EJumpText;
import entities.EPlayer;
import entities.ETilemap;

import jume.assets.Assets;
import jume.ecs.Scene;
import jume.ecs.systems.SRender;
import jume.ecs.systems.SUpdate;
import jume.events.EventListener;
import jume.events.Events;
import jume.events.input.KeyboardEvent;
import jume.view.View;

class GameScene extends Scene {
  @:inject
  var assets: Assets;

  @:inject
  var events: Events;

  @:inject
  var view: View;

  var keyListener: EventListener;

  var player: EPlayer;

  public override function init() {
    addSystem(SUpdate).init();
    addSystem(SRender).init();

    addEntity(EBackground).init();
    addEntity(ETilemap).init();

    player = addEntity(EPlayer).init({ x: 90, y: 252 });

    addEntity(EBlob).init({
      x: 300,
      y: 179,
      leftEdge: 259,
      rightEdge: 350
    });

    addEntity(EJumpText).init();

    keyListener = events.addListener({ type: KeyboardEvent.KEY_DOWN, callback: keyDown });
  }

  public override function destroy() {
    events.removeListener(keyListener);
  }

  function keyDown(event: KeyboardEvent) {
    if (event.key == SPACE) {
      player.jump();
    }
  }
}
