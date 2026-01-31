import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CharacterManager, CharacterData } from '../game/CharacterManager';

const DOMAIN = 0x0000;
const TAG = 'CharacterSelect';

// 阵营配置
const FACTION_CONFIG = {
  'swordsman': { name: '剑仙', color: '#4A90E2' },
  'confucian': { name: '儒道', color: '#9B59B6' },
  'buddhist': { name: '佛道', color: '#F39C12' },
  'demon': { name: '妖族', color: '#E74C3C' }
};

@Entry
@Component
struct CharacterSelect {
  @State private characters: CharacterData[] = [];
  @State private isLoading: boolean = true;
  @State private selectedCharacter: CharacterData | null = null;

  async aboutToAppear() {
    await this.loadCharacters();
  }

  private async loadCharacters(): Promise<void> {
    try {
      const manager = CharacterManager.getInstance();
      this.characters = manager.getAllCharacters();
      hilog.info(DOMAIN, TAG, 'Loaded %{public}d characters', this.characters.length);
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to load characters: %{public}s', JSON.stringify(error));
    } finally {
      this.isLoading = false;
    }
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

        Text('选择角色')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 占位，保持标题居中
        Text('')
          .width(60)
      }
      .width('100%')
      .height(60)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#2C3E50')

      if (this.isLoading) {
        // 加载中
        Column() {
          Text('加载角色数据中...')
            .fontSize(20)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // 角色网格
        Scroll() {
          Grid() {
            ForEach(this.characters, (character: CharacterData) => {
              GridItem() {
                this.CharacterCard(character)
              }
            })
          }
          .columnsTemplate('1fr 1fr')
          .rowsGap(15)
          .columnsGap(15)
          .width('95%')
          .padding({ top: 20, bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .width('100%')

        // 底部确认按钮
        Column() {
          if (this.selectedCharacter) {
            Text(`已选择: ${this.selectedCharacter.name}`)
              .fontSize(18)
              .fontColor('#FFD700')
              .margin({ bottom: 10 })

            Button('开始战斗')
              .width('80%')
              .height(50)
              .fontSize(20)
              .fontColor('#FFFFFF')
              .backgroundColor('#4A90E2')
              .borderRadius(10)
              .onClick(() => {
                this.navigateToDifficultySelect();
              })
          } else {
            Text('请选择一个角色')
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0F0F1A')
  }

  @Builder
  CharacterCard(character: CharacterData) {
    Column() {
      // 角色头像/颜色块
      Stack() {
        Circle()
          .width(80)
          .height(80)
          .fill(character.color)

        // 角色名字首字
        Text(character.name.charAt(0))
          .fontSize(36)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }
      .margin({ top: 15, bottom: 10 })

      // 角色名称
      Text(character.name)
        .fontSize(18)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 5 })

      // 阵营标签
      Text(FACTION_CONFIG[character.faction]?.name || character.faction)
        .fontSize(14)
        .fontColor(FACTION_CONFIG[character.faction]?.color || '#CCCCCC')
        .margin({ bottom: 10 })

      // 基础属性
      Column({ space: 5 }) {
        this.StatRow('生命', character.baseStats.maxHp)
        this.StatRow('攻击', character.baseStats.attack)
        this.StatRow('防御', character.baseStats.defense)
        this.StatRow('速度', character.baseStats.speed)
      }
      .width('100%')
      .padding({ left: 10, right: 10 })
      .margin({ bottom: 15 })

      // 选中状态
      if (this.selectedCharacter?.id === character.id) {
        Row() {
          Text('✓ 已选择')
            .fontSize(14)
            .fontColor('#4A90E2')
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 10 })
      }
    }
    .width('100%')
    .backgroundColor('#1E1E2E')
    .borderRadius(10)
    .border({
      width: this.selectedCharacter?.id === character.id ? 3 : 1,
      color: this.selectedCharacter?.id === character.id ? '#4A90E2' : '#333333'
    })
    .onClick(() => {
      this.selectedCharacter = character;
      hilog.info(DOMAIN, TAG, 'Selected character: %{public}s', character.name);
    })
  }

  @Builder
  StatRow(label: string, value: number) {
    Row() {
      Text(`${label}:`)
        .fontSize(12)
        .fontColor('#AAAAAA')
        .width(50)

      Text(value.toString())
        .fontSize(12)
        .fontColor('#FFFFFF')
        .layoutWeight(1)

      // 属性条
      Row()
        .width(50)
        .height(4)
        .backgroundColor('#333333')
        .margin({ left: 5 })

      Row()
        .width(Math.min(50, value / 30))
        .height(4)
        .backgroundColor('#4A90E2')
    }
    .width('100%')
    .padding({ left: 10, right: 10 })
  }

  private navigateToDifficultySelect(): void {
    if (!this.selectedCharacter) {
      return;
    }

    router.pushUrl({
      url: 'pages/DifficultySelect',
      params: {
        characterId: this.selectedCharacter.id
      }
    }).catch((error: Error) => {
      hilog.error(DOMAIN, TAG, 'Failed to navigate: %{public}s', error.message);
    });
  }
}
