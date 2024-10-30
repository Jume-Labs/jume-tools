package components;

import jume.ecs.Component;
import jume.ecs.components.CSprite;
import jume.ecs.components.CTransform;
import jume.tweens.Easing.easeInCubic;
import jume.tweens.Easing.easeOutCubic;
import jume.tweens.Tween;
import jume.tweens.TweenSequence;
import jume.tweens.Tweens;

class CJump extends Component {
  @:inject
  var tweens: Tweens;

  var sequence: TweenSequence;

  var transform: CTransform;

  var sprite: CSprite;

  var canJump: Bool;

  public function init(): CJump {
    transform = getComponent(CTransform);
    sprite = getComponent(CSprite);
    canJump = true;

    final downY = transform.position.y;
    final upY = transform.position.y - 70;

    var upTween = new Tween({
      target: transform.position,
      duration: 0.4,
      from: { y: downY },
      to: {
        y: upY
      }
    }).setEase(easeOutCubic).setOnComplete(upComplete);

    var downTween = new Tween({
      target: transform.position,
      duration: 0.4,
      from: { y: upY },
      to: {
        y: downY
      }
    }).setEase(easeInCubic).setOnComplete(downComplete);

    sequence = new TweenSequence([upTween, downTween]);

    return this;
  }

  public function jump() {
    if (!canJump) {
      return;
    }

    canJump = false;
    sprite.setFrame('player_jump');
    sequence.restart();
    tweens.addSequence(sequence);
  }

  function upComplete() {
    sprite.setFrame('player_fall');
  }

  function downComplete() {
    sprite.setFrame('player_idle');
    canJump = true;
  }
}
