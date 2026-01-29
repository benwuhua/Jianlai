import { Character } from '../models/Character';

export class CollisionDetector {
  // 常量定义
  private static readonly DEFAULT_ATTACK_RANGE = 100;

  // AABB碰撞检测（矩形碰撞）
  static checkAABB(char1: Character, char2: Character): boolean {
    if (!char1 || !char2) {
      return false;
    }
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
    if (!char1 || !char2) {
      return 0;
    }
    const dx = char2.x - char1.x;
    const dy = char2.y - char1.y;
    return Math.sqrt(dx * dx + dy * dy);
  }

  // 检测攻击范围碰撞
  static checkAttackRange(attacker: Character, target: Character, range: number = CollisionDetector.DEFAULT_ATTACK_RANGE): boolean {
    if (!attacker || !target) {
      return false;
    }
    const dx = target.x - attacker.x;
    const dy = target.y - attacker.y;
    const distanceSquared = dx * dx + dy * dy;
    return distanceSquared <= range * range;
  }

  // 将角色限制在屏幕边界内
  static clampToScreen(character: Character, screenWidth: number, screenHeight: number): void {
    if (!character) {
      return;
    }
    const halfWidth = character.width / 2;

    // X轴边界检查
    if (character.x - halfWidth < 0) {
      character.x = halfWidth;
    }
    if (character.x + halfWidth > screenWidth) {
      character.x = screenWidth - halfWidth;
    }

    // Y轴边界检查
    if (character.y - character.height < 0) {
      character.y = character.height;
    }
    if (character.y > screenHeight) {
      character.y = screenHeight;
    }
  }
}
