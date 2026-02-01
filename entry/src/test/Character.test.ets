import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { Character, CharacterState, CharacterStats } from '../models/Character';
import { Skill, SkillConfig } from '../models/Skill';

export default function CharacterTest() {
  describe('CharacterTest', () => {
    let character: Character;

    beforeAll(() => {
      // 初始化测试角色
    });

    beforeEach(() => {
      character = new Character('test_id', '测试角色', 200, 500, '#4A90E2');
    });

    afterEach(() => {
      character = null;
    });

    afterAll(() => {
      // 清理
    });

    // 测试角色基本属性
    it('testCharacterBasicProperties', 0, () => {
      expect(character.id).assertEqual('test_id');
      expect(character.name).assertEqual('测试角色');
      expect(character.x).assertEqual(200);
      expect(character.y).assertEqual(500);
      expect(character.color).assertEqual('#4A90E2');
    });

    // 测试默认属性值
    it('testDefaultStats', 0, () => {
      expect(character.stats.maxHp).assertEqual(1000);
      expect(character.stats.currentHp).assertEqual(1000);
      expect(character.stats.attack).assertEqual(100);
      expect(character.stats.defense).assertEqual(50);
      expect(character.stats.speed).assertEqual(5);
    });

    // 测试默认状态
    it('testDefaultState', 0, () => {
      expect(character.state).assertEqual(CharacterState.IDLE);
      expect(character.facing).assertEqual(1);
    });

    // 测试移动方法
    it('testMoveLeft', 0, () => {
      character.moveLeft();
      expect(character.velocityX).assertLessThan(0);
      expect(character.facing).assertEqual(-1);
      expect(character.state).assertEqual(CharacterState.WALKING);
    });

    it('testMoveRight', 0, () => {
      character.moveRight();
      expect(character.velocityX).assertGreaterThan(0);
      expect(character.facing).assertEqual(1);
      expect(character.state).assertEqual(CharacterState.WALKING);
    });

    it('testStopMoving', 0, () => {
      character.moveRight();
      character.stopMoving();
      expect(character.velocityX).assertEqual(0);
      expect(character.state).assertEqual(CharacterState.IDLE);
    });

    // 测试攻击方法
    it('testAttack', 0, () => {
      character.attack();
      expect(character.state).assertEqual(CharacterState.ATTACKING);
      expect(character.attackDuration).assertGreaterThan(0);
      expect(character.attackCooldown).assertGreaterThan(0);
    });

    it('testAttackCooldown', 0, () => {
      character.attack();
      character.attack(); // 第二次攻击应该在冷却中
      expect(character.state).assertEqual(CharacterState.ATTACKING);
    });

    // 测试受伤害
    it('testTakeDamage', 0, () => {
      const initialHp = character.stats.currentHp;
      character.takeDamage(50);
      expect(character.stats.currentHp).assertEqual(initialHp - 50);
      expect(character.state).assertEqual(CharacterState.HURT);
    });

    it('testTakeDamageWithDefense', 0, () => {
      // 攻击力50，防御力50，实际伤害应为0
      character.takeDamage(50);
      expect(character.stats.currentHp).assertEqual(1000);
    });

    it('testTakeDamageDeath', 0, () => {
      character.stats.defense = 0;
      character.stats.currentHp = 100;
      character.takeDamage(100);
      expect(character.stats.currentHp).assertEqual(0);
      expect(character.isDead()).assertTrue();
    });

    // 测试格挡
    it('testBlock', 0, () => {
      character.startBlock();
      expect(character.isBlockingActive()).assertTrue();
      character.stopBlock();
      expect(character.isBlockingActive()).assertFalse();
    });

    it('testBlockReducesDamage', 0, () => {
      character.startBlock();
      character.takeDamage(60); // 60 - (50+30)防御力 = -20，向上取整为1
      expect(character.stats.currentHp).assertEqual(999); // 1000 - 1
    });

    // 测试技能相关
    it('testSetSkillManager', 0, () => {
      const skills: SkillConfig[] = [
        { id: 'test_skill', name: '测试技能', type: 'active', cooldown: 1000, kiCost: 20, damage: 100, range: 150 }
      ];
      const ultimate: SkillConfig = { id: 'test_ultimate', name: '测试必杀', type: 'ultimate', cooldown: 5000, kiCost: 100, damage: 300, range: 300 };

      const skillManager = new SkillManager(skills, ultimate);
      character.setSkillManager(skillManager);

      expect(character.getSkillManager()).not().assertNull();
    });

    // 测试死亡状态
    it('testIsDead', 0, () => {
      expect(character.isDead()).assertFalse();
      character.stats.currentHp = 0;
      expect(character.isDead()).assertTrue();
    });

    // 测试攻击状态
    it('testIsAttacking', 0, () => {
      expect(character.isAttacking()).assertFalse();
      character.attack();
      expect(character.isAttacking()).assertTrue();
    });

    // 测试伤害判定窗口
    it('testCanDealDamage', 0, () => {
      character.attack();
      // 攻击开始时应该在伤害窗口内
      expect(character.canDealDamage()).assertTrue();
    });

    // 测试更新方法
    it('testUpdate', 0, () => {
      character.moveRight();
      character.update(16);
      expect(character.x).assertGreaterThan(200);
    });

    // 测试跳跃
    it('testJump', 0, () => {
      character.jump();
      expect(character.velocityY).assertLessThan(0);
    });

    // 测试状态转换
    it('testStateTransitions', 0, () => {
      // 正常状态 -> 移动 -> 停止 -> 待机
      expect(character.state).assertEqual(CharacterState.IDLE);
      character.moveRight();
      expect(character.state).assertEqual(CharacterState.WALKING);
      character.stopMoving();
      expect(character.state).assertEqual(CharacterState.IDLE);

      // 正常状态 -> 攻击 -> 攻击结束 -> 待机
      character.attack();
      expect(character.state).assertEqual(CharacterState.ATTACKING);
    });

    // 测试剑气系统
    it('testKiSystem', 0, () => {
      const skills: SkillConfig[] = [
        { id: 'test_skill', name: '测试技能', type: 'active', cooldown: 1000, kiCost: 20, damage: 100, range: 150 }
      ];
      const ultimate: SkillConfig = { id: 'test_ultimate', name: '测试必杀', type: 'ultimate', cooldown: 5000, kiCost: 100, damage: 300, range: 300 };

      const skillManager = new SkillManager(skills, ultimate);
      character.setSkillManager(skillManager);

      character.addKi(50);
      expect(character.getCurrentKi()).assertEqual(50);
      expect(character.getKiPercent()).assertEqual(0.5);
    });
  });
}

import { SkillManager } from '../game/SkillManager';
