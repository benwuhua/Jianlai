import { Character } from '../models/Character';
import { AIBehavior, AIDifficulty, DEFAULT_AI_BEHAVIOR } from '../models/AIBehavior';
import { CollisionDetector } from '../utils/CollisionDetector';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'AIController';

// AI状态枚举
export enum AIState {
  IDLE = 'idle',
  MOVE = 'move',
  ATTACK = 'attack',
  DEFEND = 'defend',
  CAST_SKILL = 'cast_skill'
}

export class AIController {
  private character: Character;
  private target: Character;
  private behavior: AIBehavior;

  // 当前状态
  private currentState: AIState = AIState.IDLE;
  private stateTimer: number = 0;
  private lastActionTime: number = 0;
  private decisionCooldown: number = 0;

  // 反应延迟（模拟人类反应时间）
  private reactionDelay: number = 0;

  constructor(character: Character, target: Character, difficulty: AIDifficulty = 'normal') {
    this.character = character;
    this.target = target;
    this.behavior = this.getBehaviorByDifficulty(difficulty);

    this.reactionDelay = this.behavior.reactionTime;

    hilog.info(DOMAIN, TAG, 'AIController initialized for %{public}s with difficulty: %{public}s',
      character.name, difficulty);
  }

  // 根据难度获取AI行为配置
  private getBehaviorByDifficulty(difficulty: AIDifficulty): AIBehavior {
    switch (difficulty) {
      case 'easy':
        return DEFAULT_AI_BEHAVIOR.easy;
      case 'normal':
        return DEFAULT_AI_BEHAVIOR.normal;
      case 'hard':
        return DEFAULT_AI_BEHAVIOR.hard;
      case 'extreme':
        return DEFAULT_AI_BEHAVIOR.extreme;
      default:
        return DEFAULT_AI_BEHAVIOR.normal;
    }
  }

  // 更新AI（每帧调用）
  update(deltaTime: number): void {
    // deltaTime 单位为毫秒
    this.stateTimer -= deltaTime;
    this.decisionCooldown -= deltaTime;
    this.reactionDelay -= deltaTime;
    this.lastActionTime += deltaTime;

    // 反应延迟未结束，不执行任何操作
    if (this.reactionDelay > 0) {
      return;
    }

    // 决策冷却未结束
    if (this.decisionCooldown > 0) {
      this.executeCurrentState(deltaTime);
      return;
    }

    // 做决策
    this.makeDecision();
  }

  // AI决策逻辑
  private makeDecision(): void {
    const distance = CollisionDetector.getDistance(this.character, this.target);
    const hpPercent = this.character.stats.currentHp / this.character.stats.maxHp;
    const targetHpPercent = this.target.stats.currentHp / this.target.stats.maxHp;

    // 优先级1：保命（低血量时优先防御）
    if (hpPercent < 0.3 && this.currentState !== AIState.DEFEND) {
      this.enterDefendState();
      return;
    }

    // 优先级2：目标在攻击范围内且准备攻击 -> 防御
    if (this.target.isAttacking() && distance < 150 && this.shouldBlock()) {
      this.enterDefendState();
      return;
    }

    // 优先级3：技能使用（根据难度决定概率）
    if (this.shouldUseSkill() && distance < 300) {
      this.enterSkillState();
      return;
    }

    // 优先级4：攻击
    if (distance < 120 && this.lastActionTime > this.behavior.attackInterval) {
      this.enterAttackState();
      return;
    }

    // 优先级5：移动（靠近或远离目标）
    if (distance > 100 || distance < 80) {
      this.enterMoveState();
      return;
    }

    // 默认：待机
    this.enterIdleState();
  }

  // 执行当前状态
  private executeCurrentState(deltaTime: number): void {
    switch (this.currentState) {
      case AIState.IDLE:
        this.executeIdle();
        break;
      case AIState.MOVE:
        this.executeMove();
        break;
      case AIState.ATTACK:
        this.executeAttack();
        break;
      case AIState.DEFEND:
        this.executeDefend();
        break;
      case AIState.CAST_SKILL:
        this.executeSkill();
        break;
    }
  }

  // IDLE状态：待机
  private enterIdleState(): void {
    this.currentState = AIState.IDLE;
    this.stateTimer = 500;
    this.decisionCooldown = 500;
    this.character.stopMoving();
  }

  private executeIdle(): void {
    if (this.stateTimer <= 0) {
      this.decisionCooldown = 0; // 重新决策
    }
  }

  // MOVE状态：移动
  private enterMoveState(): void {
    this.currentState = AIState.MOVE;
    this.stateTimer = 1000;
    this.decisionCooldown = 300;

    const distance = CollisionDetector.getDistance(this.character, this.target);
    const dx = this.target.x - this.character.x;

    // 距离太远，靠近
    if (distance > 120) {
      if (dx > 0) {
        this.character.moveRight();
      } else {
        this.character.moveLeft();
      }
    } else if (distance < 80) {
      // 距离太近，后退
      if (dx > 0) {
        this.character.moveLeft();
      } else {
        this.character.moveRight();
      }
    }
  }

  private executeMove(): void {
    if (this.stateTimer <= 0) {
      this.character.stopMoving();
      this.decisionCooldown = 0; // 重新决策
    }
  }

  // ATTACK状态：攻击
  private enterAttackState(): void {
    this.currentState = AIState.ATTACK;
    this.stateTimer = 500;
    this.decisionCooldown = 1000;
    this.lastActionTime = 0;

    // 面向目标
    const dx = this.target.x - this.character.x;
    if (dx > 0) {
      this.character.facing = 1;
    } else {
      this.character.facing = -1;
    }

    // 攻击
    this.character.attack();

    hilog.info(DOMAIN, TAG, 'AI %{public}s attacks', this.character.name);
  }

  private executeAttack(): void {
    // 连招逻辑
    if (this.behavior.canCombo && this.stateTimer <= 0) {
      // 有概率继续攻击
      if (Math.random() < 0.6) {
        this.character.attack();
        this.stateTimer = 300;
      } else {
        this.decisionCooldown = 0; // 重新决策
      }
    } else if (this.stateTimer <= 0) {
      this.decisionCooldown = 0;
    }
  }

  // DEFEND状态：防御
  private enterDefendState(): void {
    this.currentState = AIState.DEFEND;
    this.stateTimer = 1000;
    this.decisionCooldown = 1000;

    // 停止移动
    this.character.stopMoving();

    hilog.info(DOMAIN, TAG, 'AI %{public}s enters defend state', this.character.name);
  }

  private executeDefend(): void {
    // 防御状态：格挡或闪避
    if (this.stateTimer <= 0) {
      this.decisionCooldown = 0; // 重新决策
    }
  }

  // SKILL状态：使用技能
  private enterSkillState(): void {
    this.currentState = AIState.CAST_SKILL;
    this.stateTimer = 500;
    this.decisionCooldown = 1500;
    this.lastActionTime = 0;

    // 面向目标
    const dx = this.target.x - this.character.x;
    if (dx > 0) {
      this.character.facing = 1;
    } else {
      this.character.facing = -1;
    }

    // 选择技能
    const skillManager = this.character.getSkillManager();
    if (skillManager) {
      const skillCount = skillManager.getSkillCount();

      // 尝试使用必杀技（如果剑气满）
      if (skillManager.canUseUltimate() && Math.random() < 0.3) {
        this.character.useUltimate();
        hilog.info(DOMAIN, TAG, 'AI %{public}s uses ULTIMATE', this.character.name);
        return;
      }

      // 随机选择可用技能
      const availableSkills: number[] = [];
      for (let i = 0; i < skillCount; i++) {
        if (skillManager.canUseSkill(i)) {
          availableSkills.push(i);
        }
      }

      if (availableSkills.length > 0) {
        const skillIndex = availableSkills[Math.floor(Math.random() * availableSkills.length)];
        this.character.useSkill(skillIndex);

        const skillConfig = skillManager.getSkillConfig(skillIndex);
        hilog.info(DOMAIN, TAG, 'AI %{public}s uses skill %{public}s',
          this.character.name, skillConfig?.name || 'unknown');
      }
    }
  }

  private executeSkill(): void {
    if (this.stateTimer <= 0) {
      this.decisionCooldown = 0;
    }
  }

  // 判断是否应该格挡
  private shouldBlock(): boolean {
    return Math.random() < this.behavior.blockRate;
  }

  // 判断是否应该使用技能
  private shouldUseSkill(): boolean {
    const skillManager = this.character.getSkillManager();
    if (!skillManager) {
      return false;
    }

    // 检查是否有可用技能
    for (let i = 0; i < skillManager.getSkillCount(); i++) {
      if (skillManager.canUseSkill(i)) {
        return Math.random() < this.behavior.skillUsageRate;
      }
    }

    // 检查必杀技
    if (skillManager.canUseUltimate()) {
      return Math.random() < this.behavior.skillUsageRate;
    }

    return false;
  }

  // 获取当前状态
  getCurrentState(): AIState {
    return this.currentState;
  }

  // 设置难度
  setDifficulty(difficulty: AIDifficulty): void {
    this.behavior = this.getBehaviorByDifficulty(difficulty);
    this.reactionDelay = this.behavior.reactionTime;

    hilog.info(DOMAIN, TAG, 'AI difficulty changed to: %{public}s', difficulty);
  }

  // 重置AI
  reset(): void {
    this.currentState = AIState.IDLE;
    this.stateTimer = 0;
    this.lastActionTime = 0;
    this.decisionCooldown = 0;
    this.reactionDelay = this.behavior.reactionTime;

    this.character.stopMoving();
  }
}
