import { Character } from '../models/Character';
import { CollisionDetector } from '../utils/CollisionDetector';
import { AudioManager } from '../utils/AudioManager';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'BattleSystem';

export class BattleSystem {
  // 剑气生成配置 - 提高剑气获得量，让游戏更好玩
  private static readonly KI_FROM_ATTACK = 15; // 攻击获得剑气（原8）
  private static readonly KI_FROM_HIT = 10; // 受击获得剑气（原5）
  private static readonly KI_FROM_SKILL = 0; // 技能释放不获得剑气

  // 处理攻击判定 - 返回是否击中
  static handleAttack(attacker: Character, target: Character): boolean {
    // 检查攻击者是否正在攻击
    if (!attacker.isAttacking()) {
      return false;
    }

    // 检查是否在攻击范围内
    if (!CollisionDetector.checkAttackRange(attacker, target, 120)) {
      return false;
    }

    // 检查朝向是否正确
    const dx = target.x - attacker.x;
    const isFacingTarget = (attacker.facing === 1 && dx > 0) ||
                          (attacker.facing === -1 && dx < 0);

    if (!isFacingTarget) {
      return false;
    }

    // 造成伤害（避免重复判定：只在攻击开始时造成伤害）
    if (attacker.canDealDamage()) {
      const actualDamage = Math.max(1, attacker.stats.attack - target.stats.defense);
      target.takeDamage(actualDamage);

      // 生成剑气：攻击者和受击者都获得剑气
      attacker.addKi(BattleSystem.KI_FROM_ATTACK);
      target.addKi(BattleSystem.KI_FROM_HIT);

      AudioManager.getInstance().playHitSound();
      hilog.info(DOMAIN, TAG, '%{public}s hit %{public}s for %{public}d damage (attacker Ki: %{public}d, target Ki: %{public}d)',
        attacker.name, target.name, actualDamage, attacker.getCurrentKi(), target.getCurrentKi());
      
      return true;
    }
    
    return false;
  }

  // 处理技能伤害
  static handleSkillDamage(caster: Character, target: Character, skillIndex: number): void {
    const skillManager = caster.getSkillManager();
    if (!skillManager) {
      return;
    }

    const skillConfig = skillManager.getSkillConfig(skillIndex);
    if (!skillConfig) {
      return;
    }

    // 检查范围
    const distance = CollisionDetector.getDistance(caster, target);
    if (distance > skillConfig.range) {
      hilog.info(DOMAIN, TAG, 'Skill target out of range (distance: %{public}d, range: %{public}d)',
        distance, skillConfig.range);
      return;
    }

    // 检查朝向（对于定向技能）
    const dx = target.x - caster.x;
    const isFacingTarget = (caster.facing === 1 && dx > 0) ||
                          (caster.facing === -1 && dx < 0);

    if (!isFacingTarget && skillConfig.range < 300) {
      // 短距离技能需要朝向，远程全屏技能不需要
      return;
    }

    // 造成技能伤害
    const actualDamage = Math.max(1, skillConfig.damage - target.stats.defense);
    target.takeDamage(actualDamage);

    // 技能释放不获得剑气
    hilog.info(DOMAIN, TAG, '%{public}s used skill %{public}s on %{public}s for %{public}d damage',
      caster.name, skillConfig.name, target.name, actualDamage);
  }

  // 处理必杀技伤害
  static handleUltimateDamage(caster: Character, target: Character): void {
    const skillManager = caster.getSkillManager();
    if (!skillManager) {
      return;
    }

    const ultimateConfig = skillManager.getUltimateConfig();
    if (!ultimateConfig) {
      return;
    }

    // 必杀技通常是全屏或大范围
    const distance = CollisionDetector.getDistance(caster, target);
    if (distance > ultimateConfig.range) {
      return;
    }

    // 造成巨额伤害
    const actualDamage = Math.max(1, ultimateConfig.damage - target.stats.defense);
    target.takeDamage(actualDamage);

    hilog.info(DOMAIN, TAG, '%{public}s used ULTIMATE %{public}s on %{public}s for %{public}d damage',
      caster.name, ultimateConfig.name, target.name, actualDamage);
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
