import { Character } from '../models/Character';

export class InputController {
  private character: Character;
  private keys: Map<string, boolean> = new Map();
  private pressedKeys: Set<string> = new Set(); // 追踪已按下的键

  constructor(character: Character) {
    this.character = character;
  }

  // 按下按键
  onKeyDown(key: string): void {
    const normalizedKey = key.toLowerCase();
    // 只在首次按下时触发攻击/跳跃
    if (!this.pressedKeys.has(normalizedKey)) {
      this.pressedKeys.add(normalizedKey);
      this.handleInputOnPress(normalizedKey);
    }
    this.keys.set(normalizedKey, true);
    this.handleContinuousInput();
  }

  // 释放按键
  onKeyUp(key: string): void {
    const normalizedKey = key.toLowerCase();
    this.pressedKeys.delete(normalizedKey);
    this.keys.set(normalizedKey, false);
    this.handleContinuousInput();
  }

  // 处理单次触发的动作（跳跃、攻击）
  private handleInputOnPress(key: string): void {
    // 跳跃控制
    if (key === 'arrowup' || key === 'w' || key === ' ') {
      this.character.jump();
    }
    // 攻击控制
    if (key === 'j' || key === 'z') {
      this.character.attack();
    }
  }

  // 处理持续输入
  private handleContinuousInput(): void {
    // 移动控制
    const movingLeft = this.keys.get('arrowleft') || this.keys.get('a');
    const movingRight = this.keys.get('arrowright') || this.keys.get('d');

    if (movingLeft && !movingRight) {
      this.character.moveLeft();
    } else if (movingRight && !movingLeft) {
      this.character.moveRight();
    } else {
      this.character.stopMoving();
    }
  }
}
