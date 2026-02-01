import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { Skill, SkillConfig } from '../models/Skill';

export default function SkillTest() {
  describe('SkillTest', () => {
    let skill: Skill;
    let skillConfig: SkillConfig;

    beforeAll(() => {
      skillConfig = {
        id: 'test_skill',
        name: '测试技能',
        type: 'active',
        cooldown: 5000,
        kiCost: 20,
        damage: 100,
        range: 150,
        effect: '击退',
        description: '这是一个测试技能'
      };
    });

    beforeEach(() => {
      skill = new Skill(skillConfig);
    });

    afterEach(() => {
      skill = null;
    });

    afterAll(() => {
      // 清理
    });

    // 测试技能基本属性
    it('testSkillBasicProperties', 0, () => {
      expect(skill.config.id).assertEqual('test_skill');
      expect(skill.config.name).assertEqual('测试技能');
      expect(skill.config.type).assertEqual('active');
      expect(skill.config.cooldown).assertEqual(5000);
      expect(skill.config.kiCost).assertEqual(20);
      expect(skill.config.damage).assertEqual(100);
      expect(skill.config.range).assertEqual(150);
      expect(skill.config.effect).assertEqual('击退');
    });

    // 测试默认冷却
    it('testDefaultCooldown', 0, () => {
      expect(skill.remainingCooldown).assertEqual(0);
    });

    // 测试技能可用状态
    it('testCanUseInitially', 0, () => {
      expect(skill.canUse()).assertTrue();
    });

    // 测试使用技能后冷却
    it('testUseSkill', 0, () => {
      skill.use();
      expect(skill.canUse()).assertFalse();
      expect(skill.remainingCooldown).assertEqual(5000);
    });

    // 测试冷却更新
    it('testCooldownUpdate', 0, () => {
      skill.use();
      skill.update(3000); // 3秒
      expect(skill.remainingCooldown).assertEqual(2000);
      expect(skill.canUse()).assertFalse();
    });

    it('testCooldownComplete', 0, () => {
      skill.use();
      skill.update(5000); // 5秒后
      expect(skill.remainingCooldown).assertEqual(0);
      expect(skill.canUse()).assertTrue();
    });

    // 测试冷却不会变成负数
    it('testCooldownNotNegative', 0, () => {
      skill.use();
      skill.update(10000); // 超过冷却时间
      expect(skill.remainingCooldown).assertEqual(0);
    });

    // 测试必杀技配置
    it('testUltimateSkill', 0, () => {
      const ultimateConfig: SkillConfig = {
        id: 'test_ultimate',
        name: '测试必杀',
        type: 'ultimate',
        cooldown: 60000,
        kiCost: 100,
        damage: 500,
        range: 400,
        effect: '无敌',
        description: '最强必杀技'
      };

      const ultimateSkill = new Skill(ultimateConfig);
      expect(ultimateSkill.config.type).assertEqual('ultimate');
      expect(ultimateSkill.config.kiCost).assertEqual(100);
      expect(ultimateSkill.config.damage).assertEqual(500);
    });

    // 测试被动技能
    it('testPassiveSkill', 0, () => {
      const passiveConfig: SkillConfig = {
        id: 'passive_skill',
        name: '被动技能',
        type: 'passive',
        cooldown: 0,
        kiCost: 0,
        damage: 0,
        range: 0,
        effect: '增益',
        description: '被动增益技能'
      };

      const passiveSkill = new Skill(passiveConfig);
      expect(passiveSkill.config.type).assertEqual('passive');
      expect(passiveSkill.config.kiCost).assertEqual(0);
      expect(passiveSkill.canUse()).assertTrue();
    });

    // 测试多次使用技能
    it('testMultipleSkillUses', 0, () => {
      skill.use();
      skill.update(3000);
      skill.use(); // 应该在冷却中，使用失败
      expect(skill.remainingCooldown).assertGreaterThan(0);
    });
  });
}
