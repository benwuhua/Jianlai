import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'PauseMenu';

@Component
export struct PauseMenu {
  @Prop isVisible: boolean = false;
  @Prop onResume: () => void = () => {};
  @Prop onRestart: () => void = () => {};
  @Prop onQuit: () => void = () => {};

  @State private selectedIndex: number = 0;
  private menuItems: string[] = ['继续游戏', '重新开始', '返回主菜单'];

  build() {
    if (!this.isVisible) {
      return;
    }

    // 半透明黑色背景
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(0, 0, 0, 0.7)')
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        // 点击背景也关闭暂停菜单
        this.onResume();
      })

    // 暂停菜单内容
    Column({ space: 20 }) {
      // 暂停标题
      Text('暂停')
        .fontSize(36)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      // 菜单选项
      ForEach(this.menuItems, (item: string, index: number) => {
        this.createMenuItem(item, index)
      })
    }
    .width('60%')
    .padding(30)
    .backgroundColor('rgba(44, 62, 80, 0.9)')
    .borderRadius(20)
    .onClick((event: ClickEvent) => {
      // 阻止点击穿透到背景
      event.stopPropagation();
    })
  }

  @Builder
  private createMenuItem(item: string, index: number) {
    Text(item)
      .fontSize(24)
      .fontColor(index === this.selectedIndex ? '#FFD700' : '#FFFFFF')
      .fontWeight(index === this.selectedIndex ? FontWeight.Bold : FontWeight.Normal)
      .width('100%')
      .textAlign(TextAlign.Center)
      .padding(15)
      .backgroundColor(index === this.selectedIndex ? 'rgba(255, 215, 0, 0.2)' : 'transparent')
      .borderRadius(10)
      .onClick(() => {
        this.handleMenuSelect(index);
      })
      .onAppear(() => {
        // 键盘导航
      })
  }

  private handleMenuSelect(index: number): void {
    hilog.info(DOMAIN, TAG, 'Selected menu item: %{public}s', this.menuItems[index]);

    switch (index) {
      case 0: // 继续游戏
        this.onResume();
        break;
      case 1: // 重新开始
        this.onRestart();
        break;
      case 2: // 返回主菜单
        this.onQuit();
        break;
    }

    // 重置选择
    this.selectedIndex = 0;
  }

  // 键盘导航
  handleKeyDown(key: string): void {
    if (key === 'ArrowUp' || key === 'w' || key === 'W') {
      this.selectedIndex = Math.max(0, this.selectedIndex - 1);
    } else if (key === 'ArrowDown' || key === 's' || key === 'S') {
      this.selectedIndex = Math.min(this.menuItems.length - 1, this.selectedIndex + 1);
    } else if (key === 'Enter' || key === ' ') {
      this.handleMenuSelect(this.selectedIndex);
    }
  }
}
