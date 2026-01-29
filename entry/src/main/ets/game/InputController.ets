import { Character } from '../models/Character';

export class InputController {
  private character: Character;
  private keys: Map<string, boolean> = new Map();

  constructor(character: Character) {
    this.character = character;
  }

  // 按下按键
  onKeyDown(key: string): void {
    this.keys.set(key, true);
    this.handleInput();
  }

  // 释放按键
  onKeyUp(key: string): void {
    this.keys.delete(key);
    this.handleInput();
  }

  // 处理输入
  private handleInput(): void {
    // 移动控制
    if (this.keys.has('ArrowLeft') || this.keys.has('a')) {
      this.character.moveLeft();
    } else if (this.keys.has('ArrowRight') || this.keys.has('d')) {
      this.character.moveRight();
    } else {
      this.character.stopMoving();
    }

    // 跳跃控制
    if (this.keys.has('ArrowUp') || this.keys.has('w') || this.keys.has(' ')) {
      this.character.jump();
    }

    // 攻击控制
    if (this.keys.has('j') || this.keys.has('z')) {
      this.character.attack();
    }
  }
}
