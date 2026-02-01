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
  range: 0,
  effect: ''
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

// 阵营颜色映射
const FACTION_COLORS: Record<string, string> = {
  'swordsman': '#4A90E2',    // 剑仙 - 蓝色
  'taoist': '#2E86AB',        // 儒道 - 深蓝
  'buddhist': '#D64933',      // 佛道 - 橙红
  'demon': '#6C1B1B',         // 妖族 - 暗红
  'other': '#8E44AD'          // 其他 - 紫色
};

// 阵营名称映射
const FACTION_NAMES: Record<string, string> = {
  'swordsman': '剑仙',
  'taoist': '儒道',
  'buddhist': '佛道',
  'demon': '妖族',
  'other': '其他'
};

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

    // 加载默认角色
    await this.loadDefaultCharacters();
  }

  // 加载默认角色（完整12角色配置）
  private async loadDefaultCharacters(): Promise<void> {
    // ========== 剑仙阵营（4个角色）==========

    // 角色1：陈平安 - 剑仙 - 双模式主角
    const char1: CharacterData = {
      id: 'chen_pingan',
      name: '陈平安',
      faction: 'swordsman',
      color: FACTION_COLORS['swordsman'],
      baseStats: {
        maxHp: 1500,
        currentHp: 1500,
        attack: 120,
        defense: 45,
        speed: 2.0
      },
      skills: [
        {
          id: 'jianqi_jinwei',
          name: '剑气近卫',
          type: 'active',
          cooldown: 6000,
          kiCost: 20,
          damage: 144, // 120% 攻击力
          range: 150,
          effect: '击退',
          description: '对前方单体造成120%攻击力伤害，击退2米，命中后恢复10点剑气'
        },
        {
          id: 'tongtian_quan',
          name: '拳意通天',
          type: 'active',
          cooldown: 10000,
          kiCost: 35,
          damage: 216, // 180% 攻击力
          range: 200,
          effect: '眩晕',
          description: '切换至拳法模式并释放冲击波，对范围内敌人造成180%伤害并眩晕1.5秒'
        },
        {
          id: 'xinjian_huti',
          name: '心剑护体',
          type: 'active',
          cooldown: 15000,
          kiCost: 30,
          damage: 0,
          range: 0,
          effect: '护盾',
          description: '为自身添加护盾，吸收伤害量为攻击力×2.0，持续6秒'
        }
      ],
      ultimate: {
        id: 'jian_kai_tianmen',
        name: '剑开天门',
        type: 'ultimate',
        cooldown: 45000,
        kiCost: 80,
        damage: 360, // 300% 攻击力
        range: 400,
        effect: '无敌',
        description: '对范围内所有敌人造成300%攻击力伤害，释放期间无敌，切换至剑术模式'
      },
      modeSwitch: {
        hasAlternateMode: true,
        alternateMode: 'martial',
        switchCooldown: 10000
      },
      martialMode: {
        baseStats: {
          maxHp: 1950, // +30%
          currentHp: 1950,
          attack: 144, // +20%
          defense: 56, // +25%
          speed: 1.6
        },
        skills: [
          {
            id: 'quan_gu',
            name: '拳贯',
            type: 'active',
            cooldown: 5000,
            kiCost: 15,
            damage: 132,
            range: 100,
            effect: '击飞',
            description: '拳击攻击，造成110%伤害并击飞敌人'
          },
          {
            id: 'tie_shan_zhang',
            name: '铁山掌',
            type: 'active',
            cooldown: 8000,
            kiCost: 25,
            damage: 204, // 120% 攻击力
            range: 180,
            effect: '眩晕',
            description: '掌击敌人，造成120%伤害并眩晕1秒'
          },
          {
            id: 'jin_gangbu',
            name: '金刚步',
            type: 'active',
            cooldown: 12000,
            kiCost: 20,
            damage: 0,
            range: 0,
            effect: '闪避',
            description: '进入闪避状态3秒，期间移动速度提升50%'
          }
        ],
        ultimate: {
          id: 'dao_qi_tianxia',
          name: '倒骑牛天下',
          type: 'ultimate',
          cooldown: 50000,
          kiCost: 90,
          damage: 420,
          range: 300,
          effect: '连击',
          description: '连续攻击5次，每次造成84%伤害，最后一击击倒敌人'
        }
      }
    };
    this.characterConfigs.set(char1.id, char1);

    // 角色2：宁姚 - 剑仙 - 高爆发飞剑手
    const char2: CharacterData = {
      id: 'ning_ya',
      name: '宁姚',
      faction: 'swordsman',
      color: '#E74C3C',
      baseStats: {
        maxHp: 1200,
        currentHp: 1200,
        attack: 140,
        defense: 35,
        speed: 2.4
      },
      skills: [
        {
          id: 'feijian_chuanyun',
          name: '飞剑穿云',
          type: 'active',
          cooldown: 5000,
          kiCost: 18,
          damage: 210, // 150% 攻击力
          range: 400,
          effect: '追踪',
          description: '发射三把飞剑，每把造成150%攻击力伤害，可追踪目标'
        },
        {
          id: 'jianyu_liuxing',
          name: '剑雨流星',
          type: 'active',
          cooldown: 12000,
          kiCost: 40,
          damage: 280, // 200% 攻击力（10把×80%）
          range: 350,
          effect: '范围',
          description: '召唤剑雨覆盖前方区域，每把飞剑造成80%伤害，共10把'
        },
        {
          id: 'yujian_feixing',
          name: '御剑飞行',
          type: 'active',
          cooldown: 20000,
          kiCost: 35,
          damage: 140, // 100% 攻击力
          range: 300,
          effect: '无敌',
          description: '向后闪现15米，过程中无敌，并自动发射5把飞剑攻击沿途敌人'
        }
      ],
      ultimate: {
        id: 'wanjian_guizong',
        name: '万剑归宗',
        type: 'ultimate',
        cooldown: 60000,
        kiCost: 100,
        damage: 560, // 400% 攻击力
        range: 600,
        effect: '地毯轰炸',
        description: '召唤100把飞剑进行地毯式轰炸，每把造成40%攻击力伤害'
      }
    };
    this.characterConfigs.set(char2.id, char2);

    // 角色3：阿良 - 剑仙 - 全能剑术大师
    const char3: CharacterData = {
      id: 'aliang',
      name: '阿良',
      faction: 'swordsman',
      color: '#9B59B6',
      baseStats: {
        maxHp: 1400,
        currentHp: 1400,
        attack: 125,
        defense: 50,
        speed: 1.9
      },
      skills: [
        {
          id: 'jian_tiao_cangqiong',
          name: '剑挑苍穹',
          type: 'active',
          cooldown: 6000,
          kiCost: 22,
          damage: 163, // 130% 攻击力
          range: 120,
          effect: '击飞',
          description: '上挑攻击，造成130%伤害并击飞敌人1秒'
        },
        {
          id: 'hengsao_qianjun',
          name: '横扫千军',
          type: 'active',
          cooldown: 8000,
          kiCost: 28,
          damage: 200, // 160% 攻击力
          range: 200,
          effect: '减防',
          description: '180度范围攻击，造成160%伤害，命中敌人减少其防御10%持续4秒'
        },
        {
          id: 'jianxin_tongming',
          name: '剑心通明',
          type: 'active',
          cooldown: 18000,
          kiCost: 30,
          damage: 0,
          range: 0,
          effect: '增益',
          description: '提升自身攻击速度30%和移动速度20%，持续8秒'
        }
      ],
      ultimate: {
        id: 'jiandao_wushuang',
        name: '剑道无双',
        type: 'ultimate',
        cooldown: 50000,
        kiCost: 75,
        damage: 400, // 320% 攻击力（12次×80%）
        range: 250,
        effect: '击倒',
        description: '连续释放12次剑击，每次造成80%伤害，最后一击击倒范围内所有敌人'
      }
    };
    this.characterConfigs.set(char3.id, char3);

    // 角色4：左右 - 剑仙 - 剑气领域控制者
    const char4: CharacterData = {
      id: 'zuoyou',
      name: '左右',
      faction: 'swordsman',
      color: '#3498DB',
      baseStats: {
        maxHp: 1350,
        currentHp: 1350,
        attack: 130,
        defense: 48,
        speed: 1.8
      },
      skills: [
        {
          id: 'jianqi_lingyu',
          name: '剑气领域',
          type: 'active',
          cooldown: 10000,
          kiCost: 25,
          damage: 104, // 80% 攻击力 × 6秒
          range: 250,
          effect: '领域减速',
          description: '释放半径6米的剑气领域，持续6秒，每秒造成80%伤害并减速20%'
        },
        {
          id: 'jianwang_huihui',
          name: '剑网恢恢',
          type: 'active',
          cooldown: 14000,
          kiCost: 35,
          damage: 182, // 140% 攻击力
          range: 200,
          effect: '束缚',
          description: '释放剑气大网束缚敌人3秒，造成140%伤害，束缚期间敌人无法移动'
        },
        {
          id: 'renjian_heyi',
          name: '人剑合一',
          type: 'active',
          cooldown: 20000,
          kiCost: 40,
          damage: 0,
          range: 0,
          effect: '穿透',
          description: '进入人剑合一状态，攻击附带穿透效果，持续10秒'
        }
      ],
      ultimate: {
        id: 'jianqi_huaxing',
        name: '剑气化形',
        type: 'ultimate',
        cooldown: 55000,
        kiCost: 90,
        damage: 455, // 350% 攻击力
          range: 300,
          effect: '眩晕',
          description: '召唤巨型剑气人形，对范围内敌人造成350%伤害并造成2秒眩晕'
      }
    };
    this.characterConfigs.set(char4.id, char4);

    // ========== 儒道阵营（2个角色）==========

    // 角色5：齐静春 - 儒道 - 阵法辅助增益
    const char5: CharacterData = {
      id: 'qi_jingchun',
      name: '齐静春',
      faction: 'taoist',
      color: '#3D5A80',
      baseStats: {
        maxHp: 1600,
        currentHp: 1600,
        attack: 90,
        defense: 55,
        speed: 1.5
      },
      skills: [
        {
          id: 'rujia_zhengqi',
          name: '儒家正气',
          type: 'active',
          cooldown: 12000,
          kiCost: 20,
          damage: 0,
          range: 300,
          effect: '增益',
          description: '为自身和范围内友军增加攻击力15%和防御力10%，持续8秒'
        },
        {
          id: 'fazhen_kunxian',
          name: '阵法·困仙',
          type: 'active',
          cooldown: 15000,
          kiCost: 30,
          damage: 54, // 60% 攻击力
          range: 250,
          effect: '减速减攻速',
          description: '布置困阵，使范围内敌人减速40%并降低攻击速度20%，持续6秒'
        },
        {
          id: 'haoran_tiandi',
          name: '浩然天地',
          type: 'active',
          cooldown: 25000,
          kiCost: 45,
          damage: 0,
          range: 300,
          effect: '治疗',
          description: '恢复范围内所有友军生命值，恢复量为齐静春攻击力×1.5'
        }
      ],
      ultimate: {
        id: 'wendao_zhisheng',
        name: '文道至圣',
        type: 'ultimate',
        cooldown: 70000,
        kiCost: 80,
        damage: 180, // 200% 攻击力
        range: 500,
        effect: '领域',
        description: '激活文道领域，10秒内场上所有友军属性提升30%，敌人属性降低20%'
      }
    };
    this.characterConfigs.set(char5.id, char5);

    // 角色6：崔东山 - 儒道 - 策略干扰者
    const char6: CharacterData = {
      id: 'cui_dongshan',
      name: '崔东山',
      faction: 'taoist',
      color: '#98C1D9',
      baseStats: {
        maxHp: 1450,
        currentHp: 1450,
        attack: 100,
        defense: 52,
        speed: 1.7
      },
      skills: [
        {
          id: 'xinji_suanjin',
          name: '心机算尽',
          type: 'active',
          cooldown: 8000,
          kiCost: 18,
          damage: 80, // 80% 攻击力
          range: 200,
          effect: 'CD增加',
          description: '对单体造成80%伤害并使其下一个技能冷却增加3秒'
        },
        {
          id: 'celve_ganrao',
          name: '策略干扰',
          type: 'active',
          cooldown: 12000,
          kiCost: 25,
          damage: 100, // 100% 攻击力
          range: 250,
          effect: '暂停CD',
          description: '释放干扰波，使范围内敌人技能冷却计时暂停2秒'
        },
        {
          id: 'mian_guo_hai',
          name: '瞒天过海',
          type: 'active',
          cooldown: 18000,
          kiCost: 30,
          damage: 0,
          range: 0,
          effect: '隐身',
          description: '进入隐身状态3秒，下次攻击伤害提升80%并必定暴击'
        }
      ],
      ultimate: {
        id: 'yunchou_weibwo',
        name: '运筹帷幄',
        type: 'ultimate',
        cooldown: 60000,
        kiCost: 70,
        damage: 250, // 250% 攻击力
        range: 400,
        effect: '清除增益',
        description: '预判场上所有敌人下一次行动，提前布置反制措施，造成250%伤害并清除其增益效果'
      }
    };
    this.characterConfigs.set(char6.id, char6);

    // ========== 佛道阵营（2个角色）==========

    // 角色7：佛光大佛 - 佛道 - 坦克回血前排
    const char7: CharacterData = {
      id: 'foguang_dafo',
      name: '佛光大佛',
      faction: 'buddhist',
      color: FACTION_COLORS['buddhist'],
      baseStats: {
        maxHp: 2200,
        currentHp: 2200,
        attack: 85,
        defense: 75,
        speed: 1.2
      },
      skills: [
        {
          id: 'jinguang_huti',
          name: '金光护体',
          type: 'active',
          cooldown: 10000,
          kiCost: 15,
          damage: 0,
          range: 0,
          effect: '护盾',
          description: '为自身添加护盾，吸收伤害量为佛光大佛最大生命值的15%'
        },
        {
          id: 'fozhang_paiji',
          name: '佛掌拍击',
          type: 'active',
          cooldown: 8000,
          kiCost: 25,
          damage: 119, // 140% 攻击力
          range: 180,
          effect: '击退',
          description: '拍击前方敌人，造成140%伤害并击退3米'
        },
        {
          id: 'pudu_zhongsheng',
          name: '普度众生',
          type: 'active',
          cooldown: 20000,
          kiCost: 40,
          damage: 0,
          range: 300,
          effect: '治疗',
          description: '恢复自身和范围内友军生命值，恢复量为佛光大佛攻击力×2.0'
        }
      ],
      ultimate: {
        id: 'wanfo_chaozong',
        name: '万佛朝宗',
        type: 'ultimate',
        cooldown: 60000,
        kiCost: 80,
        damage: 238, // 280% 攻击力
        range: 250,
        effect: '无敌回血',
        description: '进入金身状态8秒，期间免疫所有伤害并持续恢复生命值，每秒恢复最大生命值的3%'
      }
    };
    this.characterConfigs.set(char7.id, char7);

    // 角色8：菩萨泥塑 - 佛道 - 法术金身输出
    const char8: CharacterData = {
      id: 'pusani_nisu',
      name: '菩萨泥塑',
      faction: 'buddhist',
      color: '#F4A261',
      baseStats: {
        maxHp: 1800,
        currentHp: 1800,
        attack: 110,
        defense: 60,
        speed: 1.4
      },
      skills: [
        {
          id: 'fashu_jinshen',
          name: '法术金身',
          type: 'active',
          cooldown: 12000,
          kiCost: 20,
          damage: 0,
          range: 0,
          effect: '减伤反弹',
          description: '激活金身护体，4秒内受到伤害降低40%，金身破碎时对周围敌人造成100%伤害'
        },
        {
          id: 'foguang_puzhao',
          name: '佛光普照',
          type: 'active',
          cooldown: 10000,
          kiCost: 28,
          damage: 165, // 150% 攻击力（法术伤害）
          range: 220,
          effect: '穿透',
          description: '释放扇形佛光攻击，造成150%法术伤害（无视30%防御）'
        },
        {
          id: 'nisu_jinshen',
          name: '泥塑金身',
          type: 'active',
          cooldown: 18000,
          kiCost: 35,
          damage: 0,
          range: 0,
          effect: '反弹',
          description: '提升自身防御力50%持续6秒，下一次受到的伤害反弹给攻击者'
        }
      ],
      ultimate: {
        id: 'pusadi_mei',
        name: '菩萨低眉',
        type: 'ultimate',
        cooldown: 55000,
        kiCost: 85,
        damage: 385, // 350% 攻击力
        range: 300,
        effect: '减攻速',
        description: '召唤菩萨虚影，对范围内敌人造成350%法术伤害并使其攻击速度降低30%持续5秒'
      }
    };
    this.characterConfigs.set(char8.id, char8);

    // ========== 妖族阵营（3个角色）==========

    // 角色9：王座大妖 - 妖族 - 高爆发变身输出
    const char9: CharacterData = {
      id: 'wangzuo_dayao',
      name: '王座大妖',
      faction: 'demon',
      color: '#6C1B1B',
      baseStats: {
        maxHp: 1600,
        currentHp: 1600,
        attack: 100,
        defense: 55,
        speed: 1.5
      },
      skills: [
        {
          id: 'yaoqi_shifang',
          name: '妖气释放',
          type: 'active',
          cooldown: 6000,
          kiCost: 15,
          damage: 90, // 90% 攻击力
          range: 200,
          effect: '妖气值',
          description: '释放妖气冲击波，造成90%伤害，命中敌人可积累「妖气值」'
        },
        {
          id: 'yaoya_tuxi',
          name: '獠牙突袭',
          type: 'active',
          cooldown: 10000,
          kiCost: 30,
          damage: 180, // 180% 攻击力
          range: 250,
          effect: '吸血',
          description: '快速突进至目标身后，造成180%伤害并恢复相当于伤害量15%的生命值'
        },
        {
          id: 'wangzuo_weiya',
          name: '王座威压',
          type: 'active',
          cooldown: 15000,
          kiCost: 35,
          damage: 120, // 120% 攻击力
          range: 300,
          effect: '眩晕',
          description: '释放王座威压，使范围内敌人眩晕2秒并降低攻击欲望'
        }
      ],
      ultimate: {
        id: 'yuangxing_juexing',
        name: '远古觉醒',
        type: 'ultimate',
        cooldown: 90000,
        kiCost: 100,
        damage: 0,
        range: 0,
        effect: '变身',
        description: '激活远古血脉，变身持续12秒，变身期间攻击力提升100%、速度提升50%，变身结束后虚弱3秒'
      },
      martialMode: {
        baseStats: {
          maxHp: 2400,
          currentHp: 2400,
          attack: 200,
          defense: 70,
          speed: 2.2
        },
        skills: [],
        ultimate: {
          id: 'yao_sheng_zaiqi',
          name: '妖生再起',
          type: 'ultimate',
          cooldown: 30000,
          kiCost: 0,
          damage: 300,
          range: 400,
          effect: '爆发',
          description: '变身后专用：释放全部妖力，造成300%伤害'
        }
      }
    };
    this.characterConfigs.set(char9.id, char9);

    // 角色10：搬山猿 - 妖族 - 力量范围伤害
    const char10: CharacterData = {
      id: 'banshan_yuan',
      name: '搬山猿',
      faction: 'demon',
      color: '#1B4332',
      baseStats: {
        maxHp: 1900,
        currentHp: 1900,
        attack: 115,
        defense: 65,
        speed: 1.3
      },
      skills: [
        {
          id: 'banshan_quan',
          name: '搬山拳',
          type: 'active',
          cooldown: 7000,
          kiCost: 22,
          damage: 161, // 140% 攻击力
          range: 150,
          effect: '冲击波',
          description: '强力拳击，造成140%伤害并产生冲击波，对周围敌人造成50%额外伤害'
        },
        {
          id: 'zhandang_bo',
          name: '震荡波',
          type: 'active',
          cooldown: 12000,
          kiCost: 35,
          damage: 184, // 160% 攻击力
          range: 250,
          effect: '击退',
          description: '猛击地面产生震荡波，对前方扇形区域敌人造成160%伤害并击退2米'
        },
        {
          id: 'kuangbao_zhili',
          name: '狂暴之力',
          type: 'active',
          cooldown: 20000,
          kiCost: 40,
          damage: 0,
          range: 0,
          effect: '狂暴',
          description: '进入狂暴状态6秒，攻击范围增加50%，攻击速度增加40%'
        }
      ],
      ultimate: {
        id: 'banshan_tianhai',
        name: '搬山填海',
        type: 'ultimate',
        cooldown: 50000,
        kiCost: 80,
        damage: 368, // 320% 攻击力
        range: 400,
        effect: '灼烧',
        description: '蓄力后向前方发射巨型能量球，命中后爆炸造成320%范围伤害并产生持续5秒的灼烧区域'
      }
    };
    this.characterConfigs.set(char10.id, char10);

    // 角色11：袁首 - 妖族 - 头脑妖术控制者
    const char11: CharacterData = {
      id: 'yuan_shou',
      name: '袁首',
      faction: 'demon',
      color: '#95D5B2',
      baseStats: {
        maxHp: 1550,
        currentHp: 1550,
        attack: 105,
        defense: 58,
        speed: 1.6
      },
      skills: [
        {
          id: 'yaoshu_miwu',
          name: '妖术·迷雾',
          type: 'active',
          cooldown: 10000,
          kiCost: 20,
          damage: 63, // 60% 攻击力
          range: 250,
          effect: '降命中',
          description: '释放妖术迷雾，使范围内敌人命中率降低30%持续5秒'
        },
        {
          id: 'yaoshu_hunluan',
          name: '妖术·混乱',
          type: 'active',
          cooldown: 14000,
          kiCost: 28,
          damage: 105, // 100% 攻击力
          range: 200,
          effect: '混乱',
          description: '使单体敌人进入混乱状态，攻击队友2秒'
        },
        {
          id: 'yaoshu_shufu',
          name: '妖术·束缚',
          type: 'active',
          cooldown: 18000,
          kiCost: 35,
          damage: 137, // 130% 攻击力
          range: 200,
          effect: '束缚',
          description: '召唤藤蔓束缚敌人3秒，造成130%伤害，束缚期间敌人无法行动'
        }
      ],
      ultimate: {
        id: 'yao_dao_tongtian',
        name: '妖道通天',
        type: 'ultimate',
        cooldown: 55000,
        kiCost: 75,
        damage: 315, // 300% 攻击力
        range: 350,
        effect: '眩晕',
        description: '释放全部妖力，对范围内所有敌人造成300%伤害并使其眩晕2秒'
      }
    };
    this.characterConfigs.set(char11.id, char11);

    // ========== 其他阵营（1个角色）==========

    // 角色12：白也 - 其他 - 诗剑双绝平衡型
    const char12: CharacterData = {
      id: 'bai_ye',
      name: '白也',
      faction: 'other',
      color: FACTION_COLORS['other'],
      baseStats: {
        maxHp: 1450,
        currentHp: 1450,
        attack: 135,
        defense: 50,
        speed: 2.1
      },
      skills: [
        {
          id: 'shi_yue_pojun',
          name: '诗曰·破军',
          type: 'active',
          cooldown: 6000,
          kiCost: 20,
          damage: 189, // 140% 攻击力
          range: 180,
          effect: '诗韵',
          description: '吟诵诗句后斩击，造成140%伤害并获得1层「诗韵」'
        },
        {
          id: 'shi_yue_liuxing',
          name: '诗曰·流星',
          type: 'active',
          cooldown: 10000,
          kiCost: 30,
          damage: 243, // 180% 攻击力
          range: 300,
          effect: '诗韵',
          description: '吟诵诗句后发射剑气，造成180%伤害，获得1层「诗韵」'
        },
        {
          id: 'shi_yue_shouhu',
          name: '诗曰·守护',
          type: 'active',
          cooldown: 15000,
          kiCost: 28,
          damage: 0,
          range: 0,
          effect: '护盾',
          description: '吟诵诗句形成护盾，吸收伤害量为白也攻击力×2.5，持续6秒'
        }
      ],
      ultimate: {
        id: 'shi_jian_heyi',
        name: '诗剑合一',
        type: 'ultimate',
        cooldown: 60000,
        kiCost: 90,
        damage: 540, // 400% 攻击力
        range: 400,
        effect: '诗韵强化',
        description: '释放诗意与剑意结合的最强一击，造成400%伤害，若有诗韵则每层额外增加100%伤害'
      }
    };
    this.characterConfigs.set(char12.id, char12);

    hilog.info(DOMAIN, TAG, 'Loaded %{public}d characters with full skill configurations', 12);
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

  // 获取阵营名称
  getFactionName(faction: string): string {
    return FACTION_NAMES[faction] || faction;
  }

  // 获取阵营颜色
  getFactionColor(faction: string): string {
    return FACTION_COLORS[faction] || '#636E72';
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
    character.stats = {
      maxHp: config.baseStats.maxHp,
      currentHp: config.baseStats.currentHp,
      attack: config.baseStats.attack,
      defense: config.baseStats.defense,
      speed: config.baseStats.speed
    };

    // 创建并设置技能管理器
    const skillManager = new SkillManager(getSkillsArray(config.skills), getUltimateSkill(config.ultimate));
    character.setSkillManager(skillManager);

    // 如果有模式切换配置，设置模式管理器
    if (config.modeSwitch && config.modeSwitch.hasAlternateMode && config.martialMode) {
      // ModeManager 构造函数需要7个参数
      // 需要显式转换 BaseStatsConfig 为 ModeStats 类型
      const defaultStats: ModeStats = {
        maxHp: config.baseStats.maxHp,
        currentHp: config.baseStats.currentHp,
        attack: config.baseStats.attack,
        defense: config.baseStats.defense,
        speed: config.baseStats.speed
      };
      const alternateStats: ModeStats = {
        maxHp: config.martialMode.baseStats.maxHp,
        currentHp: config.martialMode.baseStats.currentHp,
        attack: config.martialMode.baseStats.attack,
        defense: config.martialMode.baseStats.defense,
        speed: config.martialMode.baseStats.speed
      };
      const modeManager = new ModeManager(
        getSkillsArray(config.skills),           // defaultSkills
        getUltimateSkill(config.ultimate),       // defaultUltimate
        defaultStats,                            // defaultStats (显式转换)
        getSkillsArray(config.martialMode.skills), // alternateSkills
        getUltimateSkill(config.martialMode.ultimate), // alternateUltimate
        alternateStats,                          // alternateStats (显式转换)
        config.modeSwitch.switchCooldown         // switchCooldown
      );
      character.setModeManager(modeManager);
    }

    hilog.info(DOMAIN, TAG, 'Created character: %{public}s with faction: %{public}s, skills: %{public}d',
      config.name, this.getFactionName(config.faction), (config.skills || []).length);

    return character;
  }
}
