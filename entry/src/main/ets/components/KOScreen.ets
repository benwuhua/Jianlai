import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'KOScreen';

@Component
export struct KOScreen {
  @Prop isVisible: boolean = false;
  @Prop winner: string = '';
  @Prop isVictory: boolean = false;
  @Prop onRestart: () => void = () => {};
  @Prop onQuit: () => void = () => {};

  @State private selectedIndex: number = 0;
  private menuItems: string[] = ['重新开始', '返回主菜单'];

  build() {
    if (!this.isVisible) {
      return;
    }

    Column() {
      Text(this.isVictory ? '胜利！' : 'K.O.')
        .fontSize(80)
        .fontColor(this.isVictory ? '#FFD700' : '#FF0000')
        .fontWeight(FontWeight.Bold)

      Text(`${this.winner} 获胜`)
        .fontSize(36)
        .fontColor('#FFFFFF')
        .margin({ top: 20 })

      Column({ space: 15 }) {
        ForEach(this.menuItems, (item: string) => {
          Button(item)
            .width(200)
            .height(50)
            .fontSize(20)
            .onClick(() => {
              if (item === '重新开始') {
                this.onRestart();
              } else {
                this.onQuit();
              }
            })
        })
      }
      .margin({ top: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000EE')
    .justifyContent(FlexAlign.Center)
  }

  handleKeyDown(key: string): void {
    if (key === 'ArrowUp' || key === 'w' || key === 'W') {
      this.selectedIndex = Math.max(0, this.selectedIndex - 1);
    } else if (key === 'ArrowDown' || key === 's' || key === 'S') {
      this.selectedIndex = Math.min(this.menuItems.length - 1, this.selectedIndex + 1);
    } else if (key === 'Enter' || key === ' ') {
      if (this.selectedIndex === 0) {
        this.onRestart();
      } else {
        this.onQuit();
      }
    }
  }
}
