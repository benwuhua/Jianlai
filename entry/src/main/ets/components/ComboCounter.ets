/**
 * 连击计数器组件
 * @component ComboCounter
 * @description 展示当前连击数，支持动态缩放和等级特效
 */

// 连击等级配置
interface ComboLevelConfig {
  level: number;
  minCombo: number;
  name: string;
  color: string;
  scale: number;
  multiplier: number;
}

const COMBO_LEVELS: ComboLevelConfig[] = [
  { level: 1, minCombo: 1, name: '连击', color: '#F5F5F5', scale: 1.0, multiplier: 1.0 },
  { level: 2, minCombo: 10, name: '连击', color: '#F39C12', scale: 1.2, multiplier: 1.2 },
  { level: 3, minCombo: 20, name: '狂连击', color: '#D63031', scale: 1.5, multiplier: 1.5 }
];

@Component
export struct ComboCounter {
  // 当前连击数
  @Prop currentCombo: number = 0;
  // 最大连击数（用于进度条显示）
  @Prop maxCombo: number = 30;
  
  // 内部状态
  @State private displayCombo: number = 0;
  @State private scale: number = 1.0;
  @State private opacity: number = 0;
  @State private pulseAnim: number = 0;

  // 获取当前等级配置
  getComboLevel(): ComboLevelConfig {
    for (let i = COMBO_LEVELS.length - 1; i >= 0; i--) {
      if (this.currentCombo >= COMBO_LEVELS[i].minCombo) {
        return COMBO_LEVELS[i];
      }
    }
    return COMBO_LEVELS[0];
  }

  // 连击数变化动画
  updateDisplayCombo(newCombo: number): void {
    if (newCombo > 0 && this.displayCombo === 0) {
      // 从0开始显示
      this.opacity = 1;
    }

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
        this.scale = this.getComboLevel().scale;
      });
    }, 150);
  }

  // 脉冲动画（高连击时）
  startPulseAnimation(): void {
    if (this.currentCombo < 15) return;

    animateTo({
      duration: 500,
      iterations: -1,
      curve: Curve.EaseInOut
    }, () => {
      this.pulseAnim = 1;
    });
  }

  aboutToAppear(): void {
    this.displayCombo = this.currentCombo;
    this.scale = this.getComboLevel().scale;
    if (this.currentCombo > 0) {
      this.opacity = 1;
    }
  }

  aboutToUpdate(props: { propertyName: string; oldValue: number; newValue: number }[]): void {
    for (const prop of props) {
      if (prop.propertyName === 'currentCombo') {
        this.updateDisplayCombo(prop.newValue);
        if (prop.newValue >= 15 && prop.oldValue < 15) {
          this.startPulseAnimation();
        }
      }
    }
  }

  build() {
    Column({ space: 4 }) {
      // 连击数字
      Text(this.displayCombo.toString())
        .fontSize(48)
        .fontColor(this.getComboLevel().color)
        .fontWeight(FontWeight.Bold)
        .scale({ x: this.scale, y: this.scale })
        .shadow({
          radius: 20,
          color: this.getComboLevel().color,
          offsetY: 0,
          offsetX: 0
        })
        .animation({
          duration: 200,
          curve: Curve.EaseOut
        });

      // 连击等级文字
      Text(this.getComboLevel().name)
        .fontSize(14)
        .fontColor(this.getComboLevel().color)
        .fontWeight(FontWeight.Medium)
        .letterSpacing(4);

      // 连击加成提示
      if (this.getComboLevel().multiplier > 1) {
        Text(`伤害x${this.getComboLevel().multiplier}`)
          .fontSize(12)
          .fontColor('#F39C12')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('rgba(243, 156, 18, 0.2)')
          .borderRadius(4);
      }

      // 连击进度条（可选）
      if (this.currentCombo > 0) {
        Row() {
          Progress({
            value: Math.min(this.currentCombo, this.maxCombo),
            total: this.maxCombo,
            type: ProgressType.Linear
          })
            .width('100%')
            .style({ strokeWidth: 3 })
            .color(this.getComboLevel().color)
            .backgroundColor('rgba(255,255,255,0.1)');
        }
        .width(100)
        .height(3)
        .margin({ top: 4 });
      }
    }
    .opacity(this.opacity)
    .scale({ x: 1 + this.pulseAnim * 0.05, y: 1 + this.pulseAnim * 0.05 })
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    });
  }
}

/**
 * 简化版连击指示器（用于战斗界面顶部）
 */
@Component
export struct MiniComboIndicator {
  @Prop currentCombo: number = 0;

  getComboColor(): string {
    if (this.currentCombo >= 20) return '#D63031';
    if (this.currentCombo >= 10) return '#F39C12';
    return '#F5F5F5';
  }

  build() {
    if (this.currentCombo <= 0) return;

    Row({ space: 8 }) {
      Text(this.currentCombo.toString())
        .fontSize(24)
        .fontColor(this.getComboColor())
        .fontWeight(FontWeight.Bold);

      Text('COMBO')
        .fontSize(12)
        .fontColor(this.getComboColor())
        .letterSpacing(2);
    }
    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
    .backgroundColor('rgba(0,0,0,0.6)')
    .borderRadius(16)
    .animation({
      duration: 150,
      curve: Curve.EaseOut
    });
  }
}

/**
 * 连击飘字组件（用于显示伤害数字）
 */
@Component
export struct ComboPopup {
  @Prop damage: number = 0;
  @Prop combo: number = 0;
  @Prop isCrit: boolean = false;
  
  @State private offsetY: number = 0;
  @State private opacity: number = 1;

  aboutToAppear(): void {
    // 向上飘动动画
    animateTo({
      duration: 800,
      curve: Curve.EaseOut
    }, () => {
      this.offsetY = -50;
      this.opacity = 0;
    });
  }

  build() {
    Column({ space: 2 }) {
      if (this.combo > 1) {
        Text(`${this.combo} HIT`)
          .fontSize(14)
          .fontColor('#F39C12')
          .fontWeight(FontWeight.Bold);
      }
      
      Text(`-${this.damage}`)
        .fontSize(this.isCrit ? 28 : 20)
        .fontColor(this.isCrit ? '#D63031' : '#F5F5F5')
        .fontWeight(FontWeight.Bold)
        .shadow({
          radius: 4,
          color: this.isCrit ? '#D63031' : '#000000',
          offsetY: 2
        });
    }
    .offset({ y: this.offsetY })
    .opacity(this.opacity)
    .animation({
      duration: 800,
      curve: Curve.EaseOut
    });
  }
}
