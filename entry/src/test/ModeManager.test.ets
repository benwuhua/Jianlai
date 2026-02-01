import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { ModeManager, CharacterMode, ModeConfig, ModeStats } from '../game/ModeManager';
import { Character } from '../models/Character';
import { SkillConfig } from '../models/Skill';

export default function ModeManagerTest() {
  describe('ModeManagerTest', () => {
    let modeManager: ModeManager;
    let character: Character;
    let defaultSkills: SkillConfig[];
    let alternateSkills: SkillConfig[];
    let defaultUltimate: SkillConfig;
    let alternateUltimate: SkillConfig;
    let defaultStats: ModeStats;
    let alternateStats: ModeStats;

    beforeAll(() => {
      // 默认模式配置
      defaultSkills = [
        { id: 'sword_1', name: '剑式一', type: 'active', cooldown: 5000, kiCost: 15, damage: 100, range: 120 }
      ];
      defaultUltimate = { id: 'sword_ult', name: '剑道无双', type: 'ultimate', cooldown: 45000, kiCost: 80, damage: 400, range: 300 };
      defaultStats = { maxHp: 1500, currentHp: 1500, attack: 120, defense: 45, speed: 2.0 };

      // 备用模式配置
      alternateSkills = [
        { id: 'fist_1', name: '拳式一', type: 'active', cooldown: 4000, kiCost: 12, damage: 90, range: 80 }
      ];
      alternateUltimate = { id: 'fist_ult', name: '拳震天下', type: 'ultimate', cooldown: 50000, kiCost: 90, damage: 450, range: 250 };
      alternateStats = { maxHp: 1950, currentHp: 1950, attack: 144, defense: 56, speed: 1.6 };

      modeManager = new ModeManager(
        defaultSkills, defaultUltimate, defaultStats,
        alternateSkills, alternateUltimate, alternateStats,
        10000 // 10秒冷却
      );
    });

    beforeEach(() => {
      character = new Character('test', '测试角色', 200, 500, '#4A90E2');
    });

    afterEach(() => {
      character = null;
    });

    afterAll(() => {
      // 清理
    });

    // 测试初始化
    it('testInitialization', 0, () => {
      expect(modeManager.getCurrentMode()).assertEqual('default');
      expect(modeManager.canSwitch()).assertTrue();
      expect(modeManager.getCooldownRemaining()).assertEqual(0);
    });

    // 测试模式切换
    it('testSwitchMode', 0, () => {
      const newMode = modeManager.switchMode();
      expect(newMode).assertEqual('alternate');
      expect(modeManager.getCurrentMode()).assertEqual('alternate');
    });

    // 测试模式切换冷却
    it('testSwitchCooldown', 0, () => {
      modeManager.switchMode();
      expect(modeManager.canSwitch()).assertFalse();
      expect(modeManager.getCooldownRemaining()).assertEqual(10); // 10秒
    });

    // 测试冷却更新
    it('testCooldownUpdate', 0, () => {
      modeManager.switchMode();
      modeManager.update(5000); // 5秒后
      expect(modeManager.getCooldownRemaining()).assertEqual(5);
    });

    it('testCooldownComplete', 0, () => {
      modeManager.switchMode();
      modeManager.update(10000); // 10秒后
      expect(modeManager.canSwitch()).assertTrue();
    });

    // 测试多次切换
    it('testMultipleSwitches', 0, () => {
      modeManager.switchMode(); // 切换到alternate
      expect(modeManager.getCurrentMode()).assertEqual('alternate');

      modeManager.switchMode(); // 切换回default
      expect(modeManager.getCurrentMode()).assertEqual('default');
    });

    // 测试切换冷却中不能切换
    it('testCannotSwitchDuringCooldown', 0, () => {
      modeManager.switchMode();
      const currentMode = modeManager.switchMode(); // 尝试再次切换
      expect(currentMode).assertEqual('alternate'); // 模式不变
    });

    // 测试获取当前模式配置
    it('testGetCurrentModeConfig', 0, () => {
      const config = modeManager.getCurrentModeConfig();
      expect(config.stats.maxHp).assertEqual(1500);
      expect(config.skills.length).assertEqual(1);
      expect(config.ultimate.id).assertEqual('sword_ult');
    });

    it('testGetAlternateModeConfig', 0, () => {
      modeManager.switchMode();
      const config = modeManager.getCurrentModeConfig();
      expect(config.stats.maxHp).assertEqual(1950);
      expect(config.ultimate.id).assertEqual('fist_ult');
    });

    // 测试角色模式切换
    it('testCharacterModeSwitch', 0, () => {
      character.stats.maxHp = 1500;
      character.stats.currentHp = 1500;
      character.stats.attack = 120;

      modeManager.initialize(character, {
        baseStats: alternateStats,
        skills: alternateSkills,
        ultimate: alternateUltimate
      });
      character.setModeManager(modeManager);

      character.switchMode();

      // 模式切换后属性应该更新
      expect(character.getCurrentMode()).assertEqual('alternate');
      expect(character.stats.maxHp).assertEqual(1950);
      expect(character.stats.attack).assertEqual(144);
    });

    // 测试血量百分比保持
    it('testHpPercentMaintained', 0, () => {
      character.stats.maxHp = 1500;
      character.stats.currentHp = 750; // 50%
      character.stats.attack = 120;
      character.stats.defense = 45;

      modeManager.initialize(character, {
        baseStats: alternateStats,
        skills: alternateSkills,
        ultimate: alternateUltimate
      });
      character.setModeManager(modeManager);

      character.switchMode();

      // 切换后血量应该是新最大值的50%
      expect(character.stats.currentHp).assertEqual(975); // 1950 * 0.5
    });
  });
}
