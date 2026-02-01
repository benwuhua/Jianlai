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

  @State private animationProgress: number = 0;
  @State private showButtons: boolean = false;
  @State private selectedIndex: number = 0;
  private menuItems: string[] = ['重新开始', '返回主菜单'];

  aboutToAppear() {
    if (this.isVisible) {
      this.startAnimation();
    }
  }

  aboutToDisappear() {
    this.resetAnimation();
  }

  build() {
    if (!this.isVisible) {
      return;
    }

    // 全屏黑色背景
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor('#000000EE')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

    // KO/胜利文字动画
    Column({ space: 30 }) {
      // 大型KO或胜利文字
      Text(this.isVictory ? '胜利！' : 'K.O.')
        .fontSize(80)
        .fontColor(this.isVictory ? '#FFD700' : '#FF0000')
        .fontWeight(FontWeight.Bold)
        .fontStyle(FontStyle.Italic)
        .scale({ x: this.animationProgress, y: this.animationProgress })
        .animation({
          duration: 300,
          curve: Curve.EaseOut
        })

      // 获胜者名称
      Text(`${this.winner} 获胜`)
        .fontSize(36)
        .fontColor('#FFFFFF')
        .margin({ top: 20 })
        .opacity(this.showButtons ? 1 : 0)
        .animation({
          duration: 300,
          delay: 200,
          curve: Curve.EaseOut
        })

      // 菜单按钮（延迟显示）
      if (this.showButtons) {
        Column({ space: 15 }) {
          ForEach(this.menuItems, (item: string, index: number) => {
            this.createMenuButton(item, index)
          })
        }
        .margin({ top: 40 })
        .opacity(this.showButtons ? 1 : 0)
        .animation({
          duration: 300,
          delay: 400,
          curve: Curve.EaseOut
        })
      }
    }
    .width('100%')
    .height('100%')
    .onClick(() => {
      // 点击任意位置也可以触发第一个按钮
      if (this.showButtons) {
        this.handleMenuSelect(0);
      }
    })
  }

  @Builder
  private createMenuButton(item: string, index: number) {
    Button(item)
      .width(200)
      .height(50)
      .fontSize(20)
      .fontColor(index === this.selectedIndex ? '#000000' : '#FFFFFF')
      .backgroundColor(index === this.selectedIndex ? '#FFD700' : '#4A90E2')
      .borderRadius(10)
      .onClick(() => {
        this.handleMenuSelect(index);
      })
      .onFocus(() => {
        this.selectedIndex = index;
      })
  }

  private startAnimation(): void {
    this.animationProgress = 0;

    // 延迟显示按钮
    setTimeout(() => {
      this.animationProgress = 1.2; // 放大效果
      setTimeout(() => {
        this.animationProgress = 1; // 恢复正常大小
        this.showButtons = true;
      }, 100);
    }, 100);
  }

  private resetAnimation(): void {
    this.animationProgress = 0;
    this.showButtons = false;
  }

  private handleMenuSelect(index: number): void {
    hilog.info(DOMAIN, TAG, 'Selected menu item: %{public}s', this.menuItems[index]);

    switch (index) {
      case 0: // 重新开始
        this.onRestart();
        break;
      case 1: // 返回主菜单
        this.onQuit();
        break;
    }

    this.selectedIndex = 0;
  }

  // 键盘导航
  handleKeyDown(key: string): void {
    if (!this.showButtons) {
      return;
    }

    if (key === 'ArrowUp' || key === 'w' || key === 'W') {
      this.selectedIndex = Math.max(0, this.selectedIndex - 1);
    } else if (key === 'ArrowDown' || key === 's' || key === 'S') {
      this.selectedIndex = Math.min(this.menuItems.length - 1, this.selectedIndex + 1);
    } else if (key === 'Enter' || key === ' ') {
      this.handleMenuSelect(this.selectedIndex);
    } else if (key === 'ArrowLeft' || key === 'ArrowRight') {
      // 左右键也可以切换选项
    }
  }
}
