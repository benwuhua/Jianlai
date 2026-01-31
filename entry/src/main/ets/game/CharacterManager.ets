import { Character } from '../models/Character';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { util } from '@kit.ArkTS';
import { SkillManager } from './SkillManager';
import { ModeManager, ModeConfig } from './ModeManager';
import { SkillConfig } from '../models/Skill';
import { ModeStats } from './ModeManager';

const DOMAIN = 0x0000;
const TAG = 'CharacterManager';

// 模式切换配置
interface ModeSwitchConfig {
  hasAlternateMode: boolean;
  alternateMode?: string;
  switchCooldown: number;
}

// 角色基础属性配置
interface BaseStatsConfig {
  maxHp: number;
  currentHp: number;
  attack: number;
  defense: number;
  speed: number;
}

// 角色配置接口（从JSON加载）
export interface CharacterData {
  id: string;
  name: string;
  faction: string;
  color: string;
  baseStats: BaseStatsConfig;
  skills: SkillConfig[];
  ultimate: SkillConfig;
  modeSwitch?: ModeSwitchConfig;
  martialMode?: ModeConfig;
}

// 默认技能配置
const DEFAULT_SKILL: SkillConfig = {
  id: '',
  name: '',
  type: 'active',
  cooldown: 0,
  kiCost: 0,
  damage: 0,
  range: 0
};

// 空技能数组
const EMPTY_SKILLS: SkillConfig[] = [];

// 安全获取技能数组
function getSkillsArray(skills: SkillConfig[] | undefined): SkillConfig[] {
  return skills && skills.length > 0 ? skills : EMPTY_SKILLS;
}

// 安全获取终极技能
function getUltimateSkill(ultimate: SkillConfig | undefined): SkillConfig {
  return ultimate ? ultimate : DEFAULT_SKILL;
}

// 安全获取基础属性
function getBaseStats(stats: BaseStatsConfig | undefined): BaseStatsConfig {
  return stats ? stats : { maxHp: 1000, currentHp: 1000, attack: 100, defense: 50, speed: 5 };
}

// 转换 BaseStatsConfig 到 ModeStats
function convertToModeStats(stats: BaseStatsConfig): ModeStats {
  return {
    maxHp: stats.maxHp,
    currentHp: stats.currentHp,
    attack: stats.attack,
    defense: stats.defense,
    speed: stats.speed
  };
}

// 获取切换冷却时间
function getSwitchCooldown(cooldown: number | undefined): number {
  return cooldown && cooldown > 0 ? cooldown : 10000;
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

    // 使用 util.TextUtil 进行解码
    const textDecoder = new util.TextDecoder('utf-8');

    // 注意：HarmonyOS resourceManager 需要通过 context 获取
    // 这里直接使用默认角色，避免 API 兼容性问题
    // 如果需要从文件加载，需要在 Ability 中获取 context
    
    // 加载默认角色
    await this.loadDefaultCharacters();
  }

  // 加载默认角色（备用方案）
  private async loadDefaultCharacters(): Promise<void> {
    // 逐个添加角色，避免对象字面量问题
    
    // 角色1：陈平安
    const char1: CharacterData = {
      id: 'chen_pingan',
      name: '陈平安',
      faction: 'swordsman',
      color: '#4A90E2',
      baseStats: { maxHp: 1200, currentHp: 1200, attack: 110, defense: 60, speed: 5 },
      skills: [],
      ultimate: { id: 'ultimate_chen', name: '剑开天门', type: 'active', cooldown: 30, kiCost: 100, damage: 500, range: 300 }
    };
    this.characterConfigs.set(char1.id, char1);

    // 角色2：宁姚
    const char2: CharacterData = {
      id: 'ning_ya',
      name: '宁姚',
      faction: 'swordsman',
      color: '#E74C3C',
      baseStats: { maxHp: 1000, currentHp: 1000, attack: 130, defense: 50, speed: 7 },
      skills: [],
      ultimate: { id: 'ultimate_ning', name: '斩天帝', type: 'active', cooldown: 25, kiCost: 90, damage: 450, range: 350 }
    };
    this.characterConfigs.set(char2.id, char2);

    hilog.info(DOMAIN, TAG, 'Loaded %{public}d default characters', 2);
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
    character.stats = { maxHp: config.baseStats.maxHp, currentHp: config.baseStats.currentHp, attack: config.baseStats.attack, defense: config.baseStats.defense, speed: config.baseStats.speed };

    // 创建并设置技能管理器
    const skillManager = new SkillManager(getSkillsArray(config.skills), getUltimateSkill(config.ultimate));
    character.setSkillManager(skillManager);

    hilog.info(DOMAIN, TAG, 'Created character: %{public}s with %{public}d skills',
      config.name, (config.skills || []).length);

    return character;
  }
}
