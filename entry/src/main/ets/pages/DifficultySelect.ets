import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'DifficultySelect';

// 难度配置
interface DifficultyConfig {
  id: string;
  name: string;
  description: string;
  color: string;
  aiLevel: string;
}

const DIFFICULTIES: DifficultyConfig[] = [
  {
    id: 'easy',
    name: '简单',
    description: '适合新手，AI随机行动',
    color: '#27AE60',
    aiLevel: '小白'
  },
  {
    id: 'normal',
    name: '普通',
    description: '有一定挑战，AI会使用技能',
    color: '#F39C12',
    aiLevel: '练气士'
  },
  {
    id: 'hard',
    name: '困难',
    description: '高难度，AI会连招和格挡',
    color: '#E67E22',
    aiLevel: '金丹'
  },
  {
    id: 'expert',
    name: '地仙',
    description: '极难挑战，AI精通所有技巧',
    color: '#E74C3C',
    aiLevel: '地仙'
  }
];

@Entry
@Component
struct DifficultySelect {
  @State private selectedDifficulty: DifficultyConfig | null = null;
  @State private characterId: string = '';

  aboutToAppear() {
    // 获取从上一页传递过来的角色ID
    const params = router.getParams() as Record<string, string>;
    this.characterId = params['characterId'] || '';
    hilog.info(DOMAIN, TAG, 'Selected character ID: %{public}s', this.characterId);
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button('返回')
          .fontSize(16)
          .backgroundColor('#2C3E50')
          .onClick(() => {
            router.back();
          })

        Text('选择难度')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 占位
        Text('')
          .width(60)
      }
      .width('100%')
      .height(60)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#2C3E50')

      // 难度选择列表
      Scroll() {
        Column({ space: 20 }) {
          ForEach(DIFFICULTIES, (difficulty: DifficultyConfig) => {
            this.DifficultyCard(difficulty)
          })
        }
        .width('90%')
        .padding({ top: 30, bottom: 30 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .width('100%')

      // 底部确认按钮
      Column() {
        if (this.selectedDifficulty) {
          Text(`已选择: ${this.selectedDifficulty.name} (${this.selectedDifficulty.aiLevel})`)
            .fontSize(16)
            .fontColor('#FFD700')
            .margin({ bottom: 10 })

          Button('开始战斗')
            .width('80%')
            .height(50)
            .fontSize(20)
            .fontColor('#FFFFFF')
            .backgroundColor(this.selectedDifficulty.color)
            .borderRadius(10)
            .onClick(() => {
              this.startBattle();
            })
        } else {
          Text('请选择难度')
            .fontSize(16)
            .fontColor('#888888')
            .margin({ bottom: 10 })
        }
      }
      .width('100%')
      .height(100)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#1A1A2E')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0F0F1A')
  }

  @Builder
  DifficultyCard(difficulty: DifficultyConfig) {
    Column() {
      Row() {
        // 难度名称
        Text(difficulty.name)
          .fontSize(24)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)

        Blank()

        // AI等级标签
        Text(difficulty.aiLevel)
          .fontSize(14)
          .fontColor(difficulty.color)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor(difficulty.color + '20')
          .borderRadius(5)
      }
      .width('100%')
      .margin({ bottom: 10 })

      // 描述
      Text(difficulty.description)
        .fontSize(14)
        .fontColor('#AAAAAA')
        .width('100%')
        .margin({ bottom: 15 })

      // 选中状态
      if (this.selectedDifficulty?.id === difficulty.id) {
        Row() {
          Text('✓ 已选择')
            .fontSize(14)
            .fontColor(difficulty.color)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#1E1E2E')
    .borderRadius(10)
    .border({
      width: this.selectedDifficulty?.id === difficulty.id ? 3 : 1,
      color: this.selectedDifficulty?.id === difficulty.id ? difficulty.color : '#333333'
    })
    .onClick(() => {
      this.selectedDifficulty = difficulty;
      hilog.info(DOMAIN, TAG, 'Selected difficulty: %{public}s', difficulty.name);
    })
  }

  private startBattle(): void {
    if (!this.selectedDifficulty || !this.characterId) {
      hilog.warn(DOMAIN, TAG, 'Cannot start battle: missing character or difficulty');
      return;
    }

    hilog.info(DOMAIN, TAG, 'Starting battle with character: %{public}s, difficulty: %{public}s',
      this.characterId, this.selectedDifficulty.id);

    // 导航到游戏页面，传递角色ID和难度
    router.replaceUrl({
      url: 'pages/Index',
      params: {
        characterId: this.characterId,
        difficulty: this.selectedDifficulty.id
      }
    }).catch((error: Error) => {
      hilog.error(DOMAIN, TAG, 'Failed to navigate to battle: %{public}s', error.message);
    });
  }
}
