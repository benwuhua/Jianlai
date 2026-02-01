import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { CharacterManager, CharacterData } from '../game/CharacterManager';
import { Character } from '../models/Character';

export default function CharacterManagerTest() {
  describe('CharacterManagerTest', () => {
    let characterManager: CharacterManager;

    beforeAll(async () => {
      characterManager = CharacterManager.getInstance();
      await characterManager.loadAllCharacters();
    });

    afterAll(() => {
      // 清理
    });

    // 测试单例模式
    it('testSingleton', 0, () => {
      const instance1 = CharacterManager.getInstance();
      const instance2 = CharacterManager.getInstance();
      expect(instance1).assertEqual(instance2);
    });

    // 测试角色配置加载
    it('testCharacterCount', 0, () => {
      const characters = characterManager.getAllCharacters();
      expect(characters.length).assertEqual(12);
    });

    // 测试获取特定角色
    it('testGetCharacterConfig', 0, () => {
      const config = characterManager.getCharacterConfig('chen_pingan');
      expect(config).not().assertNull();
      expect(config.name).assertEqual('陈平安');
      expect(config.faction).assertEqual('swordsman');
    });

    it('testGetNonExistentCharacter', 0, () => {
      const config = characterManager.getCharacterConfig('non_existent');
      expect(config).assertNull();
    });

    // 测试阵营过滤
    it('testGetCharactersByFaction', 0, () => {
      const swordsmen = characterManager.getCharactersByFaction('swordsman');
      expect(swordsmen.length).assertEqual(4);

      const taoists = characterManager.getCharactersByFaction('taoist');
      expect(taoists.length).assertEqual(2);

      const buddhists = characterManager.getCharactersByFaction('buddhist');
      expect(buddhists.length).assertEqual(2);

      const demons = characterManager.getCharactersByFaction('demon');
      expect(demons.length).assertEqual(3);

      const others = characterManager.getCharactersByFaction('other');
      expect(others.length).assertEqual(1);
    });

    // 测试阵营名称
    it('testGetFactionName', 0, () => {
      expect(characterManager.getFactionName('swordsman')).assertEqual('剑仙');
      expect(characterManager.getFactionName('taoist')).assertEqual('儒道');
      expect(characterManager.getFactionName('buddhist')).assertEqual('佛道');
      expect(characterManager.getFactionName('demon')).assertEqual('妖族');
      expect(characterManager.getFactionName('other')).assertEqual('其他');
      expect(characterManager.getFactionName('unknown')).assertEqual('unknown');
    });

    // 测试阵营颜色
    it('testGetFactionColor', 0, () => {
      const swordsmanColor = characterManager.getFactionColor('swordsman');
      expect(swordsmanColor).assertEqual('#4A90E2');

      const demonColor = characterManager.getFactionColor('demon');
      expect(demonColor).assertEqual('#6C1B1B');
    });

    // 测试创建角色实例
    it('testCreateCharacter', 0, () => {
      const character = characterManager.createCharacter('chen_pingan');
      expect(character).not().assertNull();
      expect(character.name).assertEqual('陈平安');
      expect(character.stats.maxHp).assertEqual(1500);
      expect(character.stats.attack).assertEqual(120);
      expect(character.getSkillManager()).not().assertNull();
    });

    it('testCreateNonExistentCharacter', 0, () => {
      const character = characterManager.createCharacter('non_existent');
      expect(character).assertNull();
    });

    // 测试角色技能配置
    it('testCharacterSkills', 0, () => {
      const character = characterManager.createCharacter('ning_ya');
      expect(character).not().assertNull();

      const skillManager = character.getSkillManager();
      expect(skillManager.getSkillCount()).assertEqual(3);
      expect(skillManager.getSkillConfig(0).name).assertEqual('飞剑穿云');
      expect(skillManager.getSkillConfig(1).name).assertEqual('剑雨流星');
      expect(skillManager.getUltimateConfig().name).assertEqual('万剑归宗');
    });

    // 测试双模式角色
    it('testDualModeCharacter', 0, () => {
      const character = characterManager.createCharacter('chen_pingan');
      expect(character.hasAlternateMode()).assertTrue();

      const modeManager = character.getModeManager();
      expect(modeManager).not().assertNull();
    });

    // 测试角色属性
    it('testCharacterStats', 0, () => {
      const character = characterManager.createCharacter('banshan_yuan');
      expect(character.stats.maxHp).assertEqual(1900);
      expect(character.stats.attack).assertEqual(115);
      expect(character.stats.defense).assertEqual(65);
      expect(character.stats.speed).assertEqual(1.3);
    });

    // 测试所有角色都能创建
    it('testAllCharactersCreatable', 0, () => {
      const characterIds = [
        'chen_pingan', 'ning_ya', 'aliang', 'zuoyou',
        'qi_jingchun', 'cui_dongshan',
        'foguang_dafo', 'pusani_nisu',
        'wangzuo_dayao', 'banshan_yuan', 'yuan_shou',
        'bai_ye'
      ];

      for (const id of characterIds) {
        const character = characterManager.createCharacter(id);
        expect(character).not().assertNull(`Character ${id} should be creatable`);
      }
    });

    // 测试技能管理器初始化
    it('testSkillManagerInitialized', 0, () => {
      const character = characterManager.createCharacter('chen_pingan');
      const skillManager = character.getSkillManager();

      expect(skillManager.getSkillConfig(0).kiCost).assertEqual(20);
      expect(skillManager.getSkillConfig(1).kiCost).assertEqual(35);
      expect(skillManager.getSkillConfig(2).kiCost).assertEqual(30);
      expect(skillManager.getUltimateConfig().kiCost).assertEqual(80);
    });
  });
}
