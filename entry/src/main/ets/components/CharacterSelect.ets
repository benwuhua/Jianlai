/**
 * 角色选择界面
 * @component CharacterSelect
 * @description 网格布局的角色选择界面，支持阵营筛选和角色详情展示
 */
import { CharacterData } from '../game/CharacterManager';

@CustomDialog
@Component
export struct CharacterSelect {
  controller: CustomDialogController;
  
  // 角色列表
  @Prop characters: CharacterData[] = [];
  // 当前选中角色
  @Prop selectedCharacterId: string = '';
  // 筛选阵营
  @Prop filterFaction: string | null = null;
  
  // 回调函数
  onCharacterSelect?: (characterId: string) => void;
  onCharacterLongPress?: (characterId: string) => void;
  
  // 内部状态
  @State private currentFilter: string | null = null;
  @State private showDetail: boolean = false;
  @State private detailCharacter: CharacterData | null = null;

  // 获取筛选后的角色列表
  getFilteredCharacters(): CharacterData[] {
    if (!this.currentFilter) return this.characters;
    return this.characters.filter(c => c.faction === this.currentFilter);
  }

  // 获取阵营名称
  getFactionName(faction: string): string {
    const names: Record<string, string> = {
      'swordsman': '剑仙',
      'taoist': '儒道',
      'buddhist': '佛道',
      'demon': '妖族',
      'other': '其他'
    };
    return names[faction] || faction;
  }

  // 获取阵营颜色
  getFactionColor(faction: string): string {
    const colors: Record<string, string> = {
      'swordsman': '#4A90E2',
      'taoist': '#2E86AB',
      'buddhist': '#D64933',
      'demon': '#6C1B1B',
      'other': '#8E44AD'
    };
    return colors[faction] || '#636E72';
  }

  // 显示角色详情
  showCharacterDetail(character: CharacterData): void {
    this.detailCharacter = character;
    this.showDetail = true;
  }

  build() {
    Column({ space: 16 }) {
      // 标题
      Text('选择角色')
        .fontSize(24)
        .fontColor('#F5F5F5')
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: 20 });

      // 阵营筛选器
      Row({ space: 8 }) {
        FilterChip({
          label: '全部',
          isSelected: this.currentFilter === null,
          onClick: () => { this.currentFilter = null; }
        });

        ForEach(['swordsman', 'taoist', 'buddhist', 'demon'], (faction: string) => {
          FilterChip({
            label: this.getFactionName(faction),
            isSelected: this.currentFilter === faction,
            faction: faction,
            onClick: () => { this.currentFilter = faction; }
          });
        });
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .scrollable(ScrollDirection.Horizontal)
      .padding({ left: 16, right: 16 });

      // 角色网格
      Grid() {
        ForEach(this.getFilteredCharacters(), (character: CharacterData) => {
          GridItem() {
            CharacterCard({
              character: character,
              isSelected: character.id === this.selectedCharacterId,
              onClick: () => {
                if (this.onCharacterSelect) {
                  this.onCharacterSelect(character.id);
                }
              },
              onLongPress: () => {
                if (this.onCharacterLongPress) {
                  this.onCharacterLongPress(character.id);
                }
                this.showCharacterDetail(character);
              }
            });
          }
        });
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .padding(16)
      .width('100%')
      .layoutWeight(1);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1A1A1A');
  }
}

/**
 * 筛选芯片组件
 */
@Component
struct FilterChip {
  @Prop label: string;
  @Prop isSelected: boolean = false;
  @Prop faction: string = '';
  onClick?: () => void;

  build() {
    Text(this.label)
      .fontSize(14)
      .fontColor(this.isSelected ? '#1A1A1A' : '#F5F5F5')
      .fontWeight(this.isSelected ? FontWeight.Bold : FontWeight.Normal)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.isSelected ? this.getFactionColor() : 'rgba(45,52,54,0.8)')
      .borderRadius(16)
      .onClick(this.onClick);
  }

  getFactionColor(): string {
    if (!this.faction) return '#F5F5F5';
    const colors: Record<string, string> = {
      'swordsman': '#4A90E2',
      'taoist': '#2E86AB',
      'buddhist': '#D64933',
      'demon': '#6C1B1B'
    };
    return colors[this.faction] || '#F5F5F5';
  }
}

/**
 * 角色卡片组件
 */
@Component
struct CharacterCard {
  @Prop character: CharacterData;
  @Prop isSelected: boolean = false;
  onClick?: () => void;
  onLongPress?: () => void;

  getFactionColor(): string {
    const colors: Record<string, string> = {
      'swordsman': '#4A90E2',
      'taoist': '#2E86AB',
      'buddhist': '#D64933',
      'demon': '#6C1B1B',
      'other': '#8E44AD'
    };
    return colors[this.character.faction] || '#636E72';
  }

  build() {
    Column({ space: 8 }) {
      // 角色头像区域
      Stack() {
        // 头像背景
        Column()
          .width(72)
          .height(72)
          .backgroundColor('#2D3436')
          .borderRadius(12)
          .border({
            width: 3,
            color: this.isSelected ? this.getFactionColor() : '#2D3436',
            style: BorderStyle.Solid
          });

        // 角色图标（使用占位符）
        Text(this.character.name.charAt(0))
          .fontSize(32)
          .fontColor('#F5F5F5')
          .fontWeight(FontWeight.Bold);

        // 选中状态指示
        if (this.isSelected) {
          Column()
            .width('100%')
            .height('100%')
            .border({
              width: 3,
              color: '#F5F5F5',
              radius: 12,
              style: BorderStyle.Solid
            });
        }

        // 阵营标识
        Column()
          .width(16)
          .height(16)
          .backgroundColor(this.getFactionColor())
          .borderRadius(4)
          .position({ x: 4, y: 4 });
      }
      .width(72)
      .height(72);

      // 角色名称
      Text(this.character.name)
        .fontSize(12)
        .fontColor('#F5F5F5')
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis });
    }
    .width('100%')
    .padding(8)
    .backgroundColor(this.isSelected ? `${this.getFactionColor()}33` : 'transparent')
    .borderRadius(12)
    .animation({
      duration: 200,
      curve: Curve.EaseOut
    })
    .onClick(this.onClick)
    .onLongPress(this.onLongPress);
  }
}

/**
 * 角色详情弹窗
 */
@CustomDialog
@Component
struct CharacterDetailDialog {
  controller: CustomDialogController;
  @Prop character: CharacterData | null;

  getFactionName(faction: string): string {
    const names: Record<string, string> = {
      'swordsman': '剑仙',
      'taoist': '儒道',
      'buddhist': '佛道',
      'demon': '妖族',
      'other': '其他'
    };
    return names[faction] || faction;
  }

  getFactionColor(faction: string): string {
    const colors: Record<string, string> = {
      'swordsman': '#4A90E2',
      'taoist': '#2E86AB',
      'buddhist': '#D64933',
      'demon': '#6C1B1B',
      'other': '#8E44AD'
    };
    return colors[faction] || '#636E72';
  }

  build() {
    if (!this.character) return;

    Column({ space: 16 }) {
      // 头部
      Row() {
        Text(this.character.name)
          .fontSize(24)
          .fontColor('#F5F5F5')
          .fontWeight(FontWeight.Bold);

        Blank();

        Text(this.getFactionName(this.character.faction))
          .fontSize(14)
          .fontColor(this.getFactionColor(this.character.faction))
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
          .backgroundColor(`${this.getFactionColor(this.character.faction)}33`)
          .borderRadius(8);
      }
      .width('100%');

      // 基础属性
      Column({ space: 8 }) {
        StatRow({ label: '生命值', value: this.character.baseStats.maxHp.toString(), color: '#00B894' });
        StatRow({ label: '攻击力', value: this.character.baseStats.attack.toString(), color: '#E74C3C' });
        StatRow({ label: '防御力', value: this.character.baseStats.defense.toString(), color: '#3498DB' });
        StatRow({ label: '速度', value: this.character.baseStats.speed.toString(), color: '#F39C12' });
      }
      .width('100%')
      .padding(16)
      .backgroundColor('rgba(45,52,54,0.8)')
      .borderRadius(12);

      // 技能列表
      Text('技能')
        .fontSize(16)
        .fontColor('#F5F5F5')
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start);

      Column({ space: 8 }) {
        ForEach(this.character.skills, (skill: any) => {
          SkillInfoRow({ skill: skill });
        });

        // 必杀技
        SkillInfoRow({ skill: this.character.ultimate, isUltimate: true });
      }
      .width('100%');

      // 关闭按钮
      Button('确定')
        .width(100)
        .height(40)
        .backgroundColor(this.getFactionColor(this.character.faction))
        .fontColor('#1A1A1A')
        .onClick(() => {
          this.controller.close();
        });
    }
    .width('90%')
    .padding(20)
    .backgroundColor('#2D3436')
    .borderRadius(16);
  }
}

/**
 * 属性行组件
 */
@Component
struct StatRow {
  @Prop label: string;
  @Prop value: string;
  @Prop color: string;

  build() {
    Row() {
      Text(this.label)
        .fontSize(14)
        .fontColor('#B2BEC3')
        .width(80);

      Text(this.value)
        .fontSize(16)
        .fontColor(this.color)
        .fontWeight(FontWeight.Bold);
    }
    .width('100%');
  }
}

/**
 * 技能信息行组件
 */
@Component
struct SkillInfoRow {
  @Prop skill: any;
  @Prop isUltimate: boolean = false;

  build() {
    Row({ space: 12 }) {
      // 技能图标占位
      Column()
        .width(40)
        .height(40)
        .backgroundColor(this.isUltimate ? '#FD79A8' : '#636E72')
        .borderRadius(8);

      Column({ space: 4 }) {
        Text(this.skill.name)
          .fontSize(14)
          .fontColor('#F5F5F5')
          .fontWeight(FontWeight.Medium);

        Text(this.skill.description)
          .fontSize(12)
          .fontColor('#B2BEC3')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .layoutWeight(1);
      .alignItems(HorizontalAlign.Start);

      // 冷却和消耗
      Column({ space: 4 }) {
        Text(`CD: ${Math.round(this.skill.cooldown / 1000)}s`)
          .fontSize(10)
          .fontColor('#FDCB6E');
        Text(`气: ${this.skill.kiCost}`)
          .fontSize(10)
          .fontColor('#74B9FF');
      }
      .alignItems(HorizontalAlign.End);
    }
    .width('100%')
    .padding(8)
    .backgroundColor('rgba(0,0,0,0.3)')
    .borderRadius(8);
  }
}
