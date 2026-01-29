import { Character } from '../models/Character';
import { CollisionDetector } from '../utils/CollisionDetector';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'BattleSystem';

export class BattleSystem {
  // 处理攻击判定
  static handleAttack(attacker: Character, target: Character): void {
    // 检查攻击者是否正在攻击
    if (!attacker.isAttacking()) {
      return;
    }

    // 检查是否在攻击范围内
    if (!CollisionDetector.checkAttackRange(attacker, target, 120)) {
      return;
    }

    // 检查朝向是否正确
    const dx = target.x - attacker.x;
    const isFacingTarget = (attacker.facing === 1 && dx > 0) ||
                          (attacker.facing === -1 && dx < 0);

    if (!isFacingTarget) {
      return;
    }

    // 造成伤害（避免重复判定：只在攻击开始时造成伤害）
    if (attacker['attackDuration'] > 200) {
      target.takeDamage(attacker.stats.attack);
      hilog.info(DOMAIN, TAG, '%{public}s hit %{public}s for %{public}d damage',
        attacker.name, target.name, attacker.stats.attack);
    }
  }

  // 检测战斗是否结束
  static isBattleOver(player: Character, enemy: Character): boolean {
    return player.isDead() || enemy.isDead();
  }

  // 获取胜利者
  static getWinner(player: Character, enemy: Character): Character | null {
    if (player.isDead() && enemy.isDead()) {
      return null; // 平局
    }
    if (player.isDead()) {
      return enemy;
    }
    if (enemy.isDead()) {
      return player;
    }
    return null; // 战斗未结束
  }
}
