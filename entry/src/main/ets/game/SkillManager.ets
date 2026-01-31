import { Skill, SkillConfig, SkillType } from '../models/Skill';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'SkillManager';

export class SkillManager {
  // 技能列表
  private skills: Skill[] = [];
  private ultimate: Skill | null = null;

  // 剑气系统
  private currentKi: number = 0;
  private maxKi: number = 100;

  constructor(skills: SkillConfig[], ultimate: SkillConfig) {
    // 初始化3个普通技能
    if (skills && skills.length > 0) {
      this.skills = skills.map(config => new Skill(config));
    }

    // 初始化必杀技
    if (ultimate) {
      this.ultimate = new Skill(ultimate);
    }

    hilog.info(DOMAIN, TAG, 'SkillManager initialized with %{public}d skills', this.skills.length);
  }

  // 更新冷却时间
  update(deltaTime: number): void {
    for (const skill of this.skills) {
      skill.update(deltaTime);
    }

    if (this.ultimate) {
      this.ultimate.update(deltaTime);
    }
  }

  // 使用技能（索引 0-2）
  useSkill(index: number): boolean {
    if (index < 0 || index >= this.skills.length) {
      hilog.warn(DOMAIN, TAG, 'Invalid skill index: %{public}d', index);
      return false;
    }

    const skill = this.skills[index];

    // 检查冷却
    if (!skill.canUse()) {
      hilog.info(DOMAIN, TAG, 'Skill %{public}d is on cooldown', index);
      return false;
    }

    // 检查剑气是否足够
    if (this.currentKi < skill.config.kiCost) {
      hilog.info(DOMAIN, TAG, 'Not enough Ki for skill %{public}d (need: %{public}d, have: %{public}d)',
        index, skill.config.kiCost, this.currentKi);
      return false;
    }

    // 使用技能
    skill.use();
    this.currentKi -= skill.config.kiCost;

    hilog.info(DOMAIN, TAG, 'Used skill %{public}s (Ki cost: %{public}d, remaining Ki: %{public}d)',
      skill.config.name, skill.config.kiCost, this.currentKi);

    return true;
  }

  // 使用必杀技
  useUltimate(): boolean {
    if (!this.ultimate) {
      hilog.warn(DOMAIN, TAG, 'No ultimate skill available');
      return false;
    }

    // 检查冷却
    if (!this.ultimate.canUse()) {
      hilog.info(DOMAIN, TAG, 'Ultimate is on cooldown');
      return false;
    }

    // 检查剑气是否满（必杀技需要100点剑气）
    if (this.currentKi < this.maxKi) {
      hilog.info(DOMAIN, TAG, 'Not enough Ki for ultimate (need: %{public}d, have: %{public}d)',
        this.maxKi, this.currentKi);
      return false;
    }

    // 使用必杀技
    this.ultimate.use();
    this.currentKi = 0; // 必杀技消耗所有剑气

    hilog.info(DOMAIN, TAG, 'Used ultimate: %{public}s', this.ultimate.config.name);

    return true;
  }

  // 增加剑气
  addKi(amount: number): void {
    this.currentKi = Math.min(this.maxKi, this.currentKi + amount);
  }

  // 获取当前剑气
  getCurrentKi(): number {
    return this.currentKi;
  }

  // 获取最大剑气
  getMaxKi(): number {
    return this.maxKi;
  }

  // 获取剑气百分比
  getKiPercent(): number {
    return this.currentKi / this.maxKi;
  }

  // 获取技能配置
  getSkillConfig(index: number): SkillConfig | null {
    if (index < 0 || index >= this.skills.length) {
      return null;
    }
    return this.skills[index].config;
  }

  // 获取必杀技配置
  getUltimateConfig(): SkillConfig | null {
    return this.ultimate?.config || null;
  }

  // 检查技能是否可用
  canUseSkill(index: number): boolean {
    if (index < 0 || index >= this.skills.length) {
      return false;
    }

    const skill = this.skills[index];
    return skill.canUse() && this.currentKi >= skill.config.kiCost;
  }

  // 检查必杀技是否可用
  canUseUltimate(): boolean {
    if (!this.ultimate) {
      return false;
    }
    return this.ultimate.canUse() && this.currentKi >= this.maxKi;
  }

  // 获取技能冷却剩余时间（秒）
  getSkillCooldownRemaining(index: number): number {
    if (index < 0 || index >= this.skills.length) {
      return 0;
    }
    return Math.ceil(this.skills[index].remainingCooldown / 1000);
  }

  // 获取必杀技冷却剩余时间（秒）
  getUltimateCooldownRemaining(): number {
    if (!this.ultimate) {
      return 0;
    }
    return Math.ceil(this.ultimate.remainingCooldown / 1000);
  }

  // 获取技能数量
  getSkillCount(): number {
    return this.skills.length;
  }

  // 替换技能列表（用于模式切换）
  replaceSkills(skills: SkillConfig[], ultimate: SkillConfig): void {
    this.skills = skills.map(config => new Skill(config));
    this.ultimate = new Skill(ultimate);

    hilog.info(DOMAIN, TAG, 'Skills replaced, new skill count: %{public}d', this.skills.length);
  }
}
