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
  private static readonly ATTACK_DURATION = 500; // 攻击持续时间（毫秒）

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
  private attackDuration: number = 0;

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

    // 简单的地面碰撞
    if (this.y >= Character.GROUND_Y) {
      this.y = Character.GROUND_Y;
      this.velocityY = 0;
    }

    // 更新攻击状态
    if (this.state === CharacterState.ATTACKING) {
      this.attackDuration -= deltaTime * 1000; // 转换为毫秒
      if (this.attackDuration <= 0) {
        this.state = CharacterState.IDLE;
        this.attackDuration = 0;
      }
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
    this.state = CharacterState.ATTACKING;
    this.attackDuration = Character.ATTACK_DURATION;
    // TODO: 实现攻击逻辑
  }
}
