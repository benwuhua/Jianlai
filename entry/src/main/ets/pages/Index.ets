import { GameEngine } from '../game/GameEngine';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { KeyType, TouchType } from '@kit.ArkUI';
import { HealthBar } from '../components/HealthBar';
import { SkillButton } from '../components/SkillButton';

const DOMAIN = 0x0000;
const TAG = 'Index';

@Entry
@Component
struct Index {
  @State private canvasContext: CanvasRenderingContext2D | null = null;
  private gameEngine: GameEngine | null = null;

  // 暴露角色状态给UI
  @State playerHp: number = 1000;
  @State playerMaxHp: number = 1000;
  @State enemyHp: number = 1000;
  @State enemyMaxHp: number = 1000;

  build() {
    Stack() {
      // 游戏Canvas层
      RelativeContainer() {
        Canvas(this.canvasContext)
          .id('GameCanvas')
          .width('100%')
          .height('100%')
          .onReady(() => {
            try {
              if (this.canvasContext) {
                hilog.info(DOMAIN, TAG, 'Canvas initialized successfully');
                this.gameEngine = new GameEngine(this.canvasContext);
                // 设置回调更新UI
                this.gameEngine.setUIUpdateCallback(this.updateUIFromGame.bind(this));
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
            right: { anchor: '__container__', align: HorizontalAlign.END }
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

      // UI层
      Column() {
        // 顶部血条
        Row() {
          HealthBar({
            name: '陈平安',
            currentHp: this.playerHp,
            maxHp: this.playerMaxHp,
            position: 'top'
          })

          Blank()

          HealthBar({
            name: '敌人',
            currentHp: this.enemyHp,
            maxHp: this.enemyMaxHp,
            position: 'top'
          })
        }
        .width('100%')

        Blank()

        // 底部控制按钮
        Row() {
          SkillButton({
            label: '攻',
            onAction: () => {
              if (this.gameEngine) {
                this.gameEngine.handleKeyDown('j');
              }
            }
          })
          .onTouch((event: TouchEvent) => {
            if (this.gameEngine) {
              if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                this.gameEngine.handleKeyUp('j');
              }
            }
          })
          .margin({ right: 20 })

          SkillButton({
            label: '跳',
            onAction: () => {
              if (this.gameEngine) {
                this.gameEngine.handleKeyDown('w');
              }
            }
          })
          .onTouch((event: TouchEvent) => {
            if (this.gameEngine) {
              if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                this.gameEngine.handleKeyUp('w');
              }
            }
          })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .padding({ bottom: 30 })
      }
      .width('100%')
      .height('100%')
    }
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

  // 从游戏引擎更新UI
  private updateUIFromGame(playerHp: number, playerMaxHp: number, enemyHp: number, enemyMaxHp: number): void {
    this.playerHp = playerHp;
    this.playerMaxHp = playerMaxHp;
    this.enemyHp = enemyHp;
    this.enemyMaxHp = enemyMaxHp;
  }
}
