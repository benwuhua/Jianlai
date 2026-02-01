/**
 * 扩展信息面板组件
 * @component InfoPanel
 * @description 单屏/双屏适配的信息展示面板
 */

// 设备状态
type DeviceState = 'mobile' | 'tablet' | 'foldable-single' | 'foldable-dual';

// 面板配置
interface PanelConfig {
  showCharacterInfo: boolean;
  showBattleStats: boolean;
  showSkillInfo: boolean;
  showEnemyInfo: boolean;
}

@Component
export struct InfoPanel {
  // 设备状态
  @Prop deviceState: DeviceState = 'mobile';
  
  // 玩家信息
  @Prop playerName: string = '';
  @Prop playerHp: number = 100;
  @Prop playerMaxHp: number = 100;
  @Prop playerEnergy: number = 0;
  @Prop playerMaxEnergy: number = 100;
  @Prop playerCombo: number = 0;
  
  // 敌人信息
  @Prop enemyName: string = '';
  @Prop enemyHp: number = 100;
  @Prop enemyMaxHp: number = 100;
  
  // 战斗统计
  @Prop battleTime: number = 0;
  @Prop damage = 0;
  @Prop damageDealt: numberTaken: number = 0;
  
  // 面板配置
  @Prop panelConfig: PanelConfig = {
    showCharacterInfo: true,
    showBattleStats: true,
    showSkillInfo: true,
    showEnemyInfo: true
  };

  // 获取面板布局配置
  getLayoutConfig(): PanelConfig {
    switch (this.deviceState) {
      case 'mobile':
        return {
          showCharacterInfo: true,
          showBattleStats: false,
          showSkillInfo: true,
          showEnemyInfo: true
        };
      case 'tablet':
        return {
          showCharacterInfo: true,
          showBattleStats: true,
          showSkillInfo: true,
          showEnemyInfo: true
        };
      case 'foldable-dual':
        return {
          showCharacterInfo: true,
          showBattleStats: true,
          showSkillInfo: true,
          showEnemyInfo: true
        };
      default:
        return this.panelConfig;
    }
  }

  // 获取血条颜色
  getHpColor(): string {
    const percent = (this.playerHp / this.playerMaxHp) * 100;
    if (percent > 50) return '#00B894';
    if (percent > 25) return '#FDCB6E';
    return '#D63031';
  }

  // 获取剑气颜色
  getEnergyColor(): string {
    const percent = (this.playerEnergy / this.playerMaxEnergy) * 100;
    if (percent >= 100) return '#FD79A8';
    if (percent >= 75) return '#6C5CE7';
    if (percent >= 50) return '#0984E3';
    if (percent >= 25) return '#74B9FF';
    return '#636E72';
  }

  // 获取敌人血条颜色
  getEnemyHpColor(): string {
    const percent = (this.enemyHp / this.enemyMaxHp) * 100;
    if (percent > 50) return '#00B894';
    if (percent > 25) return '#FDCB6E';
    return '#D63031';
  }

  // 格式化时间
  formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }

  build() {
    // 根据设备状态选择布局
    if (this.deviceState === 'foldable-dual') {
      this.buildDualPanel();
    } else {
      this.buildSinglePanel();
    }
  }

  // 单屏布局
  @Builder
  buildSinglePanel() {
    Column({ space: 8 }) {
      // 顶部：玩家和敌人状态
      Row({ space: 16 }) {
        // 玩家状态（左）
        if (this.getLayoutConfig().showCharacterInfo) {
          this.buildPlayerStatus();
        }

        Blank();

        // 敌人状态（右）
        if (this.getLayoutConfig().showEnemyInfo) {
          this.buildEnemyStatus();
        }
      }
      .width('100%');

      // 中部：战斗统计（可选）
      if (this.getLayoutConfig().showBattleStats) {
        this.buildBattleStats();
      }

      // 底部：技能信息
      if (this.getLayoutConfig().showSkillInfo) {
        this.buildSkillInfo();
      }
    }
    .width('100%')
    .padding(8);
  }

  // 双屏布局
  @Builder
  buildDualPanel() {
    Row({ space: 16 }) {
      // 左屏：玩家状态和战斗统计
      Column({ space: 8 }) {
        this.buildPlayerStatus();
        this.buildBattleStats();
      }
      .width('50%')
      .alignItems(HorizontalAlign.Start);

      // 右屏：敌人状态和技能信息
      Column({ space: 8 }) {
        this.buildEnemyStatus();
        this.buildSkillInfo();
      }
      .width('50%')
      .alignItems(HorizontalAlign.End);
    }
    .width('100%')
    .padding(12);
  }

  // 玩家状态组件
  @Builder
  buildPlayerStatus() {
    Column({ space: 4 }) {
      // 角色名
      Text(this.playerName)
        .fontSize(14)
        .fontColor('#F5F5F5')
        .fontWeight(FontWeight.Bold);

      // 血条
      Row() {
        Progress({
          value: this.playerHp,
          total: this.playerMaxHp,
          type: ProgressType.Linear
        })
          .width(120)
          .style({ strokeWidth: 4 })
          .color(this.getHpColor())
          .backgroundColor('#2D3436');

        Text(`${Math.ceil(this.playerHp)}`)
          .fontSize(10)
          .fontColor('#F5F5F5')
          .margin({ left: 4 });
      }

      // 剑气条
      Row() {
        Progress({
          value: this.playerEnergy,
          total: this.playerMaxEnergy,
          type: ProgressType.Linear
        })
          .width(120)
          .style({ strokeWidth: 3 })
          .color(this.getEnergyColor())
          .backgroundColor('#2D3436');

        Text(`${Math.ceil(this.playerEnergy)}`)
          .fontSize(10)
          .fontColor('#74B9FF')
          .margin({ left: 4 });
      }

      // 连击数
      if (this.playerCombo > 1) {
        Text(`${this.playerCombo} 连击`)
          .fontSize(12)
          .fontColor('#F39C12')
          .fontWeight(FontWeight.Bold);
      }
    }
    .padding(8)
    .backgroundColor('rgba(0,0,0,0.5)')
    .borderRadius(8);
  }

  // 敌人状态组件
  @Builder
  buildEnemyStatus() {
    Column({ space: 4 }) {
      // 敌人名
      Text(this.enemyName)
        .fontSize(14)
        .fontColor('#F5F5F5')
        .fontWeight(FontWeight.Bold);

      // 血条
      Row() {
        Text(`${Math.ceil(this.enemyHp)}`)
          .fontSize(10)
          .fontColor('#F5F5F5')
          .margin({ right: 4 });

        Progress({
          value: this.enemyHp,
          total: this.enemyMaxHp,
          type: ProgressType.Linear
        })
          .width(120)
          .style({ strokeWidth: 4 })
          .color(this.getEnemyHpColor())
          .backgroundColor('#2D3436');
      }
    }
    .padding(8)
    .backgroundColor('rgba(0,0,0,0.5)')
    .borderRadius(8);
  }

  // 战斗统计组件
  @Builder
  buildBattleStats() {
    Column({ space: 8 }) {
      // 时间
      Row() {
        Text('时间')
          .fontSize(12)
          .fontColor('#B2BEC3');
        Text(this.formatTime(this.battleTime))
          .fontSize(14)
          .fontColor('#F5F5F5')
          .fontWeight(FontWeight.Bold);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);

      // 伤害输出
      Row() {
        Text('伤害输出')
          .fontSize(12)
          .fontColor('#B2BEC3');
        Text(this.damageDealt.toString())
          .fontSize(14)
          .fontColor('#00B894')
          .fontWeight(FontWeight.Bold);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);

      // 受到伤害
      Row() {
        Text('受到伤害')
          .fontSize(12)
          .fontColor('#B2BEC3');
        Text(this.damageTaken.toString())
          .fontSize(14)
          .fontColor('#D63031')
          .fontWeight(FontWeight.Bold);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .width('100%')
    .padding(12)
    .backgroundColor('rgba(45,52,54,0.8)')
    .borderRadius(8);
  }

  // 技能信息组件
  @Builder
  buildSkillInfo() {
    Column({ space: 4 }) {
      Text('快捷键')
        .fontSize(12)
        .fontColor('#B2BEC3')
        .width('100%')
        .textAlign(TextAlign.Start);

      Row({ space: 8 }) {
        SkillIndicator({ key: 'Q', name: '技能1', ready: this.playerEnergy >= 20 });
        SkillIndicator({ key: 'W', name: '技能2', ready: this.playerEnergy >= 30 });
        SkillIndicator({ key: 'E', name: '技能3', ready: this.playerEnergy >= 40 });
        SkillIndicator({ key: 'R', name: '必杀', ready: this.playerEnergy >= 100, isUltimate: true });
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly);
    }
    .width('100%')
    .padding(8)
    .backgroundColor('rgba(0,0,0,0.5)')
    .borderRadius(8);
  }
}

/**
 * 技能指示器组件
 */
@Component
struct SkillIndicator {
  @Prop key: string = '';
  @Prop name: string = '';
  @Prop ready: boolean = true;
  @Prop isUltimate: boolean = false;

  build() {
    Column({ space: 2 }) {
      // 快捷键
      Text(this.key)
        .fontSize(12)
        .fontColor(this.ready ? '#1A1A1A' : '#B2BEC3')
        .fontWeight(FontWeight.Bold)
        .width(24)
        .height(24)
        .backgroundColor(this.ready ? (this.isUltimate ? '#FD79A8' : '#74B9FF') : '#2D3436')
        .borderRadius(4)
        .textAlign(TextAlign.Center);

      // 技能名
      Text(this.name)
        .fontSize(8)
        .fontColor(this.ready ? '#F5F5F5' : '#636E72');
    }
  }
}

/**
 * 简洁版状态栏（用于顶部）
 */
@Component
export struct StatusBar {
  @Prop playerHp: number = 100;
  @Prop playerMaxHp: number = 100;
  @Prop playerEnergy: number = 0;
  @Prop playerMaxEnergy: number = 100;
  @Prop enemyHp: number = 100;
  @Prop enemyMaxHp: number = 100;
  @Prop battleTime: number = 0;

  getPlayerHpColor(): string {
    const percent = (this.playerHp / this.playerMaxHp) * 100;
    if (percent > 50) return '#00B894';
    if (percent > 25) return '#FDCB6E';
    return '#D63031';
  }

  getEnemyHpColor(): string {
    const percent = (this.enemyHp / this.enemyMaxHp) * 100;
    if (percent > 50) return '#00B894';
    if (percent > 25) return '#FDCB6E';
    return '#D63031';
  }

  getEnergyColor(): string {
    const percent = (this.playerEnergy / this.playerMaxEnergy) * 100;
    if (percent >= 100) return '#FD79A8';
    if (percent >= 75) return '#6C5CE7';
    return '#0984E3';
  }

  build() {
    Row() {
      // 玩家信息（左）
      Row({ space: 8 }) {
        // 血条
        Row()
          .width(100)
          .height(6)
          .backgroundColor('#2D3436')
          .borderRadius(3);

        Row()
          .width(`${(this.playerHp / this.playerMaxHp) * 100}%`)
          .height(6)
          .backgroundColor(this.getPlayerHpColor())
          .borderRadius(3);

        // 剑气
        Row()
          .width(60)
          .height(4)
          .backgroundColor('#2D3436')
          .borderRadius(2);

        Row()
          .width={`${(this.playerEnergy / this.playerMaxEnergy) * 60}%`}
          .height(4)
          .backgroundColor(this.getEnergyColor())
          .borderRadius(2);
      }

      Blank();

      // 时间
      Text(`${Math.floor(this.battleTime / 60)}:${(Math.floor(this.battleTime % 60)).toString().padStart(2, '0')}`)
        .fontSize(14)
        .fontColor('#F5F5F5')
        .fontWeight(FontWeight.Bold);

      Blank();

      // 敌人信息（右）
      Row({ space: 8 }) {
        // 剑气（反向）
        Row()
          .width(`${(this.playerEnergy / this.playerMaxEnergy) * 60}%`)
          .height(4)
          .backgroundColor(this.getEnergyColor())
          .borderRadius(2);

        Row()
          .width(60)
          .height(4)
          .backgroundColor('#2D3436')
          .borderRadius(2);

        // 血条（反向）
        Row()
          .width(`${(this.enemyHp / this.enemyMaxHp) * 100}%`)
          .height(6)
          .backgroundColor(this.getEnemyHpColor())
          .borderRadius(3);

        Row()
          .width(100)
          .height(6)
          .backgroundColor('#2D3436')
          .borderRadius(3);
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor('rgba(0,0,0,0.7)');
  }
}
