import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { SkillManager } from '../game/SkillManager';
import { SkillConfig } from '../models/Skill';

export default function SkillManagerTest() {
  describe('SkillManagerTest', () => {
    let skillManager: SkillManager;
    let skills: SkillConfig[];
    let ultimate: SkillConfig;

    beforeAll(() => {
      skills = [
        {
          id: 'jianqi_jinwei',
          name: '剑气近卫',
          type: 'active',
          cooldown: 6000,
          kiCost: 20,
          damage: 144,
          range: 150,
          effect: '击退'
        },
        {
          id: 'tongtian_quan',
          name: '拳意通天',
          type: 'active',
          cooldown: 10000,
          kiCost: 35,
          damage: 216,
          range: 200,
          effect: '眩晕'
        },
        {
          id: 'xinjian_huti',
          name: '心剑护体',
          type: 'active',
          cooldown: 15000,
          kiCost: 30,
          damage: 0,
          range: 0,
          effect: '护盾'
        }
      ];

      ultimate = {
        id: 'jian_kai_tianmen',
        name: '剑开天门',
        type: 'ultimate',
        cooldown: 45000,
        kiCost: 80,
        damage: 360,
        range: 400,
        effect: '无敌'
      };
    });

    beforeEach(() => {
      skillManager = new SkillManager(skills, ultimate);
    });

    afterEach(() => {
      skillManager = null;
    });

    afterAll(() => {
      // 清理
    });

    // 测试初始化
    it('testInitialization', 0, () => {
      expect(skillManager.getSkillCount()).assertEqual(3);
      expect(skillManager.getCurrentKi()).assertEqual(0);
      expect(skillManager.getMaxKi()).assertEqual(100);
      expect(skillManager.getKiPercent()).assertEqual(0);
    });

    // 测试使用技能
    it('testUseSkill', 0, () => {
      skillManager.addKi(50);
      const result = skillManager.useSkill(0);
      expect(result).assertTrue();
      expect(skillManager.getCurrentKi()).assertEqual(30); // 50 - 20
    });

    // 测试技能冷却检查
    it('testSkillOnCooldown', 0, () => {
      skillManager.addKi(50);
      skillManager.useSkill(0);
      const result = skillManager.useSkill(0);
      expect(result).assertFalse(); // 技能在冷却中
    });

    // 测试剑气不足
    it('testInsufficientKi', 0, () => {
      skillManager.addKi(10); // 只有10点剑气
      const result = skillManager.useSkill(0); // 需要20点
      expect(result).assertFalse();
    });

    // 测试无效技能索引
    it('testInvalidSkillIndex', 0, () => {
      skillManager.addKi(100);
      const result = skillManager.useSkill(99);
      expect(result).assertFalse();
    });

    // 测试必杀技
    it('testUseUltimate', 0, () => {
      skillManager.addKi(100);
      const result = skillManager.useUltimate();
      expect(result).assertTrue();
      expect(skillManager.getCurrentKi()).assertEqual(0); // 必杀技消耗所有剑气
    });

    it('testUltimateNotReady', 0, () => {
      skillManager.addKi(100);
      skillManager.useUltimate();
      const result = skillManager.useUltimate();
      expect(result).assertFalse(); // 必杀技在冷却中
    });

    it('testUltimateInsufficientKi', 0, () => {
      skillManager.addKi(50); // 剑气不足
      const result = skillManager.useUltimate();
      expect(result).assertFalse();
    });

    // 测试增加剑气
    it('testAddKi', 0, () => {
      skillManager.addKi(30);
      expect(skillManager.getCurrentKi()).assertEqual(30);
      skillManager.addKi(50);
      expect(skillManager.getCurrentKi()).assertEqual(80);
      skillManager.addKi(50); // 超过最大值
      expect(skillManager.getCurrentKi()).assertEqual(100);
    });

    // 测试技能冷却时间获取
    it('testCooldownRemaining', 0, () => {
      skillManager.addKi(100);
      skillManager.useSkill(0);
      const cooldown = skillManager.getSkillCooldownRemaining(0);
      expect(cooldown).assertGreaterThan(0);
    });

    // 测试更新冷却
    it('testUpdate', 0, () => {
      skillManager.addKi(100);
      skillManager.useSkill(0);
      skillManager.update(7000); // 7秒后，技能冷却6秒
      expect(skillManager.canUseSkill(0)).assertTrue();
    });

    // 测试技能配置获取
    it('testGetSkillConfig', 0, () => {
      const config = skillManager.getSkillConfig(0);
      expect(config).not().assertNull();
      expect(config.id).assertEqual('jianqi_jinwei');
      expect(config.name).assertEqual('剑气近卫');
    });

    it('testGetUltimateConfig', 0, () => {
      const config = skillManager.getUltimateConfig();
      expect(config).not().assertNull();
      expect(config.id).assertEqual('jian_kai_tianmen');
    });

    // 测试无效索引返回null
    it('testInvalidIndexReturnsNull', 0, () => {
      expect(skillManager.getSkillConfig(99)).assertNull();
    });

    // 测试技能替换
    it('testReplaceSkills', 0, () => {
      const newSkills: SkillConfig[] = [
        { id: 'new_skill_1', name: '新技能1', type: 'active', cooldown: 2000, kiCost: 10, damage: 50, range: 100 }
      ];
      const newUltimate: SkillConfig = { id: 'new_ultimate', name: '新必杀', type: 'ultimate', cooldown: 30000, kiCost: 90, damage: 400, range: 350 };

      skillManager.replaceSkills(newSkills, newUltimate);
      expect(skillManager.getSkillCount()).assertEqual(1);
      expect(skillManager.getSkillConfig(0).id).assertEqual('new_skill_1');
      expect(skillManager.getUltimateConfig().id).assertEqual('new_ultimate');
    });
  });
}
