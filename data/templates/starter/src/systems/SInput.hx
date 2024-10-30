package systems;

import components.CJump;

import jume.ecs.Entity;
import jume.ecs.System;
import jume.events.EventListener;
import jume.events.Events;
import jume.events.input.KeyboardEvent;

class SInput extends System {
  final playerEntities: Array<Entity> = [];

  @:inject
  var events: Events;

  var keyListener: EventListener;

  public function init(): SInput {
    addEntityListener({ entities: playerEntities, components: [CJump] });
    keyListener = events.addListener({ type: KeyboardEvent.KEY_DOWN, callback: keyDown });

    return this;
  }

  public override function destroy() {
    events.removeListener(keyListener);
  }

  function keyDown(event: KeyboardEvent) {
    if (event.key == SPACE && playerEntities.length > 0) {
      playerEntities[0].getComponent(CJump).jump();
    }
  }
}
