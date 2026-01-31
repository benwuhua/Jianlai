import { SkillManager } from './SkillManager';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { SkillConfig } from '../models/Skill';

const DOMAIN = 0x0000;
const TAG = 'ModeManager';

export type CharacterMode = 'default' | 'alternate';

// 模式属性配置类型
export interface ModeStats {
  maxHp: number;
  currentHp: number;
  attack: number;
  defense: number;
  speed: number;
}

// 模式配置接口
export interface ModeConfig {
  baseStats: ModeStats;
  skills: SkillConfig[];
  ultimate: SkillConfig;
}

// 内部模式配置类型
interface InternalModeConfig {
  stats: ModeStats;
  skills: SkillConfig[];
  ultimate: SkillConfig;
}

export class ModeManager {
  private currentMode: CharacterMode = 'default';
  private switchCooldown: number = 0;
  private readonly SWITCH_COOLDOWN_TIME: number;

  // 默认模式和备用模式的配置
  private defaultModeConfig: InternalModeConfig = {
    stats: {
      maxHp: 0,
      currentHp: 0,
      attack: 0,
      defense: 0,
      speed: 0
    },
    skills: [],
    ultimate: {
      id: '',
      name: '',
      type: 'active',
      cooldown: 0,
      kiCost: 0,
      damage: 0,
      range: 0
    }
  };

  private alternateModeConfig: InternalModeConfig = {
    stats: {
      maxHp: 0,
      currentHp: 0,
      attack: 0,
      defense: 0,
      speed: 0
    },
    skills: [],
    ultimate: {
      id: '',
      name: '',
      type: 'active',
      cooldown: 0,
      kiCost: 0,
      damage: 0,
      range: 0
    }
  };

  constructor(
    defaultSkills: SkillConfig[],
    defaultUltimate: SkillConfig,
    defaultStats: ModeStats,
    alternateSkills: SkillConfig[],
    alternateUltimate: SkillConfig,
    alternateStats: ModeStats,
    switchCooldown: number
  ) {
    this.SWITCH_COOLDOWN_TIME = switchCooldown;

    // 直接使用参数初始化，避免对象字面量问题
    this.defaultModeConfig.stats = defaultStats;
    this.defaultModeConfig.skills = defaultSkills;
    this.defaultModeConfig.ultimate = defaultUltimate;

    this.alternateModeConfig.stats = alternateStats;
    this.alternateModeConfig.skills = alternateSkills;
    this.alternateModeConfig.ultimate = alternateUltimate;

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
  getCurrentModeConfig(): InternalModeConfig {
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
  setAlternateConfig(skills: SkillConfig[], ultimate: SkillConfig, stats: ModeStats): void {
    this.alternateModeConfig = {
      stats: { maxHp: stats.maxHp, currentHp: stats.currentHp, attack: stats.attack, defense: stats.defense, speed: stats.speed },
      skills: skills.slice(),
      ultimate: { id: ultimate.id, name: ultimate.name, type: ultimate.type, cooldown: ultimate.cooldown, kiCost: ultimate.kiCost, damage: ultimate.damage, range: ultimate.range }
    };
    hilog.info(DOMAIN, TAG, 'Alternate mode config set');
  }
}
