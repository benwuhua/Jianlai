import { Character } from '../models/Character';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { resourceManager } from '@kit.LocalizationKit';
import { SkillManager } from './SkillManager';
import { ModeManager } from './ModeManager';

const DOMAIN = 0x0000;
const TAG = 'CharacterManager';

// 角色配置接口（从JSON加载）
export interface CharacterData {
  id: string;
  name: string;
  faction: string;
  color: string;
  baseStats: {
    maxHp: number;
    currentHp: number;
    attack: number;
    defense: number;
    speed: number;
  };
  skills: any[];
  ultimate: any;
  modeSwitch?: any;
  martialMode?: any;
}

export class CharacterManager {
  private static instance: CharacterManager;
  private characterConfigs: Map<string, CharacterData> = new Map();

  private constructor() {}

  static getInstance(): CharacterManager {
    if (!CharacterManager.instance) {
      CharacterManager.instance = new CharacterManager();
    }
    return CharacterManager.instance;
  }

  // 加载所有角色配置
  async loadAllCharacters(): Promise<void> {
    hilog.info(DOMAIN, TAG, 'Loading character configurations...');

    try {
      // 读取所有角色JSON文件
      const characterFiles = [
        'chen_pingan.json',
        'ning_ya.json',
        'aliang.json',
        'cao_qing_lang.json',
        'luo_shi_huang.json',
        'po_jun.json',
        'wen_shu.json',
        'xu_mao.json',
        'yu_li_zi.json',
        'zhong_kui.json'
      ];

      for (const fileName of characterFiles) {
        try {
          const fileData = await resourceManager.getRawFileDescriptor(`characters/${fileName}`);
          const content = await fileData.readText();
          const charData: CharacterData = JSON.parse(content);

          this.characterConfigs.set(charData.id, charData);
          hilog.info(DOMAIN, TAG, 'Loaded character: %{public}s', charData.name);
        } catch (fileError) {
          hilog.warn(DOMAIN, TAG, 'Failed to load %{public}s: %{public}s', fileName, JSON.stringify(fileError));
        }
      }

      hilog.info(DOMAIN, TAG, 'Loaded %{public}d characters total', this.characterConfigs.size);

      // 如果没有加载到任何角色，使用默认配置
      if (this.characterConfigs.size === 0) {
        hilog.warn(DOMAIN, TAG, 'No characters loaded, using default configuration');
        await this.loadDefaultCharacters();
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to load characters: %{public}s', JSON.stringify(error));
      // 加载失败时使用默认配置
      await this.loadDefaultCharacters();
    }
  }

  // 加载默认角色（备用方案）
  private async loadDefaultCharacters(): Promise<void> {
    const characters: CharacterData[] = [
      {
        id: 'chen_pingan',
        name: '陈平安',
        faction: 'swordsman',
        color: '#4A90E2',
        baseStats: { maxHp: 1200, currentHp: 1200, attack: 110, defense: 60, speed: 5 },
        skills: [],
        ultimate: {}
      },
      {
        id: 'ning_ya',
        name: '宁姚',
        faction: 'swordsman',
        color: '#E74C3C',
        baseStats: { maxHp: 1000, currentHp: 1000, attack: 130, defense: 50, speed: 7 },
        skills: [],
        ultimate: {}
      }
    ];

    characters.forEach(char => {
      this.characterConfigs.set(char.id, char);
    });

    hilog.info(DOMAIN, TAG, 'Loaded %{public}d default characters', characters.length);
  }

  // 根据ID获取角色配置
  getCharacterConfig(id: string): CharacterData | undefined {
    return this.characterConfigs.get(id);
  }

  // 获取所有角色配置
  getAllCharacters(): CharacterData[] {
    return Array.from(this.characterConfigs.values());
  }

  // 根据阵营获取角色
  getCharactersByFaction(faction: string): CharacterData[] {
    return this.getAllCharacters().filter(char => char.faction === faction);
  }

  // 从配置创建Character实例
  createCharacter(id: string): Character | null {
    const config = this.getCharacterConfig(id);
    if (!config) {
      hilog.error(DOMAIN, TAG, 'Character not found: %{public}s', id);
      return null;
    }

    const character = new Character(
      config.id,
      config.name,
      200,
      500,
      config.color
    );

    // 设置属性
    character.stats = { ...config.baseStats };

    // 创建并设置技能管理器
    const skillManager = new SkillManager(config.skills || [], config.ultimate || {});
    character.setSkillManager(skillManager);

    // 如果有双模式，创建并设置模式管理器
    if (config.modeSwitch && config.modeSwitch.hasAlternateMode && config.martialMode) {
      const modeManager = new ModeManager(
        config.skills || [],
        config.ultimate || {},
        config.baseStats,
        config.martialMode.skills || [],
        config.martialMode.ultimate || {},
        config.martialMode.baseStats,
        config.modeSwitch.switchCooldown || 10000
      );
      character.setModeManager(modeManager);

      hilog.info(DOMAIN, TAG, 'Character %{public}s has alternate mode', config.name);
    }

    hilog.info(DOMAIN, TAG, 'Created character: %{public}s with %{public}d skills',
      config.name, (config.skills || []).length);

    return character;
  }
}
