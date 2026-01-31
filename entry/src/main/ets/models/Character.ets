import { AudioManager } from '../utils/AudioManager';
import { Skill, SkillConfig } from './Skill';
import { SkillManager } from '../game/SkillManager';
import { ModeManager, CharacterMode } from '../game/ModeManager';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;

// 角色状态枚举
export enum CharacterState {
  IDLE = 'idle',
  WALKING = 'walking',
  ATTACKING = 'attacking',
  HURT = 'hurt',
  DEAD = 'dead',
  CASTING_SKILL = 'casting_skill',
  MODE_SWITCHING = 'mode_switching'
}

// 角色属性接口
export interface CharacterStats {
  maxHp: number;
  currentHp: number;
  attack: number;
  defense: number;
  speed: number;
}

// 角色类
export class Character {
  // 常量
  private static readonly GROUND_Y = 500;
  private static readonly ATTACK_DURATION = 300; // 攻击持续时间（毫秒）
  private static readonly ATTACK_COOLDOWN_TIME = 500; // 攻击冷却时间（毫秒）
  private static readonly DAMAGE_WINDOW_START = 200; // 伤害判定窗口阈值（ms）

  id: string;
  name: string;
  state: CharacterState;
  stats: CharacterStats;

  // 位置和速度
  x: number;
  y: number;
  velocityX: number;
  velocityY: number;

  // 渲染属性
  width: number = 100;
  height: number = 150;
  color: string;

  // 面向方向 (1: 右, -1: 左)
  facing: number = 1;

  // 攻击状态管理
  private attackCooldown: number = 0;
  private attackDuration: number = 0;

  // 受击硬直状态管理
  private hurtDuration: number = 0;
  private static readonly HURT_DURATION = 100; // ms

  // 技能系统
  skillManager: SkillManager | null = null;

  // 模式切换系统（用于陈平安等双模式角色）
  modeManager: ModeManager | null = null;
  private currentMode: CharacterMode = 'default';

  constructor(id: string, name: string, x: number, y: number, color: string) {
    this.id = id;
    this.name = name;
    this.x = x;
    this.y = y;
    this.color = color;
    this.state = CharacterState.IDLE;
    this.velocityX = 0;
    this.velocityY = 0;

    // 默认属性
    this.stats = {
      maxHp: 1000,
      currentHp: 1000,
      attack: 100,
      defense: 50,
      speed: 5
    };
  }

  // 更新位置
  update(deltaTime: number): void {
    // 使用deltaTime标准化速度（deltaTime单位为毫秒）
    this.x += this.velocityX * deltaTime * 60 / 1000; // 60是基准帧率，1000转换为秒
    this.y += this.velocityY * deltaTime * 60 / 1000;

    // 更新技能管理器
    if (this.skillManager) {
      this.skillManager.update(deltaTime);
    }

    // 更新模式管理器
    if (this.modeManager) {
      this.modeManager.update(deltaTime);
    }

    // 更新攻击冷却
    if (this.attackCooldown > 0) {
      this.attackCooldown -= deltaTime * 1000;
    }

    // 更新攻击持续时间
    if (this.attackDuration > 0) {
      this.attackDuration -= deltaTime * 1000;
      if (this.attackDuration <= 0) {
        this.state = CharacterState.IDLE;
        this.attackDuration = 0;
      }
    }

    // 更新受击硬直状态
    if (this.hurtDuration > 0) {
      this.hurtDuration -= deltaTime * 1000;
      if (this.hurtDuration <= 0) {
        if (this.stats.currentHp > 0) {
          this.state = CharacterState.IDLE;
        } else {
          this.state = CharacterState.DEAD;
        }
      }
    }

    // 简单的地面碰撞
    if (this.y >= Character.GROUND_Y) {
      this.y = Character.GROUND_Y;
      this.velocityY = 0;
    }
  }

  // 向左移动
  moveLeft(): void {
    this.velocityX = -this.stats.speed;
    this.facing = -1;
    this.state = CharacterState.WALKING;
  }

  // 向右移动
  moveRight(): void {
    this.velocityX = this.stats.speed;
    this.facing = 1;
    this.state = CharacterState.WALKING;
  }

  // 停止移动
  stopMoving(): void {
    this.velocityX = 0;
    if (this.state === CharacterState.WALKING) {
      this.state = CharacterState.IDLE;
    }
  }

  // 跳跃
  jump(): void {
    if (this.y >= Character.GROUND_Y) { // 在地面
      this.velocityY = -15;
      // 播放跳跃音效
      AudioManager.getInstance().playJumpSound();
    }
  }

  // 攻击
  attack(): void {
    // 注意：冷却时间(500ms)包含攻击持续时间(300ms)，实际额外冷却为200ms
    if (this.attackCooldown > 0 || this.attackDuration > 0) {
      return;
    }

    this.state = CharacterState.ATTACKING;
    this.attackDuration = Character.ATTACK_DURATION;
    this.attackCooldown = Character.ATTACK_COOLDOWN_TIME;

    // 播放攻击音效
    AudioManager.getInstance().playAttackSound();
  }

  // 受到伤害
  takeDamage(damage: number): void {
    // 如果已经在受击状态，不重复受伤（提供短暂无敌帧）
    if (this.state === CharacterState.HURT) {
      return;
    }

    const actualDamage = damage - this.stats.defense;
    if (actualDamage > 0) {
      this.stats.currentHp = Math.max(0, this.stats.currentHp - actualDamage);
      this.state = CharacterState.HURT;
      this.hurtDuration = Character.HURT_DURATION;
    }
  }

  // 检查是否死亡
  isDead(): boolean {
    return this.stats.currentHp <= 0;
  }

  // 检查是否正在攻击
  isAttacking(): boolean {
    return this.attackDuration > 0;
  }

  // 检查是否在伤害判定窗口（攻击的前100ms：300ms持续时间 - 200ms阈值）
  canDealDamage(): boolean {
    return this.attackDuration > Character.DAMAGE_WINDOW_START;
  }

  // 设置技能管理器
  setSkillManager(skillManager: SkillManager): void {
    this.skillManager = skillManager;
  }

  // 获取技能管理器
  getSkillManager(): SkillManager | null {
    return this.skillManager;
  }

  // 使用技能
  useSkill(index: number): boolean {
    if (!this.skillManager) {
      return false;
    }

    if (this.skillManager.useSkill(index)) {
      this.state = CharacterState.CASTING_SKILL;
      // 攻击和受击会积攒剑气
      // 技能释放不积攒剑气
      return true;
    }

    return false;
  }

  // 使用必杀技
  useUltimate(): boolean {
    if (!this.skillManager) {
      return false;
    }

    if (this.skillManager.useUltimate()) {
      this.state = CharacterState.CASTING_SKILL;
      return true;
    }

    return false;
  }

  // 剑气管理
  addKi(amount: number): void {
    if (this.skillManager) {
      this.skillManager.addKi(amount);
    }
  }

  getKiPercent(): number {
    return this.skillManager ? this.skillManager.getKiPercent() : 0;
  }

  getCurrentKi(): number {
    return this.skillManager ? this.skillManager.getCurrentKi() : 0;
  }

  getMaxKi(): number {
    return this.skillManager ? this.skillManager.getMaxKi() : 100;
  }

  // 模式切换相关方法
  setModeManager(modeManager: ModeManager): void {
    this.modeManager = modeManager;
  }

  getModeManager(): ModeManager | null {
    return this.modeManager;
  }

  // 切换模式
  switchMode(): boolean {
    if (!this.modeManager || !this.modeManager.canSwitch()) {
      return false;
    }

    this.state = CharacterState.MODE_SWITCHING;
    const newMode = this.modeManager.switchMode();
    this.currentMode = newMode;

    // 获取新模式的配置
    const modeConfig = this.modeManager.getCurrentModeConfig();

    // 更新属性
    const hpPercent = this.stats.currentHp / this.stats.maxHp;
    this.stats.maxHp = modeConfig.stats.maxHp;
    this.stats.currentHp = Math.min(this.stats.maxHp, modeConfig.stats.maxHp * hpPercent);
    this.stats.attack = modeConfig.stats.attack;
    this.stats.defense = modeConfig.stats.defense;
    this.stats.speed = modeConfig.stats.speed;

    // 更新技能
    if (this.skillManager) {
      this.skillManager.replaceSkills(modeConfig.skills, modeConfig.ultimate);
    }

    // 模式切换动画延迟后恢复
    setTimeout(() => {
      this.state = CharacterState.IDLE;
    }, 2000);

    hilog.info(DOMAIN, 'Character', 'Switched to %{public}s mode', newMode);

    return true;
  }

  // 获取当前模式
  getCurrentMode(): CharacterMode {
    return this.currentMode;
  }

  // 检查是否有备用模式
  hasAlternateMode(): boolean {
    return this.modeManager !== null;
  }
}
