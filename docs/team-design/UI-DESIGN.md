# 《剑来》游戏UI设计规范

## 文档信息

| 项目 | 内容 |
|------|------|
| 游戏名称 | 剑来 |
| 游戏类型 | 横版格斗游戏 |
| 目标平台 | HarmonyOS |
| 适配设备 | 手机/折叠屏 |
| 设计风格 | 水墨武侠风格 |
| 文档版本 | 1.0 |
| 创建日期 | 2026-01-29 |

---

## 1. 视觉风格定义

### 1.1 设计理念

本游戏UI设计以《剑来》小说的水墨武侠美学为核心，通过简洁有力的视觉语言传达武侠世界的意境与张力。设计遵循"留白透气、墨韵层次、动静相生"三大原则，在保证游戏性能的同时，呈现高品质的视觉体验。

水墨风格强调意境的营造，UI元素不宜过于繁复，而应以简练的线条和典雅的色彩构建画面。借鉴传统中国画"计白当黑"的构图智慧，为游戏画面留出足够的呼吸空间，让玩家专注于战斗本身。色彩运用上，以墨色为基调，辅以各阵营代表色，既保持整体风格的统一，又能通过色彩快速传达阵营归属和战斗状态。

### 1.2 色彩系统

#### 1.2.1 主色调

| 颜色名称 | 色值 | 用途说明 |
|----------|------|----------|
| 墨黑 | #1A1A1A | 界面背景、主要文字 |
| 浓墨 | #2D3436 | 次级文字、边框 |
| 淡墨 | #636E72 | 禁用状态、辅助说明 |
| 宣纸白 | #F5F5F5 | 卡片背景、高亮区域 |
| 绢米色 | #F8F4E8 | 界面底纹、次要背景 |

#### 1.2.2 四大阵营色彩

阵营色彩是游戏视觉识别系统的核心元素，每个阵营拥有独特的代表色，用于角色头像、边框、UI装饰等场景。色彩选择兼顾传统寓意与视觉辨识度，确保玩家在激烈的战斗中仍能快速识别阵营归属。

| 阵营名称 | 主色 | 辅色 | 阵营寓意 |
|----------|------|------|----------|
| 道家 | #2E86AB | #A23B72 | 上善若水，智慧深远 |
| 佛家 | #D64933 | #F4A261 | 慈悲金刚，降魔卫道 |
| 儒家 | #3D5A80 | #98C1D9 | 仁义礼智，浩然正气 |
| 兵家 | #1B4332 | #95D5B2 | 兵法权谋，决胜千里 |

#### 1.2.3 状态指示色

| 状态 | 颜色 | 色值 | 使用场景 |
|------|------|------|----------|
| 生命旺盛 | 翡翠绿 | #00B894 | 满血状态 |
| 生命告急 | 琥珀黄 | #FDCB6E | 中血量警示 |
| 生命垂危 | 朱砂红 | #D63031 | 低血量警告 |
| 剑气充盈 | 天青蓝 | #74B9FF | 技能就绪 |
| 冷却中 | 烟灰紫 | #B2BEC3 | 技能冷却 |
| 连击加成 | 金色 | #F39C12 | 高连击数 |
| 胜利结算 | 鎏金 | #E1B12C | 结算高亮 |
| 失败灰暗 | 鸦青 | #505050 | 失败状态 |

#### 1.2.4 材质纹理

游戏UI采用仿宣纸和仿绢帛的纹理处理，营造传统文化氛围。纹理使用需克制，仅在重要界面（如主菜单、结算界面）使用全幅纹理，战斗界面保持简洁以确保性能。

```css
/* 宣纸纹理效果 */
.fan-paper {
  background-image: url('/resources/textures/fan-paper.png');
  background-blend-mode: multiply;
  opacity: 0.92;
}

/* 绢帛纹理效果 */
.silk-fabric {
  background-image: url('/resources/textures/silk-fabric.png');
  background-blend-mode: soft-light;
  opacity: 0.88;
}
```

### 1.3 字体规范

#### 1.3.1 字体家族

考虑到HarmonyOS的字体渲染特性和文化适配需求，字体选择遵循以下优先级：

| 用途 | 首选字体 | 备选字体 | 字重 |
|------|----------|----------|------|
| 主标题 | HarmonyOS Sans SC Bold | Noto Serif SC Bold | Bold |
| 副标题 | HarmonyOS Sans SC Medium | Noto Serif SC Medium | Medium |
| 正文 | HarmonyOS Sans SC Regular | Noto Serif SC Regular | Regular |
| 数字/计数 | HarmonyOS Sans SC Number | Roboto Mono | Medium |
| 装饰文字 | 方正黄草_GBK | STKaiti | Regular |

#### 1.3.2 字号规范

字号设计基于屏幕高度的比例，确保在不同尺寸设备上保持良好的可读性和视觉比例。战斗界面使用较大字号以确保信息清晰可辨，非战斗界面则采用相对收敛的字号以保持优雅。

| 用途 | 基准尺寸（px） | 平板/折叠屏适配 | 说明 |
|------|----------------|-----------------|------|
| 大标题 | 32 | 40 | 主菜单标题、结算大标题 |
| 中标题 | 24 | 28 | 界面标题、角色名 |
| 小标题 | 18 | 22 | 分组标题、状态提示 |
| 正文 | 14 | 16 | 说明文字、技能描述 |
| 辅助文字 | 12 | 14 | 次要信息、冷却计时 |
| 战斗数字 | 28-48 | 32-56 | 生命值、连击数、伤害数字 |
| 技能图标文字 | 10 | 12 | 快捷键、热键提示 |

#### 1.3.3 行高与字间距

中文排版需特别注意行高设置，确保文字在不同字号下都具有良好的可读性。战斗场景中的数字显示采用紧凑的行高以节省空间。

```css
/* 标题文字 */
.heading-text {
  line-height: 1.3;
  letter-spacing: 2px;
}

/* 正文内容 */
.body-text {
  line-height: 1.6;
  letter-spacing: 1px;
}

/* 紧凑数字 */
.compact-number {
  line-height: 1.1;
  letter-spacing: 0;
}
```

### 1.4 间距系统

#### 1.4.1 基础间距单位

采用8px作为基础间距单位，所有间距值均为8的倍数。这不仅便于开发实现，也有助于保持视觉上的节奏感和一致性。

| 名称 | 间距值 | 用途 |
|------|--------|------|
| xs | 4px | 元素内部微调 |
| sm | 8px | 相关元素组间距 |
| md | 16px | 常规元素间距 |
| lg | 24px | 组件间距 |
| xl | 32px | 区块间距 |
| 2xl | 48px | 界面分区间距 |
| 3xl | 64px | 全屏边距 |

#### 1.4.2 响应式间距

折叠屏设备在不同状态下需要调整间距策略，确保界面元素既不过于拥挤也不过于松散。

| 设备状态 | 基础边距 | 组件间距 | 列表间距 |
|----------|----------|----------|----------|
| 手机竖屏 | 16px | 12px | 8px |
| 手机横屏 | 20px | 16px | 12px |
| 折叠单屏 | 20px | 16px | 12px |
| 折叠双屏展开 | 32px | 24px | 16px |

### 1.5 图标系统

#### 1.5.1 图标风格

游戏图标采用"水墨线条"风格，以粗细变化的线条勾勒轮廓，模拟毛笔书写的质感。图标设计遵循"简练传神"的原则，用最少的笔触传达最明确的意义。

图标网格采用24x24的基础单位，图标主体占用20x20的视觉区域，四周各留2px出血空间。关键元素（中心点、重要线条）对齐网格基准线，确保图标在各种尺寸下都保持清晰的辨识度。

#### 1.5.2 图标尺寸

| 用途 | 基础尺寸 | 可用尺寸 | 备注 |
|------|----------|----------|------|
| 技能图标 | 64px | 48-80px | 主要交互元素 |
| 角色头像 | 56px | 48-72px | 列表选择展示 |
| 小型图标 | 24px | 20-32px | 功能标识 |
| 装饰图标 | 32px | 28-40px | 界面装饰 |
| 状态图标 | 20px | 16-24px | 状态指示 |

#### 1.5.3 核心图标清单

```
/resources/icons/
├── combat/
│   ├── attack.png      # 攻击
│   ├── defense.png     # 防御
│   ├── skill.png       # 技能
│   ├── ultimate.png    # 大招
│   └── dash.png        # 冲刺
├── faction/
│   ├── daoist.png      # 道家
│   ├── buddhist.png    # 佛家
│   ├── confucian.png   # 儒家
│   └── militarist.png  # 兵家
├── ui/
│   ├── menu.png        # 菜单
│   ├── settings.png    # 设置
│   ├── back.png        # 返回
│   ├── home.png        # 主页
│   └── close.png       # 关闭
└── status/
    ├── cooldown.png    # 冷却
    ├── lock.png        # 锁定
    ├── selected.png    # 选中
    └── disabled.png    # 禁用
```

---

## 2. 组件设计规范

### 2.1 角色头像框组件

#### 2.1.1 组件概述

角色头像框是游戏中最核心的UI组件之一，用于角色选择界面、战斗界面和结算界面。头像框需要清晰展示角色形象、阵营归属和当前状态。设计采用"外框定阵营、内核显个性"的分层结构，外框颜色标识阵营，内核展示角色剪影或头像。

头像框需支持多种状态展示：默认状态、选中状态、锁定状态、禁用状态和战斗状态（显示生命值）。不同状态通过边框样式、遮罩层和角标进行区分。

#### 2.1.2 设计规格

| 属性 | 规格值 |
|------|--------|
| 基础尺寸 | 80×80px（可缩放） |
| 头像区域 | 64×64px（居中） |
| 边框宽度 | 3px |
| 圆角半径 | 12px |
| 阵营标识 | 左上角12×12px色块 |
| 状态角标 | 右上角16×16px图标 |

#### 2.1.3 阵营边框样式

每个阵营拥有独特的边框纹理设计，通过渐变色和图案体现阵营特色。

```typescript
// 阵营边框配置
interface FactionBorderStyle {
  faction: 'daoist' | 'buddhist' | 'confucian' | 'militarist';
  primaryColor: string;
  secondaryColor: string;
  gradientAngle: number;
  patternType: 'wave' | 'lotus' | 'ruyi' | 'spear';
}

const factionBorders: FactionBorderStyle[] = [
  {
    faction: 'daoist',
    primaryColor: '#2E86AB',
    secondaryColor: '#A23B72',
    gradientAngle: 180,
    patternType: 'wave'
  },
  {
    faction: 'buddhist',
    primaryColor: '#D64933',
    secondaryColor: '#F4A261',
    gradientAngle: 45,
    patternType: 'lotus'
  },
  {
    faction: 'confucian',
    primaryColor: '#3D5A80',
    secondaryColor: '#98C1D9',
    gradientAngle: 90,
    patternType: 'ruyi'
  },
  {
    faction: 'militarist',
    primaryColor: '#1B4332',
    secondaryColor: '#95D5B2',
    gradientAngle: 135,
    patternType: 'spear'
  }
];
```

#### 2.1.4 组件状态

| 状态 | 视觉表现 | 交互表现 |
|------|----------|----------|
| 默认 | 正常边框，100%不透明度 | 可点击，有 hover 效果 |
| 选中 | 高亮边框，缩放1.05倍 | 聚焦状态，持续高亮 |
| 锁定 | 灰色遮罩，锁图标覆盖 | 不可点击 |
| 禁用 | 50%不透明度，灰色滤镜 | 不可点击 |
| 战斗 | 显示血条，角色头像置灰 | 不可交互 |

#### 2.1.5 ArkTS代码模板

```typescript
/**
 * 角色头像框组件
 * @component CharacterAvatar
 * @description 用于展示角色头像，支持多种状态和阵营样式
 */
@Component
export struct CharacterAvatar {
  // 角色ID
  @Prop characterId: string;
  // 角色头像资源
  @Prop avatarResource: Resource;
  // 阵营类型
  @Prop faction: 'daoist' | 'buddhist' | 'confucian' | 'militarist';
  // 组件状态
  @Prop state: 'default' | 'selected' | 'locked' | 'disabled' | 'combat';
  // 生命值（战斗状态）
  @Prop healthPercent100;
  //: number =  是否为玩家角色
  @Prop isPlayer: boolean = true;
  // 点击事件
  onClick?: (characterId: string) => void;

  // 内部状态
  @State private isPressed: boolean = false;

  // 获取阵营颜色
  getFactionColor(faction: string): string {
    const colors = {
      'daoist': '#2E86AB',
      'buddhist': '#D64933',
      'confucian': '#3D5A80',
      'militarist': '#1B4332'
    };
    return colors[faction] || '#636E72';
  }

  // 构建样式
  @Builder
  buildFactionBorder(faction: string) {
    Column() {
      // 边框装饰层
    }
    .border({
      width: 3,
      color: this.getFactionColor(faction),
      radius: 12,
      style: BorderStyle.Solid
    })
    .backgroundColor(this.state === 'disabled' ? '#505050' : '#1A1A1A')
  }

  build() {
    Column() {
      // 头像容器
      Stack() {
        // 角色头像
        Image(this.avatarResource)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .borderRadius(10)
          .grayscale(this.state === 'combat' ? 1 : 0)
          .opacity(this.state === 'disabled' ? 0.5 : 1);

        // 阵营标识
        if (this.state !== 'combat') {
          Column()
            .width(12)
            .height(12)
            .backgroundColor(this.getFactionColor(this.faction))
            .borderRadius(2)
            .position({ x: 4, y: 4 });
        }

        // 战斗状态血条
        if (this.state === 'combat') {
          Column() {
            Row() {
              // 血条背景
              Row()
                .width('90%')
                .height(4)
                .backgroundColor('#2D3436')
                .borderRadius(2);

              // 血条前景
              Row()
                .width(`${this.healthPercent}%`)
                .height(4)
                .backgroundColor(this.getHealthColor())
                .borderRadius(2)
                .animation({
                  duration: 200,
                  curve: Curve.EaseOut
                });
            }
            .width('100%')
            .justifyContent(FlexAlign.Center);
          }
          .position({ x: 0, y: '85%' })
          .width('100%');
        }

        // 锁定遮罩
        if (this.state === 'locked') {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.6)')
            .borderRadius(10);

          Image($r('app.media.ic_lock'))
            .width(24)
            .height(24)
            .fillColor('#F5F5F5');
        }
      }
      .width(this.state === 'selected' ? 88 : 80)
      .height(this.state === 'selected' ? 88 : 80)
      .scale({ x: this.state === 'selected' ? 1.05 : 1 })
      .animation({
        duration: 150,
        curve: Curve.EaseOut
      })
      .onClick(() => {
        if (this.state !== 'locked' && this.state !== 'disabled' && this.onClick) {
          this.onClick(this.characterId);
        }
      });
    }
  }

  getHealthColor(): string {
    if (this.healthPercent > 50) return '#00B894';
    if (this.healthPercent > 25) return '#FDCB6E';
    return '#D63031';
  }
}
```

### 2.2 血条组件

#### 2.2.1 组件概述

血条组件是战斗界面的核心信息展示元素，需要清晰传达角色当前生命值和最大生命值的比例。设计采用"主血条+伤害反馈"的双层结构，主血条显示当前生命值，受到伤害时通过红色闪烁和数值跳动提供即时反馈。

血条分为玩家血条和敌人血条两种变体：玩家血条位于屏幕左上方，从左向右填充；敌人血条位于屏幕右上方，从右向左填充。这种设计符合玩家的阅读习惯，同时在视觉上形成对称美感。

#### 2.2.2 设计规格

| 属性 | 玩家血条 | 敌人血条 |
|------|----------|----------|
| 基础宽度 | 240px | 200px |
| 基础高度 | 20px | 16px |
| 圆角半径 | 10px | 8px |
| 填充方向 | 左→右 | 右→左 |
| 位置 | 左上角 | 右上角 |
| 伤害延迟 | 100ms | 100ms |

#### 2.2.3 血条层次结构

```
玩家血条组件
├── 容器层
│   ├── 背景层（深灰色半透明）
│   ├── 血条层（当前血量）
│   │   └── 渐变填充（绿→黄→红）
│   └── 血条边框（阵营颜色）
├── 文字层
│   ├── 数值显示（当前/最大）
│   └── 角色名（可选择显示）
└── 特效层
    ├── 受击闪烁（红色遮罩）
    └── 伤害飘字（动态数字）
```

#### 2.2.4 ArkTS代码模板

```typescript
/**
 * 血条组件
 * @component HealthBar
 * @description 展示角色生命值，支持伤害反馈和状态变化
 */
@Component
export struct HealthBar {
  // 当前生命值
  @Prop currentHealth: number;
  // 最大生命值
  @Prop maxHealth: number;
  // 角色名称
  @Prop characterName: string;
  // 阵营类型（用于边框颜色）
  @Prop faction: 'daoist' | 'buddhist' | 'confucian' | 'militarist';
  // 是否为玩家
  @Prop isPlayer: boolean = true;
  // 血条宽度
  @Prop barWidth: number = 240;
  // 是否显示数值文字
  @Prop showText: boolean = true;

  // 内部状态
  @State private displayHealth: number = 100;
  @State private previousHealth: number = 100;
  @State private damageFlash: number = 0;

  // 计算血量百分比
  getHealthPercent(): number {
    return Math.max(0, Math.min(100,
      (this.displayHealth / this.maxHealth) * 100
    ));
  }

  // 获取血条颜色
  getBarColor(): string {
    const percent = this.getHealthPercent();
    if (percent > 50) return '#00B894';
    if (percent > 25) return '#FDCB6E';
    return '#D63031';
  }

  // 获取阵营颜色
  getFactionColor(): string {
    const colors = {
      'daoist': '#2E86AB',
      'buddhist': '#D64933',
      'confucian': '#3D5A80',
      'militarist': '#1B4332'
    };
    return colors[this.faction];
  }

  aboutToAppear(): void {
    this.displayHealth = this.currentHealth;
    this.previousHealth = this.currentHealth;
  }

  aboutToUpdate({
    propKey,
    oldValue,
    newValue
  }: { propKey: string; oldValue: number; newValue: number }): void {
    if (propKey === 'currentHealth' && newValue < oldValue) {
      // 受到伤害，触发闪烁效果
      this.triggerDamageFlash();
    }
  }

  triggerDamageFlash(): void {
    // 伤害闪烁动画
    animateTo({
      duration: 100,
      iterations: 3
    }, () => {
      this.damageFlash = 1;
    });
    setTimeout(() => {
      this.damageFlash = 0;
    }, 300);
  }

  build() {
    Column({ space: 4 }) {
      // 角色名称
      if (this.showText && this.characterName) {
        Text(this.characterName)
          .fontSize(14)
          .fontColor('#F5F5F5')
          .fontWeight(FontWeight.Medium)
          .textAlign(this.isPlayer ? TextAlign.Start : TextAlign.End)
          .width('100%');
      }

      // 血条容器
      Stack() {
        // 血条背景
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(45, 52, 54, 0.8)')
          .borderRadius(this.isPlayer ? 10 : 8);

        // 血条填充
        Row()
          .height('100%')
          .width(this.isPlayer ?
            `${this.getHealthPercent()}%` :
            `${this.getHealthPercent()}%`)
          .backgroundColor(this.getBarColor())
          .borderRadius(this.isPlayer ? 10 : 8)
          .animation({
            duration: 200,
            curve: Curve.EaseOut
          });

        // 受击闪烁层
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor('#D63031')
          .opacity(this.damageFlash)
          .borderRadius(this.isPlayer ? 10 : 8);

        // 阵营标识线
        Row()
          .width(3)
          .height('60%')
          .backgroundColor(this.getFactionColor())
          .position({
            x: this.isPlayer ? 4 : 'auto',
            right: this.isPlayer ? 'auto' : 4,
            left: this.isPlayer ? 4 : undefined
          });
      }
      .width(this.barWidth)
      .height(this.isPlayer ? 20 : 16);

      // 数值显示
      if (this.showText) {
        Text(`${Math.ceil(this.displayHealth)} / ${this.maxHealth}`)
          .fontSize(12)
          .fontColor('#636E72')
          .textAlign(this.isPlayer ? TextAlign.Start : TextAlign.End)
          .width('100%');
      }
    }
    .alignItems(this.isPlayer ? HorizontalAlign.Start : HorizontalAlign.End);
  }
}
```

### 2.3 剑气槽组件

#### 2.3.1 组件概述

剑气槽是战斗系统中能量管理的核心UI元素，用于展示角色当前积累的剑气值。剑气值通过战斗中的攻击、格挡和连击逐步积累，当剑气槽满时角色可以释放终极技能。设计采用"阶梯式积累"的可视化方式，通过光效和粒子效果增强积累的成就感。

剑气槽支持多种显示模式：战斗模式下完整显示积累过程，非战斗模式下简化为数值显示。剑气槽的充盈动画采用从下向上的填充方式，配合流动的光效模拟剑气汇聚的视觉效果。

#### 2.3.2 设计规格

| 属性 | 规格值 |
|------|--------|
| 基础宽度 | 280px |
| 基础高度 | 24px |
| 分段数 | 4段（每段25%） |
| 充能动画时长 | 300ms/段 |
| 发光强度 | 0.6-1.0（随积累增加） |
| 满槽特效 | 脉冲发光 |

#### 2.3.3 视觉效果

```typescript
// 剑气等级配置
interface SwordEnergyLevel {
  level: number;        // 等级（0-4）
  percent: number;      // 百分比
  color: string;        // 颜色
  glowIntensity: number;// 发光强度
  effect: string;       // 特效名称
}

const energyLevels: SwordEnergyLevel[] = [
  { level: 0, percent: 0, color: '#636E72', glowIntensity: 0, effect: 'none' },
  { level: 1, percent: 25, color: '#74B9FF', glowIntensity: 0.3, effect: 'weak' },
  { level: 2, percent: 50, color: '#0984E3', glowIntensity: 0.5, effect: 'medium' },
  { level: 3, percent: 75, color: '#6C5CE7', glowIntensity: 0.8, effect: 'strong' },
  { level: 4, percent: 100, color: '#FD79A8', glowIntensity: 1.0, effect: 'full' }
];
```

#### 2.3.4 ArkTS代码模板

```typescript
/**
 * 剑气槽组件
 * @component SwordEnergyBar
 * @description 展示剑气积累，支持充能动画和满槽特效
 */
@Component
export struct SwordEnergyBar {
  // 当前剑气值（0-100）
  @Prop currentEnergy: number;
  // 最大剑气值
  @Prop maxEnergy: number = 100;
  // 是否满槽
  @Prop isFull: boolean = false;
  // 宽度
  @Prop barWidth: number = 280;
  // 高度
  @Prop barHeight: number = 24;

  // 内部状态
  @State private displayEnergy: number = 0;
  @State private pulseScale: number = 1.0;
  @State private glowIntensity: number = 0;

  // 计算当前等级
  getCurrentLevel(): number {
    const percent = (this.displayEnergy / this.maxEnergy) * 100;
    if (percent >= 100) return 4;
    if (percent >= 75) return 3;
    if (percent >= 50) return 2;
    if (percent >= 25) return 1;
    return 0;
  }

  // 获取颜色
  getBarColor(): string {
    const level = this.getCurrentLevel();
    const colors = ['#636E72', '#74B9FF', '#0984E3', '#6C5CE7', '#FD79A8'];
    return colors[Math.min(level, colors.length - 1)];
  }

  // 脉冲动画（满槽时）
  startPulseAnimation(): void {
    if (!this.isFull) return;

    animateTo({
      duration: 800,
      iterations: -1,
      curve: Curve.EaseInOut
    }, () => {
      this.pulseScale = 1.05;
    });
  }

  aboutToAppear(): void {
    this.displayEnergy = this.currentEnergy;
    if (this.isFull) {
      this.startPulseAnimation();
    }
  }

  build() {
    Stack() {
      // 背景槽
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(45, 52, 54, 0.8)')
        .borderRadius(12);

      // 分段标记线
      Row({ space: 0 }) {
        ForEach([1, 2, 3], (index: number) => {
          Column()
            .width(2)
            .height('60%')
            .backgroundColor('rgba(255,255,255,0.2)');
        });
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly);

      // 剑气填充
      Row()
        .height('100%')
        .width(`${(this.displayEnergy / this.maxEnergy) * 100}%`)
        .backgroundColor(this.getBarColor())
        .borderRadius(12)
        .shadow({
          radius: 10,
          color: this.getBarColor(),
          offsetY: 0,
          offsetX: 0,
          opacity: this.glowIntensity
        })
        .animation({
          duration: 300,
          curve: Curve.EaseOut
        });

      // 发光效果层
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor(this.getBarColor())
        .opacity(this.glowIntensity * 0.3)
        .blur(8)
        .borderRadius(12);

      // 满槽脉冲框
      if (this.isFull) {
        Row()
          .width('100%')
          .height('100%')
          .border({
            width: 2,
            color: '#FD79A8',
            style: BorderStyle.Dashed
          })
          .borderRadius(12)
          .scale({ x: this.pulseScale, y: this.pulseScale });
      }
    }
    .width(this.barWidth)
    .height(this.barHeight)
    .onClick(() => {
      // 点击可查看剑气说明
    });
  }
}
```

### 2.4 技能按钮组件

#### 2.4.1 组件概述

技能按钮是战斗界面的主要交互元素，玩家通过点击技能按钮释放各种战斗技能。技能按钮需要清晰展示技能图标、冷却状态、快捷键绑定和当前可用状态。设计采用"图标为主、文字为辅"的布局原则，确保玩家在紧张战斗中能够快速识别和操作。

技能按钮支持四种状态：就绪（可使用）、冷却中（倒计时）、选中（已按下）和禁用（不可用）。不同状态通过透明度变化、遮罩层和倒计时数字进行区分。

#### 2.4.2 设计规格

| 属性 | 规格值 |
|------|--------|
| 按钮尺寸 | 72×72px（可缩放） |
| 图标区域 | 48×48px |
| 圆角半径 | 12px |
| 边框宽度 | 2px |
| 冷却倒计时 | 居中显示，字号16px |
| 热键提示 | 左下角10×10px |

#### 2.4.3 技能按钮状态

| 状态 | 视觉表现 | 交互表现 |
|------|----------|----------|
| 就绪 | 100%不透明度，边框高亮 | 可点击，有波纹效果 |
| 冷却中 | 灰色遮罩，倒计时数字 | 不可点击 |
| 选中 | 缩放0.95，按压效果 | 释放技能 |
| 禁用 | 50%透明度，灰化 | 不可点击 |

#### 2.4.4 ArkTS代码模板

```typescript
/**
 * 技能按钮组件
 * @component SkillButton
 * @description 战斗技能按钮，支持冷却动画和状态管理
 */
@Component
export struct SkillButton {
  // 技能ID
  @Prop skillId: string;
  // 技能图标
  @Prop skillIcon: Resource;
  // 技能名称
  @Prop skillName: string;
  // 冷却时间（秒）
  @Prop cooldownTime: number;
  // 当前冷却剩余（秒）
  @Prop currentCooldown: number;
  // 热键提示
  @Prop hotkey: string;
  // 技能类型
  @Prop skillType: 'normal' | 'skill' | 'ultimate';
  // 按钮状态
  @Prop state: 'ready' | 'cooldown' | 'pressed' | 'disabled';
  // 点击事件
  onClick?: (skillId: string) => void;

  // 内部状态
  @State private isPressed: boolean = false;
  @State private cooldownPercent: number = 0;

  // 计算冷却百分比
  getCooldownPercent(): number {
    if (this.cooldownTime <= 0) return 0;
    return (this.currentCooldown / this.cooldownTime) * 100;
  }

  // 获取边框颜色
  getBorderColor(): string {
    const colors = {
      'normal': '#636E72',
      'skill': '#0984E3',
      'ultimate': '#FD79A8'
    };
    return colors[this.skillType];
  }

  build() {
    Stack() {
      // 按钮背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.state === 'disabled' ? '#2D3436' : '#1A1A1A')
        .border({
          width: 2,
          color: this.state === 'ready' ? this.getBorderColor() : '#2D3436',
          radius: 12,
          style: BorderStyle.Solid
        })
        .scale({ x: this.isPressed ? 0.95 : 1.0 })
        .animation({
          duration: 100,
          curve: Curve.EaseOut
        });

      // 技能图标
      Image(this.skillIcon)
        .width(48)
        .height(48)
        .objectFit(ImageFit.Contain)
        .opacity(this.state === 'disabled' ? 0.4 : 1);

      // 冷却遮罩
      if (this.state === 'cooldown') {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.7)')
          .borderRadius(12);

        // 冷却倒计时
        Text(Math.ceil(this.currentCooldown).toString())
          .fontSize(16)
          .fontColor('#F5F5F5')
          .fontWeight(FontWeight.Bold);

        // 冷却进度弧形
        Canvas(this)
          .width(72)
          .height(72)
          .onReady((render: RenderingContext) => {
            const centerX = 36;
            const centerY = 36;
            const radius = 30;
            const startAngle = -Math.PI / 2;
            const endAngle = startAngle + (Math.PI * 2 * this.getCooldownPercent() / 100);

            render.clearRect(0, 0, 72, 72);
            render.beginPath();
            render.arc(centerX, centerY, radius, 0, Math.PI * 2);
            render.strokeStyle = 'rgba(255,255,255,0.1)';
            render.lineWidth = 4;
            render.stroke();

            render.beginPath();
            render.arc(centerX, centerY, radius, startAngle, endAngle);
            render.strokeStyle = '#F5F5F5';
            render.lineWidth = 4;
            render.lineCap = LineCap.Round;
            render.stroke();
          });
      }

      // 热键提示
      if (this.hotkey && this.state === 'ready') {
        Text(this.hotkey)
          .fontSize(10)
          .fontColor('#F5F5F5')
          .backgroundColor('#2D3436')
          .padding({ left: 4, right: 4, top: 2, bottom: 2 })
          .borderRadius(4)
          .position({ x: 4, y: 4 });
      }

      // 选中状态指示
      if (this.state === 'pressed') {
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
    }
    .width(72)
    .height(72)
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true;
      } else if (event.type === TouchType.Up) {
        this.isPressed = false;
        if (this.state === 'ready' && this.onClick) {
          this.onClick(this.skillId);
        }
      }
    });
  }
}
```

### 2.5 连击计数器组件

#### 2.5.1 组件概述

连击计数器用于展示当前连击数，是战斗界面中最具视觉冲击力的动态元素。当玩家连续击中敌人时，连击数会持续增加，计数器通过动态缩放、颜色变化和粒子特效增强打击感和成就感。高连击数还能触发连击加成，提升伤害输出。

连击计数器采用"数字+文字"的组合形式，数字展示连击次数，文字标识连击等级。连击数归零时通过灰化动画过渡，积累时通过脉冲动画强调。

#### 2.5.2 设计规格

| 属性 | 规格值 |
|------|--------|
| 基础字号 | 32px（动态缩放48px） |
| 连击等级 | 3级（普通、强力、狂暴） |
| 动画时长 | 150ms（出现/消失） |
| 缩放范围 | 1.0-1.5倍 |
| 位置 | 屏幕中央偏上 |

#### 2.5.3 连击等级定义

```typescript
interface ComboLevel {
  level: number;        // 等级
  minCombo: number;     // 最小连击数
  name: string;         // 等级名称
  color: string;        // 颜色
  scale: number;        // 缩放比例
  multiplier: number;   // 伤害加成
}

const comboLevels: ComboLevel[] = [
  { level: 1, minCombo: 1, name: '连击', color: '#F5F5F5', scale: 1.0, multiplier: 1.0 },
  { level: 2, minCombo: 10, name: '连击', color: '#F39C12', scale: 1.2, multiplier: 1.2 },
  { level: 3, minCombo: 20, name: '狂连击', color: '#D63031', scale: 1.5, multiplier: 1.5 }
];
```

#### 2.5.4 ArkTS代码模板

```typescript
/**
 * 连击计数器组件
 * @component ComboCounter
 * @description 展示当前连击数，支持动态缩放和等级特效
 */
@Component
export struct ComboCounter {
  // 当前连击数
  @Prop currentCombo: number;
  // 最大连击数（用于进度条）
  @Prop maxCombo: number = 30;
  // 连击等级
  @Prop comboLevel: number = 1;

  // 内部状态
  @State private displayCombo: number = 0;
  @State private scale: number = 1.0;
  @State private pulseCount: number = 0;

  // 获取当前等级配置
  getComboLevelConfig(): ComboLevel {
    if (this.comboLevel >= 3) return comboLevels[2];
    if (this.comboLevel >= 2) return comboLevels[1];
    return comboLevels[0];
  }

  // 连击数变化动画
  updateDisplayCombo(newCombo: number): void {
    animateTo({
      duration: 150,
      curve: Curve.EaseOut
    }, () => {
      this.displayCombo = newCombo;
      this.scale = 1.3;
    });

    // 缩放回弹
    setTimeout(() => {
      animateTo({
        duration: 200,
        curve: Curve.ElasticOut
      }, () => {
        this.scale = this.getComboLevelConfig().scale;
      });
    }, 150);
  }

  aboutToAppear(): void {
    this.displayCombo = this.currentCombo;
    this.scale = this.getComboLevelConfig().scale;
  }

  build() {
    Column({ space: 4 }) {
      // 连击数字
      Text(this.displayCombo.toString())
        .fontSize(48)
        .fontColor(this.getComboLevelConfig().color)
        .fontWeight(FontWeight.Bold)
        .scale({ x: this.scale, y: this.scale })
        .shadow({
          radius: 20,
          color: this.getComboLevelConfig().color,
          offsetY: 0,
          offsetX: 0
        })
        .animation({
          duration: 200,
          curve: Curve.EaseOut
        });

      // 连击等级文字
      Text(this.getComboLevelConfig().name)
        .fontSize(14)
        .fontColor(this.getComboLevelConfig().color)
        .fontWeight(FontWeight.Medium)
        .letterSpacing(4);

      // 连击加成提示
      if (this.getComboLevelConfig().multiplier > 1) {
        Text(`伤害x${this.getComboLevelConfig().multiplier}`)
          .fontSize(12)
          .fontColor('#F39C12')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('rgba(243, 156, 18, 0.2)')
          .borderRadius(4);
      }
    }
    .opacity(this.currentCombo > 0 ? 1 : 0)
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    });
  }
}
```

### 2.6 角色选择器组件

#### 2.6.1 组件概述

角色选择器是游戏主界面的核心导航组件，玩家通过选择器选择要使用的角色进入战斗。选择器采用Grid网格布局展示12个角色，每个角色以头像框形式呈现。设计强调快速识别和流畅选择，通过阵营分组和筛选功能提升选择效率。

选择器支持多种交互模式：单个点击选择、长按查看详情、拖动浏览更多。选中角色后高亮显示，并展示角色简略属性（职业、难度评级）。

#### 2.6.2 设计规格

| 属性 | 规格值 |
|------|--------|
| 网格列数 | 4列（手机）/ 6列（平板） |
| 角色间距 | 16px |
| 每行角色数 | 4-6个 |
| 滚动方向 | 水平滚动 |
| 分组标题 | 按阵营分组 |

#### 2.6.3 ArkTS代码模板

```typescript
/**
 * 角色选择器组件
 * @component CharacterSelector
 * @description 网格布局的角色选择界面，支持阵营筛选
 */
@Component
export struct CharacterSelector {
  // 角色列表
  @Prop characters: CharacterData[];
  // 当前选中角色
  @Prop selectedCharacterId: string;
  // 筛选阵营
  @Prop filterFaction: string | null;
  // 点击事件
  onCharacterSelect?: (characterId: string) => void;
  // 长按事件
  onCharacterLongPress?: (characterId: string) => void;

  // 内部状态
  @State private filter: string | null = null;

  // 获取筛选后的角色列表
  getFilteredCharacters(): CharacterData[] {
    if (!this.filter) return this.characters;
    return this.characters.filter(c => c.faction === this.filter);
  }

  // 按阵营分组
  getCharactersByFaction(): Map<string, CharacterData[]> {
    const grouped = new Map<string, CharacterData[]>();
    const filtered = this.getFilteredCharacters();

    filtered.forEach(char => {
      if (!grouped.has(char.faction)) {
        grouped.set(char.faction, []);
      }
      grouped.get(char.faction)!.push(char);
    });

    return grouped;
  }

  build() {
    Column({ space: 16 }) {
      // 阵营筛选器
      Row({ space: 8 }) {
        FilterChip({
          label: '全部',
          isSelected: this.filter === null,
          onClick: () => { this.filter = null; }
        });

        ForEach(['daoist', 'buddhist', 'confucian', 'militarist'], (faction: string) => {
          FilterChip({
            label: this.getFactionName(faction),
            isSelected: this.filter === faction,
            faction: faction,
            onClick: () => { this.filter = faction; }
          });
        });
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .scrollable(ScrollDirection.Horizontal);

      // 角色网格
      Scroll() {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
          ForEach(this.getFilteredCharacters(), (character: CharacterData) => {
            CharacterAvatar({
              characterId: character.id,
              avatarResource: character.avatar,
              faction: character.faction,
              state: character.id === this.selectedCharacterId ? 'selected' : 'default',
              onClick: (id: string) => {
                if (this.onCharacterSelect) {
                  this.onCharacterSelect(id);
                }
              }
            })
            .onLongPress(() => {
              if (this.onCharacterLongPress) {
                this.onCharacterLongPress(character.id);
              }
            })
            .margin({ right: 16, bottom: 16 });
          });
        }
      }
      .width('100%')
      .height('100%');
    }
    .width('100%')
    .height('100%');
  }

  getFactionName(faction: string): string {
    const names = {
      'daoist': '道家',
      'buddhist': '佛家',
      'confucian': '儒家',
      'militarist': '兵家'
    };
    return names[faction] || faction;
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
    const colors = {
      'daoist': '#2E86AB',
      'buddhist': '#D64933',
      'confucian': '#3D5A80',
      'militarist': '#1B4332'
    };
    return colors[this.faction];
  }
}
```

### 2.7 难度选择器组件

#### 2.7.1 组件概述

难度选择器用于设置AI对手的挑战等级，游戏提供4级难度供玩家选择。难度选择器采用卡片式布局，每个难度等级展示难度名称、推荐战力、敌人属性加成和特色标签。设计强调难度差异的直观传达，帮助玩家选择适合自己的挑战等级。

难度等级从简单到困难分别为：初入江湖（简单）、小有所成（普通）、炉火纯青（困难）、登峰造极（专家）。每个难度对应不同的AI行为参数和敌人属性倍率。

#### 2.7.2 设计规格

| 属性 | 规格值 |
|------|--------|
| 卡片宽度 | 280px（手机）/ 320px（平板） |
| 卡片高度 | 160px |
| 卡片间距 | 16px |
| 难度等级 | 4级 |
| 推荐位置 | 水平居中 |

#### 2.7.3 难度配置数据

```typescript
interface DifficultyConfig {
  level: number;
  name: string;
  description: string;
  enemyMultiplier: number;  // 敌人属性倍率
  aiAggression: number;     // AI攻击性 (0-1)
  aiDefensive: number;      // AI防御性 (0-1)
  tags: string[];
  color: string;
}

const difficultyConfigs: DifficultyConfig[] = [
  {
    level: 1,
    name: '初入江湖',
    description: '适合新手玩家熟悉操作',
    enemyMultiplier: 0.8,
    aiAggression: 0.3,
    aiDefensive: 0.3,
    tags: ['入门', '练习'],
    color: '#00B894'
  },
  {
    level: 2,
    name: '小有所成',
    description: '标准的战斗体验',
    enemyMultiplier: 1.0,
    aiAggression: 0.5,
    aiDefensive: 0.5,
    tags: ['标准', '挑战'],
    color: '#FDCB6E'
  },
  {
    level: 3,
    name: '炉火纯青',
    description: '需要熟练技巧应对',
    enemyMultiplier: 1.2,
    aiAggression: 0.7,
    aiDefensive: 0.7,
    tags: ['困难', '进阶'],
    color: '#E17055'
  },
  {
    level: 4,
    name: '登峰造极',
    description: '极致挑战，AI会使用连招',
    enemyMultiplier: 1.5,
    aiAggression: 0.9,
    aiDefensive: 0.9,
    tags: ['专家', '极限'],
    color: '#D63031'
  }
];
```

#### 2.7.4 ArkTS代码模板

```typescript
/**
 * 难度选择器组件
 * @component DifficultySelector
 * @description 选择AI难度等级，展示难度信息
 */
@Component
export struct DifficultySelector {
  // 当前难度等级
  @Prop currentDifficulty: number;
  // 可选难度列表
  @Prop difficulties: DifficultyConfig[];
  // 难度选择事件
  onDifficultySelect?: (level: number) => void;

  build() {
    Column({ space: 24 }) {
      // 标题
      Text('选择挑战难度')
        .fontSize(20)
        .fontColor('#F5F5F5')
        .fontWeight(FontWeight.Bold);

      // 难度卡片列表
      Column({ space: 12 }) {
        ForEach(this.difficulties, (difficulty: DifficultyConfig) => {
          DifficultyCard({
            config: difficulty,
            isSelected: difficulty.level === this.currentDifficulty,
            onSelect: () => {
              if (this.onDifficultySelect) {
                this.onDifficultySelect(difficulty.level);
              }
            }
          });
        });
      }
      .width('100%');
    }
    .width('100%')
    .padding(20);
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
    Column({ space: 8 }) {
      // 卡片头部
      Row() {
        // 难度名称
        Text(this.config.name)
          .fontSize(18)
          .fontColor(this.isSelected ? '#1A1A1A' : '#F5F5F5')
          .fontWeight(FontWeight.Bold);

        // 选中指示器
        if (this.isSelected) {
          Text('✓')
            .fontSize(16)
            .fontColor('#1A1A1A');
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);

      // 难度描述
      Text(this.config.description)
        .fontSize(12)
        .fontColor(this.isSelected ? '#2D3436' : '#B2BEC3')
        .width('100%');

      // 属性加成信息
      Row({ space: 16 }) {
        StatItem({
          label: '敌人属性',
          value: `${Math.round(this.config.enemyMultiplier * 100)}%`,
          color: this.config.color
        });
        StatItem({
          label: 'AI攻击性',
          value: `${Math.round(this.config.aiAggression * 100)}%`,
          color: this.config.color
        });
      }
      .width('100%');

      // 标签
      Row({ space: 8 }) {
        ForEach(this.config.tags, (tag: string) => {
          Text(tag)
            .fontSize(10)
            .fontColor(this.isSelected ? '#1A1A1A' : this.config.color)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor(this.isSelected ?
              'rgba(255,255,255,0.9)' :
              `${this.config.color}33`)
            .borderRadius(4);
        });
      }
      .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.isSelected ? this.config.color : 'rgba(45,52,54,0.8)')
    .borderRadius(12)
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
 * 属性项组件
 */
@Component
struct StatItem {
  @Prop label: string;
  @Prop value: string;
  @Prop color: string;

  build() {
    Column({ space: 2 }) {
      Text(this.label)
        .fontSize(10)
        .fontColor('#B2BEC3');
      Text(this.value)
        .fontSize(14)
        .fontColor(this.color)
        .fontWeight(FontWeight.Bold);
    }
    .alignItems(HorizontalAlign.Start);
  }
}
```

---

## 3. 界面布局规范

### 3.1 折叠屏适配策略

折叠屏设备是本游戏的重要目标平台，需要针对不同折叠状态提供优化的界面布局。设计采用"渐进式适配"策略，单屏模式保持紧凑布局，双屏展开模式利用额外空间增强信息展示和交互体验。

设备状态定义如下：折叠状态（Folded）指屏幕完全折叠，仅使用主屏幕显示；半折状态（Half-folded）指屏幕展开至90-120度，上屏显示游戏画面，下屏显示UI控件；展开状态（Unfolded）指屏幕完全展开，使用双屏联合显示内容。

#### 3.1.1 屏幕尺寸基准

| 设备状态 | 屏幕宽度 | 屏幕高度 | 宽高比 |
|----------|----------|----------|--------|
| 手机竖屏 | 360px | 780px | 9:19.5 |
| 手机横屏 | 780px | 360px | 19.5:9 |
| 折叠单屏 | 408px | 880px | 10.2:22 |
| 折叠双屏 | 816px | 880px | 10.2:22 |

#### 3.1.2 布局断点系统

```typescript
// 布局断点配置
interface LayoutBreakpoints {
  name: string;
  minWidth: number;
  maxWidth: number;
  columns: number;
  spacing: LayoutSpacing;
}

const breakpoints: LayoutBreakpoints[] = [
  {
    name: 'mobile',
    minWidth: 0,
    maxWidth: 599,
    columns: 4,
    spacing: { sm: 8, md: 12, lg: 16 }
  },
  {
    name: 'tablet',
    minWidth: 600,
    maxWidth: 839,
    columns: 6,
    spacing: { sm: 12, md: 16, lg: 24 }
  },
  {
    name: 'desktop',
    minWidth: 840,
    maxWidth: Infinity,
    columns: 8,
    spacing: { sm: 16, md: 24, lg: 32 }
  }
];
```

### 3.2 战斗界面布局

战斗界面是游戏的核心交互场景，界面布局需要平衡信息展示和画面观感。设计将界面划分为多个功能区域：顶部状态区显示双方生命值和剑气槽，底部操作区放置技能按钮，中央区域留给游戏画面。

#### 3.2.1 战斗界面布局图

```
┌─────────────────────────────────────────────────────────────┐
│  ┌──────────────────┐                    ┌────────────────┐ │
│  │  玩家名称         │                    │   敌人名称      │ │
│  │ [████████████]   │                    │  [████████]    │ │
│  │ HP: 1000/1000    │                    │  HP: 800/800   │ │
│  └──────────────────┘                    └────────────────┘ │
│                                                             │
│                    ┌────────────────┐                       │
│                    │    剑气槽       │                       │
│                    │ [████████████]  │                       │
│                    └────────────────┘                       │
│                                                             │
│                              ┌─────────────────┐            │
│                              │     连击: 12    │            │
│                              │    伤害x1.2     │            │
│                              └─────────────────┘            │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │                    游戏画面                         │   │
│  │                  (Canvas渲染区域)                   │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐       │
│  │ [技能1] │  │ [技能2] │  │ [技能3] │  │ [技能4] │       │
│  │   Q     │  │   W     │  │   E     │  │   R     │       │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘       │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  移动摇杆        防御      冲刺      必杀           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### 3.2.2 战斗界面区域规格

| 区域 | 位置 | 高度/宽度 | 关键元素 |
|------|------|-----------|----------|
| 顶部状态区 | 屏幕顶部 | 120px | 玩家血条、敌人血条、剑气槽 |
| 连击显示区 | 屏幕中上方 | 80px | 连击数字、伤害加成 |
| 游戏画面区 | 屏幕中央 | 自适应 | Canvas渲染区域 |
| 技能操作区 | 屏幕底部 | 100px | 技能按钮、虚拟摇杆 |
| 底部控制区 | 屏幕最底部 | 60px | 移动、防御、冲刺按钮 |

### 3.3 主菜单界面布局

主菜单界面是玩家进入游戏的第一印象，布局设计强调气势感和仪式感。设计采用"中心辐射"布局，主视觉居中展示游戏Logo和主题元素，功能入口环绕周围。折叠屏展开状态下，可利用双屏优势将Logo和功能入口分屏展示。

#### 3.3.1 主菜单布局规格

| 设备状态 | 主Logo区 | 功能入口区 | 底部信息区 |
|----------|----------|------------|------------|
| 手机竖屏 | 屏幕上方40% | 屏幕中部40% | 屏幕底部20% |
| 手机横屏 | 屏幕左方40% | 屏幕右方60% | 底部横条 |
| 折叠双屏 | 左屏全屏 | 右屏全屏 | 底部横条 |

### 3.4 角色选择界面布局

角色选择界面采用Grid网格布局展示所有可用角色，支持阵营筛选和滚动浏览。界面顶部设置筛选器和搜索功能，中部为主内容区域展示角色卡片，底部显示确认和返回按钮。

```typescript
// 角色选择界面布局配置
interface CharacterSelectionLayout {
  columns: number;
  rows: number;
  itemSpacing: number;
  headerHeight: number;
  footerHeight: number;
}

const characterSelectionLayout: Record<string, CharacterSelectionLayout> = {
  mobile: {
    columns: 4,
    rows: 3,
    itemSpacing: 12,
    headerHeight: 80,
    footerHeight: 60
  },
  tablet: {
    columns: 6,
    rows: 3,
    itemSpacing: 16,
    headerHeight: 100,
    footerHeight: 80
  },
  foldable: {
    columns: 8,
    rows: 3,
    itemSpacing: 20,
    headerHeight: 120,
    footerHeight: 80
  }
};
```

### 3.5 结算界面布局

结算界面展示战斗结果，包括胜负判定、奖励结算和数据统计。布局采用"上中下"三层结构：上层显示胜负结果和评级，中层展示获得的经验、金币和道具奖励，下层显示战斗数据和返回按钮。

---

## 4. 动效设计规范

### 4.1 动效设计原则

游戏动效设计遵循"有意义、有节奏、有反馈"三大原则。有意义指每个动效都服务于明确的交互目的或视觉表达，不添加无意义的装饰动画；有节奏指动效时长和曲线与交互重要性和物理规律相匹配，点击反馈快速简短，状态切换平滑过渡；有反馈指通过动效为玩家操作提供即时、明确的响应确认。

动效性能是移动游戏的关键考量，所有动效均需在60fps下流畅运行。复杂动效采用GPU加速，避免触发布局重计算（Reflow）。粒子效果等重量级动效需提供性能开关，允许玩家根据设备性能进行调整。

### 4.2 缓动函数

缓动函数（Easing Functions）控制动画随时间的变化速率，是动的关键因素。本游戏采用以下标准效质感缓动函数：

| 缓动类型 | 曲线函数 | 适用场景 |
|----------|----------|----------|
| EaseOutQuad | t*(2-t) | 按钮点击、元素消失 |
| EaseInOutCubic | t<.5?4*t^3:(t-1)*(2*t-2)*(2*t-2)+1 | 元素出现、状态切换 |
| ElasticOut | 弹性算法 | 连击数字、成就达成 |
| EaseInOutQuad | t<.5?2*t*t:-1+(4-2*t)*t | 平滑移动、尺寸变化 |
| Linear | t | 进度条、持续动画 |

```typescript
// 缓动函数配置
const easingFunctions = {
  easeOutQuad: (t: number): number => t * (2 - t),
  easeInOutCubic: (t: number): number => t < 0.5 ?
    4 * t * t * t :
    (t - 1) * (2 * t - 2) * (2 * t - 2) + 1,
  easeInOutQuad: (t: number): number => t < 0.5 ?
    2 * t * t :
    -1 + (4 - 2 * t) * t,
  elasticOut: (t: number): number => {
    const p = 0.3;
    return Math.pow(2, -10 * t) * Math.sin((t - p / 4) * (2 * Math.PI) / p) + 1;
  }
};
```

### 4.3 技能冷却动画

技能冷却动画通过弧形进度条和倒计时数字展示冷却状态。动画从满冷却开始，逐步减少至零，同时数字倒计时同步变化。冷却完成时触发闪光特效提示玩家技能可用。

| 动画阶段 | 时长 | 缓动函数 | 视觉效果 |
|----------|------|----------|----------|
| 冷却进度减少 | 按冷却时间动态 | Linear | 弧形进度条逆时针减少 |
| 倒计时数字 | 按冷却时间动态 | Linear | 数字每秒递减 |
| 冷却完成闪光 | 200ms | EaseOut | 白色闪光渐隐 |

```typescript
// 技能冷却动画配置
const cooldownAnimation = {
  duration: 200,           // 闪光动画时长(ms)
  curve: Curve.EaseOut,    // 缓动函数
  iterations: 1,           // 动画次数
  flashColor: '#FFFFFF'    // 闪光颜色
};
```

### 4.4 剑气积累动画

剑气积累动画展示剑气值从0到100%的充能过程。动画采用分段式设计，每积累25%剑气触发一次阶段性特效，满槽时触发最强的脉冲光效。填充动画配合流动光效，模拟剑气在槽中流动的视觉效果。

| 动画阶段 | 时长 | 缓动函数 | 视觉效果 |
|----------|------|----------|----------|
| 填充动画 | 300ms/段 | EaseOutCubic | 光效从下向上流动 |
| 阶段特效 | 150ms | EaseOut | 阶段性闪光 |
| 满槽脉冲 | 800ms | ElasticOut | 边框脉冲发光 |

### 4.5 受击闪红效果

受击闪红效果在角色受到伤害时触发，通过红色遮罩层和数值跳动传达伤害信息。设计采用"闪烁-渐隐"的双阶段动画：瞬间的高强度闪烁提供即时反馈，随后渐隐的红色遮罩延长视觉停留时间。

```typescript
// 受击闪红动画配置
const hitFlashAnimation = {
  flash: {
    duration: 100,         // 闪烁时长(ms)
    iterations: 3,         // 闪烁次数
    opacity: 0.6           // 闪烁透明度
  },
  fade: {
    duration: 300,         // 渐隐时长(ms)
    curve: Curve.EaseOut   // 缓动函数
  },
  damageNumber: {
    duration: 800,         // 飘字总时长
    moveDistance: 50,      // 向上飘动距离
    fadeDelay: 400         // 渐隐开始时间
  }
};
```

### 4.6 角色死亡灰化效果

角色死亡时通过灰化滤镜和透明度渐变展示死亡状态。死亡动画分为三个阶段：受击闪红后角色进入"濒死"状态（红色闪烁），随后触发死亡动画（灰化滤镜+透明度下降），最终定格为灰色半透明状态。

| 动画阶段 | 时长 | 缓动函数 | 视觉效果 |
|----------|------|----------|----------|
| 濒死警告 | 300ms | EaseOut | 红色快速闪烁 |
| 死亡过渡 | 500ms | EaseIn | 灰化滤镜渐显 |
| 死亡定格 | - | - | 50%透明度灰色 |

### 4.7 胜利结算动画

胜利结算动画是战斗结束后的高潮环节，通过多阶段的动画序列展示战斗成果和奖励信息。动画设计注重节奏感和仪式感，从结果揭示到奖励展示层层递进。

```typescript
// 胜利结算动画配置
const victoryAnimation = {
  reveal: {
    duration: 500,
    delay: 0,
    curve: Curve.EaseOut
  },
  stars: {
    duration: 300,
    delay: 500,
    stagger: 150,
    curve: Curve.EaseOut
  },
  stats: {
    duration: 400,
    delay: 1200,
    stagger: 100,
    curve: Curve.EaseOut
  },
  rewards: {
    duration: 500,
    delay: 2000,
    stagger: 200,
    curve: Curve.EaseOut
  },
  total: {
    duration: 800,
    delay: 3000,
    curve: Curve.EaseInOut
  }
};
```

#### 4.7.1 胜利动画时间线

| 时间点 | 动画内容 | 持续时间 |
|--------|----------|----------|
| 0ms | 胜利文字渐显 | 500ms |
| 500ms | 星级评定逐个出现 | 900ms |
| 1400ms | 战斗统计数据滚动 | 1200ms |
| 2600ms | 奖励道具逐个展示 | 1500ms |
| 4100ms | 结算按钮出现 | 500ms |

### 4.8 通用动效参数

以下为通用UI动效的标准参数，所有组件应遵循此规范以保证动效一致性：

| 动效类型 | 默认时长 | 快速版时长 | 慢速版时长 | 缓动函数 |
|----------|----------|------------|------------|----------|
| 按钮点击 | 100ms | 50ms | 200ms | EaseOutQuad |
| 元素出现 | 300ms | 150ms | 500ms | EaseOutCubic |
| 元素消失 | 200ms | 100ms | 400ms | EaseInQuad |
| 状态切换 | 250ms | 150ms | 400ms | EaseInOutCubic |
| 尺寸变化 | 300ms | 150ms | 500ms | EaseInOutQuad |
| 位置移动 | 350ms | 200ms | 600ms | EaseInOutQuad |
| 透明度变化 | 300ms | 150ms | 500ms | Linear |
| 缩放效果 | 300ms | 150ms | 500ms | ElasticOut |
| 旋转效果 | 400ms | 200ms | 700ms | EaseInOutSine |
| 颜色变化 | 300ms | 150ms | 500ms | Linear |

---

## 5. 组件代码模板规范

### 5.1 ArkTS组件结构标准

所有UI组件应遵循统一的代码结构标准，确保代码可读性和可维护性。组件结构包含以下标准区块：组件注释、导入语句、接口定义、组件类定义和构建方法。

```typescript
/**
 * 组件名称
 * @component ComponentName
 * @description 组件功能描述
 * @example 使用示例
 */
@Component
export struct ComponentName {
  // Props - 从外部传入的数据
  @Prop prop1: string;
  @Prop prop2: number = 0;
  @Prop prop3: boolean = false;

  // State - 内部状态
  @State state1: string = '';
  @State state2: number = 0;

  // Links - 与父组件双向绑定的数据
  @Link linkData: SomeType;

  // Controllers - 控制器
  private myController: MyController = new MyController();

  // 生命周期回调
  aboutToAppear(): void {
    // 初始化逻辑
  }

  aboutToDisappear(): void {
    // 清理逻辑
  }

  // 私有方法
  private handleAction(): void {
    // 处理逻辑
  }

  // 构建方法
  build() {
    // UI结构
  }
}
```

### 5.2 组件命名规范

组件命名采用PascalCase命名法，以功能描述性名称结尾。文件名称与组件名称保持一致，使用kebab-case格式。

| 组件类型 | 命名示例 | 文件名 |
|----------|----------|--------|
| 基础组件 | Button、Avatar、Badge | button.ets、avatar.ets |
| 复合组件 | HealthBar、SwordEnergyBar | health-bar.ets |
| 业务组件 | CharacterSelector、DifficultySelector | character-selector.ets |
| 容器组件 | GameContainer、ModalContainer | game-container.ets |

### 5.3 资源文件规范

资源文件按类型和用途组织在统一的目录结构中，采用语义化的命名方式。

```
/resources/
├── base/
│   ├── color/          # 颜色资源
│   ├── string/         # 字符串资源
│   ├── media/          # 图片资源
│   │   ├── icon/       # 图标
│   │   ├── character/  # 角色资源
│   │   ├── skill/      # 技能资源
│   │   └── effect/     # 特效资源
│   └── font/           # 字体资源
└── rawfile/            # 原始文件
```

### 5.4 样式管理规范

组件样式采用内联样式与自定义样式相结合的方式。基础样式属性在内联定义，可定制的样式属性通过参数传入。

```typescript
// 样式配置接口示例
interface ComponentStyle {
  width?: Length;
  height?: Length;
  backgroundColor?: ResourceColor;
  borderRadius?: Length;
  border?: BorderOptions;
  shadow?: ShadowOptions;
  opacity?: number;
}
```

### 5.5 响应式设计实现

组件应支持响应式布局，通过监听窗口尺寸变化和设备状态调整展示方式。

```typescript
// 响应式配置接口
interface ResponsiveConfig {
  breakpoints: string[];        // 断点列表
  currentBreakpoint: string;    // 当前断点
  designWidth: number;          // 设计基准宽度
  scaleFactor: number;          // 缩放因子
}

// 使用示例
@Component
export struct ResponsiveComponent {
  @StorageProp('currentBreakpoint') breakpoint: string = 'md';
  @StorageProp('windowWidth') windowWidth: number = 360;

  getItemCount(): number {
    switch (this.breakpoint) {
      case 'sm': return 2;
      case 'md': return 4;
      case 'lg': return 6;
      default: return 4;
    }
  }
}
```

### 5.6 无障碍设计规范

所有交互元素应支持无障碍访问，包括内容描述、焦点管理和屏幕阅读器支持。

```typescript
// 无障碍配置示例
Text('按钮文本')
  .width(72)
  .height(72)
  .accessibilityGroup(true)
  .accessibilityLabel('技能按钮')
  .accessibilityHint('点击释放技能')
  .focusable(true);
```

---

## 6. 性能优化规范

### 6.1 渲染性能优化

游戏UI需要在保证视觉效果的同时维持稳定的帧率表现。以下是渲染性能优化的关键策略：

布局优化方面，应避免使用嵌套层级过深的Flex布局，减少布局计算开销。优先使用Stack和Position定位，减少测量和排列次数。对于静态内容，使用Image和Canvas组件而非自定义绘制。

渲染优化方面，复杂动效优先使用GPU加速属性（transform、opacity），避免触发重绘。频繁变化的元素使用willChange提示浏览器优化。减少阴影和模糊效果的使用，这些效果对性能影响较大。

资源优化方面，按需加载图片资源，使用图片懒加载。矢量图标优先转换为位图缓存。动画期间暂停不必要的渲染更新。

### 6.2 内存管理优化

内存管理是移动游戏稳定运行的关键。组件销毁时应及时释放不再使用的资源，避免内存泄漏。

资源释放方面，大型资源（图片、音频）在组件销毁时调用释放方法。避免在循环中创建临时对象和闭包。使用ObjectPool复用频繁创建的对象。

缓存策略方面，常用数据使用LruCache缓存，设置合理的缓存大小限制。纹理资源使用纹理Atlas合并减少采样次数。预加载下一场景所需资源。

---

## 7. 设计验收标准

### 7.1 视觉验收

所有UI组件上线前需通过以下视觉验收标准：

布局验收方面，元素位置符合设计稿公差±2px以内。间距和尺寸符合间距系统规范。响应式布局在所有断点下正常显示。

色彩验收方面，颜色值与设计稿一致（支持不同亮度模式）。状态颜色变化符合规范要求。对比度满足WCAG 2.1 AA级标准（4.5:1）。

动效验收方面，动效时长符合规范要求。缓动曲线自然流畅，无卡顿。性能稳定在目标设备上达到60fps。

### 7.2 交互验收

交互设计验收关注用户体验的流畅性和一致性：

响应验收方面，点击反馈在100ms内出现。状态切换动画不超过300ms。复杂动画期间保持界面可响应。

一致性验收方面，同类操作在不同界面保持一致的行为模式。状态变化的可视化反馈统一。错误状态和成功状态的提示方式统一。

### 7.3 性能验收

性能验收确保游戏在不同设备上都能流畅运行：

帧率验收方面，战斗界面稳定60fps。结算等复杂动效场景不低于45fps。角色选择等静态界面稳定60fps。

内存验收方面，单次游戏会话内存增长不超过100MB。退出战斗后内存恢复正常水平。无内存泄漏导致的内存持续增长。

---

## 附录

### A. 术语表

| 术语 | 定义 |
|------|------|
| 剑气 | 角色积累的能量槽，用于释放终极技能 |
| 阵营 | 角色的所属势力，共4个（道家、佛家、儒家、兵家） |
| 连击 | 连续击中敌人的次数，影响伤害加成 |
| 冷却 | 技能使用后的恢复时间 |
| 折叠屏 | 可折叠的柔性屏幕设备 |

### B. 参考资源

- 游戏设计文档：`docs/plans/2026-01-29-jianlai-fighting-game-design.md`
- 第二阶段设计：`docs/plans/2026-01-29-fighting-game-phase2-design.md`
- 现有代码：`entry/src/main/ets/components/`

### C. 更新日志

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| 1.0 | 2026-01-29 | 初始版本，完整UI设计规范 |

---

*文档结束*
