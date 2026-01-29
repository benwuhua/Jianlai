import { Character } from '../models/Character';

export class CollisionDetector {
  // AABB碰撞检测（矩形碰撞）
  static checkAABB(char1: Character, char2: Character): boolean {
    const char1Left = char1.x - char1.width / 2;
    const char1Right = char1.x + char1.width / 2;
    const char1Top = char1.y - char1.height;
    const char1Bottom = char1.y;

    const char2Left = char2.x - char2.width / 2;
    const char2Right = char2.x + char2.width / 2;
    const char2Top = char2.y - char2.height;
    const char2Bottom = char2.y;

    return char1Left < char2Right &&
           char1Right > char2Left &&
           char1Top < char2Bottom &&
           char1Bottom > char2Top;
  }

  // 计算两个角色之间的距离
  static getDistance(char1: Character, char2: Character): number {
    const dx = char2.x - char1.x;
    const dy = char2.y - char1.y;
    return Math.sqrt(dx * dx + dy * dy);
  }

  // 检测攻击范围碰撞
  static checkAttackRange(attacker: Character, target: Character, range: number = 100): boolean {
    const distance = this.getDistance(attacker, target);
    return distance <= range;
  }

  // 将角色限制在屏幕边界内
  static clampToScreen(character: Character, screenWidth: number, screenHeight: number): void {
    const halfWidth = character.width / 2;

    if (character.x - halfWidth < 0) {
      character.x = halfWidth;
    }
    if (character.x + halfWidth > screenWidth) {
      character.x = screenWidth - halfWidth;
    }
  }
}
