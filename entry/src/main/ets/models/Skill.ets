// 技能类型
export type SkillType = 'active' | 'passive' | 'ultimate';

// 技能配置接口
export interface SkillConfig {
  id: string;
  name: string;
  type: SkillType;
  cooldown: number;  // 冷却时间（毫秒）
  kiCost: number;    // 剑气消耗
  damage: number;    // 基础伤害
  range: number;     // 攻击范围
  effect?: string;   // 特效名称
  description?: string;
}

// 技能状态（运行时）
export class Skill {
  config: SkillConfig;
  remainingCooldown: number;

  constructor(config: SkillConfig) {
    this.config = config;
    this.remainingCooldown = 0;
  }

  // 是否可用
  canUse(): boolean {
    return this.remainingCooldown <= 0;
  }

  // 使用技能
  use(): void {
    this.remainingCooldown = this.config.cooldown;
  }

  // 更新冷却
  update(deltaTime: number): void {
    if (this.remainingCooldown > 0) {
      this.remainingCooldown -= deltaTime * 1000;
    }
  }
}
