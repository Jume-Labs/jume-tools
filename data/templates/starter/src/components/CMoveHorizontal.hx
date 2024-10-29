package components;

import jume.ecs.Component;
import jume.ecs.Updatable;
import jume.ecs.components.CTransform;

enum abstract Direction(Int) to Int {
  var LEFT = -1;
  var RIGHT = 1;
}

typedef CMoveHorizontalOptions = {
  var leftEdge: Float;
  var rightEdge: Float;
  var speed: Float;
  var direction: Direction;
}

class CMoveHorizontal extends Component implements Updatable {
  var leftEdge: Float;

  var rightEdge: Float;

  var speed: Float;

  var direction: Direction;

  var transform: CTransform;

  public function init(options: CMoveHorizontalOptions): CMoveHorizontal {
    leftEdge = options.leftEdge;
    rightEdge = options.rightEdge;
    speed = options.speed;
    direction = options.direction;

    transform = getComponent(CTransform);
    transform.scale.x = -direction;

    return this;
  }

  public function cUpdate(dt: Float) {
    var x = transform.position.x;
    x += speed * direction * dt;

    if (x >= rightEdge) {
      x = rightEdge;
      direction = LEFT;
    } else if (x <= leftEdge) {
      x = leftEdge;
      direction = RIGHT;
    }

    transform.position.x = x;
    transform.scale.x = -direction;
  }
}
