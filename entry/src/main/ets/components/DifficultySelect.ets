/**
 * 难度选择界面
 * @component DifficultySelect
 * @description 选择AI难度等级，展示难度信息和预览
 */
import { AIDifficulty } from '../models/AIBehavior';

// 难度配置
interface DifficultyConfig {
  level: number;
  name: string;
  key: AIDifficulty;
  description: string;
  enemyMultiplier: number;
  aiAggression: number;
  aiDefensive: number;
  tags: string[];
  color: string;
}

const DIFFICULTY_CONFIGS: DifficultyConfig[] = [
  {
    level: 1,
    name: '初入江湖',
    key: 'easy',
    description: '适合新手玩家熟悉操作，AI反应较慢',
    enemyMultiplier: 0.8,
    aiAggression: 0.3,
    aiDefensive: 0.3,
    tags: ['入门', '练习'],
    color: '#00B894'
  },
  {
    level: 2,
    name: '小有所成',
    key: 'normal',
    description: '标准的战斗体验，AI具备基本战斗能力',
    enemyMultiplier: 1.0,
    aiAggression: 0.5,
    aiDefensive: 0.5,
    tags: ['标准', '挑战'],
    color: '#FDCB6E'
  },
  {
    level: 3,
    name: '炉火纯青',
    key: 'hard',
    description: '需要熟练技巧应对，AI会使用连招和预判',
    enemyMultiplier: 1.2,
    aiAggression: 0.7,
    aiDefensive: 0.7,
    tags: ['困难', '进阶'],
    color: '#E17055'
  },
  {
    level: 4,
    name: '登峰造极',
    key: 'extreme',
    description: '极致挑战，AI具备顶级战斗策略',
    enemyMultiplier: 1.5,
    aiAggression: 0.9,
    aiDefensive: 0.9,
    tags: ['专家', '极限'],
    color: '#D63031'
  }
];

@CustomDialog
@Component
export struct DifficultySelect {
  controller: CustomDialogController;
  
  // 当前难度
  @Prop currentDifficulty: AIDifficulty = 'normal';
  
  // 回调函数
  onDifficultySelect?: (difficulty: AIDifficulty) => void;

  // 根据key获取难度配置
  getDifficultyByKey(key: AIDifficulty): DifficultyConfig {
    return DIFFICULTY_CONFIGS.find(d => d.key === key) || DIFFICULTY_CONFIGS[1];
  }

  build() {
    Column({ space: 24 }) {
      // 标题
      Text('选择挑战难度')
        .fontSize(24)
        .fontColor('#F5F5F5')
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center);

      // 难度卡片列表
      Column({ space: 12 }) {
        ForEach(DIFFICULTY_CONFIGS, (difficulty: DifficultyConfig) => {
          DifficultyCard({
            config: difficulty,
            isSelected: difficulty.key === this.currentDifficulty,
            onSelect: () => {
              if (this.onDifficultySelect) {
                this.onDifficultySelect(difficulty.key);
              }
              this.controller.close();
            }
          });
        });
      }
      .width('100%');

      // 取消按钮
      Button('取消')
        .width(120)
        .height(40)
        .backgroundColor('rgba(45,52,54,0.8)')
        .fontColor('#F5F5F5')
        .onClick(() => {
          this.controller.close();
        });
    }
    .width('90%')
    .padding(24)
    .backgroundColor('#1A1A1A')
    .borderRadius(20);
  }
}

/**
 * 难度卡片组件
 */
@Component
struct DifficultyCard {
  @Prop config: DifficultyConfig;
  @Prop isSelected: boolean = false;
  onSelect?: () => void;

  build() {
    Column({ space: 12 }) {
      // 卡片头部
      Row() {
        // 难度名称
        Text(this.config.name)
          .fontSize(20)
          .fontColor(this.isSelected ? '#1A1A1A' : '#F5F5F5')
          .fontWeight(FontWeight.Bold);

        Blank();

        // 选中指示器
        if (this.isSelected) {
          Text('✓')
            .fontSize(20)
            .fontColor('#1A1A1A')
            .fontWeight(FontWeight.Bold)
            .padding(8)
            .backgroundColor('#F5F5F5')
            .borderRadius(20);
        }
      }
      .width('100%');

      // 难度描述
      Text(this.config.description)
        .fontSize(14)
        .fontColor(this.isSelected ? '#2D3436' : '#B2BEC3')
        .width('100%')
        .textAlign(TextAlign.Start);

      // 属性信息
      Row({ space: 24 }) {
        // 敌人属性加成
        Column({ space: 4 }) {
          Text('敌人属性')
            .fontSize(12)
            .fontColor(this.isSelected ? '#2D3436' : '#B2BEC3');
          Text(`+${Math.round((this.config.enemyMultiplier - 1) * 100)}%`)
            .fontSize(18)
            .fontColor(this.config.color)
            .fontWeight(FontWeight.Bold);
        }
        .alignItems(HorizontalAlign.Center);

        // AI攻击性
        Column({ space: 4 }) {
          Text('AI攻击性')
            .fontSize(12)
            .fontColor(this.isSelected ? '#2D3436' : '#B2BEC3');
          Text(`${Math.round(this.config.aiAggression * 100)}%`)
            .fontSize(18)
            .fontColor(this.config.color)
            .fontWeight(FontWeight.Bold);
        }
        .alignItems(HorizontalAlign.Center);

        // AI防御性
        Column({ space: 4 }) {
          Text('AI防御性')
            .fontSize(12)
            .fontColor(this.isSelected ? '#2D3436' : '#B2BEC3');
          Text(`${Math.round(this.config.aiDefensive * 100)}%`)
            .fontSize(18)
            .fontColor(this.config.color)
            .fontWeight(FontWeight.Bold);
        }
        .alignItems(HorizontalAlign.Center);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly);

      // 标签
      Row({ space: 8 }) {
        ForEach(this.config.tags, (tag: string) => {
          Text(tag)
            .fontSize(12)
            .fontColor(this.isSelected ? '#1A1A1A' : this.config.color)
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor(this.isSelected ?
              'rgba(245,245,245,0.9)' :
              `${this.config.color}33`)
            .borderRadius(8);
        });
      }
      .width('100%')
      .justifyContent(FlexAlign.Start);
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.isSelected ? this.config.color : 'rgba(45,52,54,0.8)')
    .borderRadius(16)
    .border({
      width: this.isSelected ? 0 : 2,
      color: this.config.color,
      style: BorderStyle.Solid
    })
    .animation({
      duration: 200,
      curve: Curve.EaseOut
    })
    .onClick(this.onSelect);
  }
}

/**
 * 难度选择按钮（用于主界面）
 */
@Component
export struct DifficultyButton {
  @Prop currentDifficulty: AIDifficulty = 'normal';
  onClick?: () => void;

  getDifficultyName(key: AIDifficulty): string {
    const config = DIFFICULTY_CONFIGS.find(d => d.key === key);
    return config ? config.name : '未知';
  }

  getDifficultyColor(key: AIDifficulty): string {
    const config = DIFFICULTY_CONFIGS.find(d => d.key === key);
    return config ? config.color : '#636E72';
  }

  build() {
    Button() {
      Row({ space: 8 }) {
        Text('难度')
          .fontSize(14)
          .fontColor('#F5F5F5');
        Text(this.getDifficultyName(this.currentDifficulty))
          .fontSize(14)
          .fontColor(this.getDifficultyColor(this.currentDifficulty))
          .fontWeight(FontWeight.Bold);
      }
    }
    .width(140)
    .height(40)
    .backgroundColor('rgba(45,52,54,0.8)')
    .borderRadius(20)
    .onClick(this.onClick);
  }
}
