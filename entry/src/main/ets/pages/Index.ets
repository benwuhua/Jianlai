import { GameEngine } from '../game/GameEngine';

@Entry
@Component
struct Index {
  @State private canvasContext: CanvasRenderingContext2D | null = null;
  private gameEngine: GameEngine | null = null;

  build() {
    RelativeContainer() {
      Canvas(this.canvasContext)
        .id('GameCanvas')
        .width('100%')
        .height('100%')
        .onReady(() => {
          // Canvas准备好后，创建游戏引擎
          if (this.canvasContext) {
            this.gameEngine = new GameEngine(this.canvasContext);
            this.gameEngine.start();
          }
        })
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          right: { anchor: '__container__', align: HorizontalAlign.End }
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }

  // 初始化Canvas上下文
  aboutToAppear() {
    this.canvasContext = new CanvasRenderingContext2D();
  }

  // 清理资源
  aboutToDisappear() {
    if (this.gameEngine) {
      this.gameEngine.stop();
    }
  }
}