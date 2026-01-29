import { GameEngine } from '../game/GameEngine';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { KeyType } from '@kit.ArkUI';

const DOMAIN = 0x0000;
const TAG = 'Index';

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
          try {
            // Canvas准备好后，创建游戏引擎
            if (this.canvasContext) {
              hilog.info(DOMAIN, TAG, 'Canvas initialized successfully');
              this.gameEngine = new GameEngine(this.canvasContext);
              this.gameEngine.start();
            } else {
              hilog.error(DOMAIN, TAG, 'Canvas context is null');
            }
          } catch (error) {
            hilog.error(DOMAIN, TAG, 'Failed to initialize game engine: %{public}s', JSON.stringify(error));
          }
        })
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          right: { anchor: '__container__', align: HorizontalAlign.End }
        })
        .onKeyEvent((event) => {
          // 处理键盘事件
          if (this.gameEngine) {
            if (event.type === KeyType.Down) {
              this.gameEngine.handleKeyDown(event.keyCode);
            } else if (event.type === KeyType.Up) {
              this.gameEngine.handleKeyUp(event.keyCode);
            }
          }
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