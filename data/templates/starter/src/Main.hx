package;

import jume.Jume;

import scenes.GameScene;

class Main {
  public static function main() {
    final jume = new Jume({ title: 'Jume Game' });
    jume.launch(GameScene);
  }
}
