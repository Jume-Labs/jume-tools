package;

import jume.Jume;

import scenes.LoadScene;

class Main {
  public static function main() {
    final jume = new Jume({
      title: 'Jume Game',
      designSize: { width: 399, height: 294 },
      canvasSize: {
        width: 798,
        height: 588
      },
      pixelFilter: true
    });
    jume.launch(LoadScene);
  }
}
