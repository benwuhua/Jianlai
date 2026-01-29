// 角色状态枚举
export enum CharacterState {
  IDLE = 'idle',
  WALKING = 'walking',
  ATTACKING = 'attacking',
  HURT = 'hurt',
  DEAD = 'dead'
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
    // 使用deltaTime标准化速度（假设deltaTime单位为秒）
    this.x += this.velocityX * deltaTime * 60; // 60是基准帧率
    this.y += this.velocityY * deltaTime * 60;

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
    }
  }

  // 攻击
  attack(): void {
    // 检查是否在冷却中
    // 注意：冷却时间(500ms)包含攻击持续时间(300ms)，实际额外冷却为200ms
    if (this.attackCooldown > 0 || this.attackDuration > 0) {
      return;
    }

    this.state = CharacterState.ATTACKING;
    this.attackDuration = Character.ATTACK_DURATION;
    this.attackCooldown = Character.ATTACK_COOLDOWN_TIME;
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
}
