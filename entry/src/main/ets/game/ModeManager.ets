import { SkillManager } from './SkillManager';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'ModeManager';

export type CharacterMode = 'default' | 'alternate';

// 模式配置接口
export interface ModeConfig {
  baseStats: {
    maxHp: number;
    currentHp: number;
    attack: number;
    defense: number;
    speed: number;
  };
  skills: any[];
  ultimate: any;
}

export class ModeManager {
  private currentMode: CharacterMode = 'default';
  private switchCooldown: number = 0;
  private readonly SWITCH_COOLDOWN_TIME: number;

  // 默认模式和备用模式的配置
  private defaultModeConfig: {
    stats: any;
    skills: any[];
    ultimate: any;
  };
  private alternateModeConfig: {
    stats: any;
    skills: any[];
    ultimate: any;
  };

  constructor(
    defaultSkills: any[],
    defaultUltimate: any,
    defaultStats: any,
    alternateSkills: any[],
    alternateUltimate: any,
    alternateStats: any,
    switchCooldown: number
  ) {
    this.SWITCH_COOLDOWN_TIME = switchCooldown;

    this.defaultModeConfig = {
      stats: { ...defaultStats },
      skills: [...defaultSkills],
      ultimate: { ...defaultUltimate }
    };

    this.alternateConfig = {
      stats: { ...alternateStats },
      skills: [...alternateSkills],
      ultimate: { ...alternateUltimate }
    };

    hilog.info(DOMAIN, TAG, 'ModeManager initialized with switch cooldown: %{public}dms', switchCooldown);
  }

  // 更新冷却
  update(deltaTime: number): void {
    if (this.switchCooldown > 0) {
      this.switchCooldown -= deltaTime * 1000;
    }
  }

  // 检查是否可以切换模式
  canSwitch(): boolean {
    return this.switchCooldown <= 0;
  }

  // 切换模式
  switchMode(): CharacterMode {
    if (!this.canSwitch()) {
      hilog.info(DOMAIN, TAG, 'Cannot switch mode, cooldown remaining: %{public}dms', this.switchCooldown);
      return this.currentMode;
    }

    // 切换模式
    this.currentMode = this.currentMode === 'default' ? 'alternate' : 'default';
    this.switchCooldown = this.SWITCH_COOLDOWN_TIME;

    hilog.info(DOMAIN, TAG, 'Switched to mode: %{public}s', this.currentMode);

    return this.currentMode;
  }

  // 获取当前模式
  getCurrentMode(): CharacterMode {
    return this.currentMode;
  }

  // 获取当前模式的配置
  getCurrentModeConfig(): { stats: any; skills: any[]; ultimate: any } {
    if (this.currentMode === 'default') {
      return this.defaultModeConfig;
    }
    return this.alternateModeConfig;
  }

  // 获取冷却剩余时间（秒）
  getCooldownRemaining(): number {
    return Math.ceil(this.switchCooldown / 1000);
  }

  // 设置备用模式配置
  setAlternateConfig(skills: any[], ultimate: any, stats: any): void {
    this.alternateModeConfig = {
      stats: { ...stats },
      skills: [...skills],
      ultimate: { ...ultimate }
    };
    hilog.info(DOMAIN, TAG, 'Alternate mode config set');
  }

  private get alternateConfig(): any {
    return this.alternateModeConfig;
  }

  private set alternateConfig(value: any) {
    this.alternateModeConfig = value;
  }
}
