import { Character } from '../models/Character';
import { hilog } from '@kit.PerformanceAnalysisKit';

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

    // 临时硬编码，后续使用ResourceManager读取
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

    hilog.info(DOMAIN, TAG, 'Loaded %{public}d characters', characters.length);
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

    return character;
  }
}
