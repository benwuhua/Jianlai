import { SkillConfig } from '../models/Skill';

const SKILL_ICONS = ['技能1', '技能2', '技能3'];
const ULTIMATE_ICON = '必杀';

@Component
export struct SkillButton {
  @Prop label: string;
  @Prop cooldownRemaining: number = 0;
  @Prop maxCooldown: number = 0;
  @Prop kiCost: number = 0;
  @Prop canUse: boolean = true;
  @Prop isUltimate: boolean = false;
  private onAction: () => void = () => {};

  build() {
    Column() {
      Stack() {
        // 技能按钮背景
        Circle()
          .width(this.isUltimate ? 80 : 60)
          .height(this.isUltimate ? 80 : 60)
          .fill(this.canUse ? (this.isUltimate ? '#E74C3C' : '#4A90E2') : '#333333')
          .stroke(this.isUltimate ? '#FFD700' : '#FFFFFF')
          .strokeWidth(this.isUltimate ? 3 : 2)

        // 冷却遮罩
        if (this.cooldownRemaining > 0) {
          Circle()
            .width(this.isUltimate ? 80 : 60)
            .height(this.isUltimate ? 80 : 60)
            .fill('#000000AA')
            .stroke({
              width: this.isUltimate ? 3 : 2,
              color: this.isUltimate ? '#FFD700' : '#FFFFFF'
            })
        }

        // 技能图标/标签
        Text(this.label)
          .fontSize(this.isUltimate ? 20 : 16)
          .fontColor(this.canUse ? '#FFFFFF' : '#888888')
          .fontWeight(FontWeight.Bold)

        // 冷却时间显示
        if (this.cooldownRemaining > 0) {
          Text(`${this.cooldownRemaining}s`)
            .fontSize(12)
            .fontColor('#FFFFFF')
            .margin({ top: 25 })
        }
      }
      .margin({ bottom: 5 })

      // 剑气消耗
      if (this.kiCost > 0) {
        Text(`${this.kiCost} 剑气`)
          .fontSize(10)
          .fontColor(this.canUse ? '#FFD700' : '#888888')
      }
    }
    .onClick(() => {
      if (this.canUse && this.onAction) {
        this.onAction();
      }
    })
  }
}

@Component
export struct KiBar {
  @Prop currentKi: number = 0;
  @Prop maxKi: number = 100;

  build() {
    Column() {
      Text('剑气')
        .fontSize(14)
        .fontColor('#FFD700')
        .margin({ bottom: 5 })

      Stack() {
        // 剑气槽背景
        Rect()
          .width(200)
          .height(20)
          .fill('#1A1A2E')
          .stroke('#FFD700')
          .strokeWidth(2)
          .borderRadius(10)

        // 当前剑气
        Rect()
          .width(200 * Math.min(1, this.currentKi / this.maxKi))
          .height(20)
          .fill('#FFD700')
          .borderRadius({ topLeft: 10, bottomLeft: 10 })

        // 剑气数值
        Text(`${Math.floor(this.currentKi)}/${this.maxKi}`)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }
    }
    .alignItems(HorizontalAlign.Center)
  }
}

@Component
export struct SkillButtonBar {
  @Prop skills: SkillConfig[] = [];
  @Prop ultimate: SkillConfig | null = null;
  @Prop cooldowns: number[] = [];
  @Prop ultimateCooldown: number = 0;
  @Prop currentKi: number = 0;
  @Prop maxKi: number = 100;
  @Prop canUseSkills: boolean[] = [];
  @Prop canUseUltimate: boolean = false;
  private onSkillPress: (index: number) => void = () => {};
  private onUltimatePress: () => void = () => {};

  build() {
    Column() {
      // 剑气槽
      KiBar({
        currentKi: this.currentKi,
        maxKi: this.maxKi
      })
      .margin({ bottom: 15 })

      // 技能按钮行
      Row() {
        // 3个普通技能
        ForEach(this.skills, (skill: SkillConfig, index: number) => {
          SkillButton({
            label: skill.name.substring(0, 2), // 显示技能名称前2个字
            cooldownRemaining: this.cooldowns[index] || 0,
            maxCooldown: Math.ceil(skill.cooldown / 1000),
            kiCost: skill.kiCost,
            canUse: this.canUseSkills[index],
            isUltimate: false,
            onAction: () => {
              this.onSkillPress(index);
            }
          })
          .margin({ right: 10 })
        })

        Blank()

        // 必杀技按钮
        if (this.ultimate) {
          SkillButton({
            label: ULTIMATE_ICON,
            cooldownRemaining: this.ultimateCooldown,
            maxCooldown: Math.ceil(this.ultimate.cooldown / 1000),
            kiCost: this.ultimate.kiCost,
            canUse: this.canUseUltimate,
            isUltimate: true,
            onAction: () => {
              this.onUltimatePress();
            }
          })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
    .backgroundColor('#1A1A2EAA')
    .borderRadius(15)
  }
}
