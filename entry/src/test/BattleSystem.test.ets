import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { BattleSystem } from '../game/BattleSystem';
import { Character } from '../models/Character';
import { SkillManager } from '../game/SkillManager';
import { SkillConfig } from '../models/Skill';

export default function BattleSystemTest() {
  describe('BattleSystemTest', () => {
    let player: Character;
    let enemy: Character;
    let playerSkillManager: SkillManager;
    let enemySkillManager: SkillManager;

    beforeAll(() => {
      const skills: SkillConfig[] = [
        { id: 'test_skill', name: '测试技能', type: 'active', cooldown: 5000, kiCost: 20, damage: 100, range: 150 }
      ];
      const ultimate: SkillConfig = { id: 'test_ultimate', name: '测试必杀', type: 'ultimate', cooldown: 30000, kiCost: 100, damage: 300, range: 300 };

      playerSkillManager = new SkillManager(skills, ultimate);
      enemySkillManager = new SkillManager(skills, ultimate);
    });

    beforeEach(() => {
      player = new Character('player', '玩家', 200, 500, '#4A90E2');
      enemy = new Character('enemy', '敌人', 400, 500, '#E74C3C');
      player.setSkillManager(playerSkillManager);
      enemy.setSkillManager(enemySkillManager);
    });

    afterEach(() => {
      player = null;
      enemy = null;
    });

    afterAll(() => {
      // 清理
    });

    // 测试基础攻击判定
    it('testHandleAttack', 0, () => {
      player.attack();
      enemy.stats.defense = 30; // 降低防御力以确保造成伤害

      const result = BattleSystem.handleAttack(player, enemy);
      expect(result).assertTrue();
      expect(enemy.stats.currentHp).assertLessThan(1000);
    });

    // 测试攻击未开始时不能命中
    it('testAttackNotStarted', 0, () => {
      const result = BattleSystem.handleAttack(player, enemy);
      expect(result).assertFalse();
    });

    // 测试朝向错误时不能命中
    it('testWrongFacing', 0, () => {
      player.moveLeft(); // 朝向左
      enemy.x = 400; // 敌人在右边
      player.attack();

      const result = BattleSystem.handleAttack(player, enemy);
      expect(result).assertFalse();
    });

    // 测试距离过远不能命中
    it('testOutOfRange', 0, () => {
      player.x = 200;
      enemy.x = 600; // 距离400像素，超过默认范围
      player.attack();

      const result = BattleSystem.handleAttack(player, enemy);
      expect(result).assertFalse();
    });

    // 测试战斗结束检测
    it('testBattleOver', 0, () => {
      expect(BattleSystem.isBattleOver(player, enemy)).assertFalse();

      enemy.stats.currentHp = 0;
      expect(BattleSystem.isBattleOver(player, enemy)).assertTrue();

      player.stats.currentHp = 0;
      expect(BattleSystem.isBattleOver(player, enemy)).assertTrue();
    });

    // 测试胜利者判断
    it('testGetWinner', 0, () => {
      expect(BattleSystem.getWinner(player, enemy)).assertNull();

      enemy.stats.currentHp = 0;
      expect(BattleSystem.getWinner(player, enemy)).assertEqual(player);

      player.stats.currentHp = 0;
      expect(BattleSystem.getWinner(player, enemy)).assertNull(); // 平局
    });

    // 测试剑气生成
    it('testKiGeneration', 0, () => {
      player.attack();
      BattleSystem.handleAttack(player, enemy);

      expect(player.getCurrentKi()).assertEqual(BattleSystem.KI_FROM_ATTACK);
      expect(enemy.getCurrentKi()).assertEqual(BattleSystem.KI_FROM_HIT);
    });

    // 测试技能伤害
    it('testSkillDamage', 0, () => {
      enemy.stats.defense = 0;
      BattleSystem.handleSkillDamage(player, enemy, 0);

      expect(enemy.stats.currentHp).assertLessThan(1000);
    });

    // 测试必杀技伤害
    it('testUltimateDamage', 0, () => {
      enemy.stats.defense = 0;
      BattleSystem.handleUltimateDamage(player, enemy);

      expect(enemy.stats.currentHp).assertLessThan(1000);
    });

    // 测试伤害计算
    it('testDamageCalculation', 0, () => {
      const initialEnemyHp = enemy.stats.currentHp;
      player.stats.attack = 100;
      enemy.stats.defense = 50;
      player.attack();
      BattleSystem.handleAttack(player, enemy);

      // 伤害应该是 100 - 50 = 50
      expect(enemy.stats.currentHp).assertEqual(initialEnemyHp - 50);
    });

    // 测试最小伤害为1
    it('testMinimumDamage', 0, () => {
      const initialEnemyHp = enemy.stats.currentHp;
      player.stats.attack = 30;
      enemy.stats.defense = 50; // 防御力大于攻击力
      player.attack();
      BattleSystem.handleAttack(player, enemy);

      // 最小伤害应该是1
      expect(enemy.stats.currentHp).assertEqual(initialEnemyHp - 1);
    });

    // 测试连续攻击
    it('testMultipleAttacks', 0, () => {
      enemy.stats.defense = 0;
      const initialHp = enemy.stats.currentHp;

      player.attack();
      BattleSystem.handleAttack(player, enemy);

      // 等待攻击结束
      player.update(500);

      player.attack();
      BattleSystem.handleAttack(player, enemy);

      expect(enemy.stats.currentHp).assertEqual(initialHp - 200); // 两次100点伤害
    });

    // 测试范围外技能
    it('testSkillOutOfRange', 0, () => {
      player.x = 200;
      enemy.x = 1000; // 超出技能范围
      enemy.stats.defense = 0;

      BattleSystem.handleSkillDamage(player, enemy, 0);

      // 敌人应该没有受到伤害
      expect(enemy.stats.currentHp).assertEqual(1000);
    });
  });
}
