import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CharacterManager } from '../game/CharacterManager';

const DOMAIN = 0x0000;
const TAG = 'MainMenu';

@Entry
@Component
struct MainMenu {
  @State private isLoading: boolean = true;
  @State private characterCount: number = 0;

  async aboutToAppear() {
    // 预加载角色数据
    try {
      const manager = CharacterManager.getInstance();
      await manager.loadAllCharacters();
      this.characterCount = manager.getAllCharacters().length;
      hilog.info(DOMAIN, TAG, 'Loaded %{public}d characters', this.characterCount);
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to load characters: %{public}s', JSON.stringify(error));
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    RelativeContainer() {
      Column() {
        // 游戏标题
        Text('剑来')
          .fontSize(60)
          .fontColor('#FFD700')
          .fontWeight(FontWeight.Bold)
          .margin({ top: 100, bottom: 20 })

        Text('格斗游戏')
          .fontSize(30)
          .fontColor('#FFFFFF')
          .margin({ bottom: 80 })

        // 加载状态
        if (this.isLoading) {
          Text('加载中...')
            .fontSize(20)
            .fontColor('#CCCCCC')
        } else {
          // 主菜单按钮
          Column({ space: 20 }) {
            this.MenuButton('开始游戏', () => {
              this.navigateToCharacterSelect();
            })

            this.MenuButton('游戏设置', () => {
              // TODO: 实现设置页面
              hilog.info(DOMAIN, TAG, 'Settings clicked (not implemented)');
            })

            this.MenuButton('关于游戏', () => {
              // TODO: 实现关于页面
              hilog.info(DOMAIN, TAG, 'About clicked (not implemented)');
            })
          }
          .width('60%')
        }

        // 底部信息
        Blank()

        Text(`已加载 ${this.characterCount} 个角色`)
          .fontSize(14)
          .fontColor('#888888')
          .margin({ bottom: 20 })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1A1A2E')
  }

  @Builder
  MenuButton(text: string, onClick: () => void) {
    Button(text)
      .width('100%')
      .height(60)
      .fontSize(24)
      .fontColor('#FFFFFF')
      .backgroundColor('#4A90E2')
      .borderRadius(10)
      .onClick(() => {
        onClick();
      })
  }

  private navigateToCharacterSelect(): void {
    router.pushUrl({
      url: 'pages/CharacterSelect'
    }).catch((error: Error) => {
      hilog.error(DOMAIN, TAG, 'Failed to navigate: %{public}s', error.message);
    });
  }
}
