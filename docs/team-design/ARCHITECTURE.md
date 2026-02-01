# 《剑来》横版格斗游戏 - 整体架构设计文档

## 1. 项目概述

### 1.1 项目背景
《剑来》是一款基于HarmonyOS平台的横版格斗游戏，采用ArkTS语言开发。游戏包含12个角色、4个阵营、4级AI难度。

### 1.2 技术栈
- **开发语言**: ArkTS (TypeScript-based)
- **UI框架**: ArkUI (声明式UI)
- **目标平台**: HarmonyOS (API Level 22+)
- **构建工具**: Hvigor
- **包管理**: OHPM

### 1.3 核心功能
- 12个可玩角色，4个阵营
- 4级AI难度（简单/普通/困难/极难）
- 技能系统（3个主动技能 + 1个必杀技）
- 剑气系统（攻击积攒，释放技能消耗）
- 模式切换（如陈平安的双形态）
- 99秒倒计时战斗

---

## 2. 模块架构

### 2.1 目录结构

```
entry/src/main/ets/
├── pages/                          # 页面层（UI入口）
│   ├── Index.ets                   # 游戏主页面
│   ├── MainMenu.ets                # 主菜单
│   ├── CharacterSelect.ets         # 角色选择
│   ├── DifficultySelect.ets        # 难度选择
│   └── GameResult.ets              # 结算界面
│
├── game/                           # 游戏核心逻辑
│   ├── GameEngine.ets              # 主引擎（游戏循环）
│   ├── BattleSystem.ets            # 战斗逻辑（伤害计算、胜负判定）
│   ├── CharacterManager.ets        # 角色管理（加载、创建）
│   ├── SkillManager.ets            # 技能系统（冷却、效果）
│   ├── AIController.ets            # AI逻辑（决策、执行）
│   ├── ModeManager.ets             # 模式切换（双形态角色）
│   ├── InputController.ets         # 输入控制（键盘、手势）
│   └── LevelSystem.ets             # 关卡管理（预留扩展）
│
├── components/                     # UI组件
│   ├── CharacterRenderer.ets       # 角色渲染
│   ├── HealthBar.ets               # 血条组件
│   ├── SkillButton.ets             # 技能按钮
│   ├── SkillButtonBar.ets          # 技能栏
│   └── ...                         # 更多UI组件
│
├── models/                         # 数据模型
│   ├── Character.ets               # 角色模型
│   ├── Skill.ets                   # 技能模型
│   ├── AIBehavior.ets              # AI行为配置
│   └── ...                         # 更多模型
│
├── utils/                          # 工具类
│   ├── CollisionDetector.ets       # 碰撞检测
│   ├── AudioManager.ets            # 音频管理
│   ├── ObjectPool.ets              # 对象池（预留）
│   └── ...                         # 更多工具
│
└── config/                         # 配置
    └── characters/                 # 角色JSON配置（预留）
```

### 2.2 模块职责说明

| 模块 | 职责 | 依赖 |
|------|------|------|
| **GameEngine** | 游戏主循环、更新、渲染、状态管理 | Character, BattleSystem, InputController |
| **BattleSystem** | 伤害计算、攻击判定、胜负判定、剑气系统 | Character, CollisionDetector |
| **CharacterManager** | 角色配置加载、角色创建、单例管理 | Character, Skill, ModeManager |
| **SkillManager** | 技能冷却、剑气管理、技能释放 | Skill, Character |
| **AIController** | AI决策、状态机、难度适配 | Character, AIBehavior, CollisionDetector |
| **ModeManager** | 双形态切换、属性继承、技能替换 | Character, Skill |
| **InputController** | 键盘输入、手势识别、状态映射 | Character |
| **Character** | 角色状态、属性、移动、攻击、受击 | Skill, ModeManager |
| **Skill** | 技能配置、冷却状态、可用性判断 | - |
| **CharacterRenderer** | Canvas角色绘制、动画状态显示 | Character |

---

## 3. 核心模块接口设计

### 3.1 CharacterManager（角色管理）

```typescript
// 角色数据配置接口
export interface CharacterData {
  id: string;
  name: string;
  faction: string;              // 阵营
  color: string;                // 角色颜色（渲染用）
  baseStats: BaseStatsConfig;
  skills: SkillConfig[];        // 3个普通技能
  ultimate: SkillConfig;        // 必杀技
  modeSwitch?: ModeSwitchConfig; // 模式切换配置（可选）
  martialMode?: ModeConfig;      // 备用模式配置（可选）
}

// 基础属性配置
export interface BaseStatsConfig {
  maxHp: number;
  currentHp: number;
  attack: number;
  defense: number;
  speed: number;
}

// 模式切换配置
export interface ModeSwitchConfig {
  hasAlternateMode: boolean;
  alternateMode?: string;
  switchCooldown: number;
}

// 模式配置
export interface ModeConfig {
  baseStats: ModeStats;
  skills: SkillConfig[];
  ultimate: SkillConfig;
}

export class CharacterManager {
  // 单例模式
  static getInstance(): CharacterManager;
  
  // 加载角色配置
  async loadAllCharacters(): Promise<void>;
  
  // 根据ID获取角色配置
  getCharacterConfig(id: string): CharacterData | undefined;
  
  // 获取所有角色
  getAllCharacters(): CharacterData[];
  
  // 根据阵营筛选角色
  getCharactersByFaction(faction: string): CharacterData[];
  
  // 从配置创建角色实例
  createCharacter(id: string): Character | null;
}
```

### 3.2 SkillManager（技能系统）

```typescript
export class SkillManager {
  // 构造函数
  constructor(skills: SkillConfig[], ultimate: SkillConfig);
  
  // 更新冷却
  update(deltaTime: number): void;
  
  // 使用技能（索引0-2）
  useSkill(index: number): boolean;
  
  // 使用必杀技
  useUltimate(): boolean;
  
  // 增加剑气
  addKi(amount: number): void;
  
  // 获取当前剑气
  getCurrentKi(): number;
  
  // 获取最大剑气
  getMaxKi(): number;
  
  // 获取剑气百分比
  getKiPercent(): number;
  
  // 获取技能配置
  getSkillConfig(index: number): SkillConfig | null;
  
  // 获取必杀技配置
  getUltimateConfig(): SkillConfig | null;
  
  // 检查技能是否可用
  canUseSkill(index: number): boolean;
  
  // 检查必杀技是否可用
  canUseUltimate(): boolean;
  
  // 获取技能冷却剩余时间（秒）
  getSkillCooldownRemaining(index: number): number;
  
  // 获取必杀技冷却剩余时间（秒）
  getUltimateCooldownRemaining(): number;
  
  // 替换技能列表（模式切换用）
  replaceSkills(skills: SkillConfig[], ultimate: SkillConfig): void;
}
```

### 3.3 BattleSystem（战斗逻辑）

```typescript
export class BattleSystem {
  // 处理攻击判定（返回是否击中）
  static handleAttack(attacker: Character, target: Character): boolean;
  
  // 处理技能伤害
  static handleSkillDamage(
    caster: Character,
    target: Character,
    skillIndex: number
  ): void;
  
  // 处理必杀技伤害
  static handleUltimateDamage(caster: Character, target: Character): void;
  
  // 检测战斗是否结束
  static isBattleOver(player: Character, enemy: Character): boolean;
  
  // 获取胜利者
  static getWinner(player: Character, enemy: Character): Character | null;
  
  // 剑气生成配置（常量）
  static readonly KI_FROM_ATTACK: number;  // 攻击获得剑气
  static readonly KI_FROM_HIT: number;     // 受击获得剑气
}
```

### 3.4 AIController（AI控制）

```typescript
// AI难度级别
export type AIDifficulty = 'easy' | 'normal' | 'hard' | 'extreme';

// AI状态枚举
export enum AIState {
  IDLE = 'idle',
  MOVE = 'move',
  ATTACK = 'attack',
  DEFEND = 'defend',
  CAST_SKILL = 'cast_skill'
}

// AI行为配置
export interface AIBehavior {
  difficulty: AIDifficulty;
  reactionTime: number;      // 反应时间（毫秒）
  blockRate: number;         // 格挡概率 (0-1)
  skillUsageRate: number;    // 技能使用率 (0-1)
  attackInterval: number;    // 攻击间隔（毫秒）
  canCombo: boolean;         // 是否会连招
  canPredict: boolean;       // 是否会预判
}

export class AIController {
  constructor(
    character: Character,
    target: Character,
    difficulty: AIDifficulty
  );
  
  // 更新AI（每帧调用）
  update(deltaTime: number): void;
  
  // 获取当前状态
  getCurrentState(): AIState;
  
  // 设置难度
  setDifficulty(difficulty: AIDifficulty): void;
  
  // 重置AI
  reset(): void;
}
```

### 3.5 LevelSystem（关卡管理）

```typescript
export interface LevelData {
  id: string;
  name: string;
  enemyId: string;          // 敌人角色ID
  enemyCount: number;       // 敌人数量（预留多敌）
  timeLimit: number;        // 时间限制（秒）
  background: string;       // 背景资源
  winCondition: WinCondition;
  dropRewards?: string[];   // 掉落奖励（预留）
}

export enum WinCondition {
  KILL_ALL = 'kill_all',    // 击杀所有敌人
  SURVIVE = 'survive',      // 存活时间
  COLLECT = 'collect'       // 收集物品（预留）
}

export class LevelSystem {
  static getInstance(): LevelSystem;
  
  // 加载关卡配置
  async loadLevels(): Promise<void>;
  
  // 获取所有关卡
  getAllLevels(): LevelData[];
  
  // 根据ID获取关卡
  getLevelById(id: string): LevelData | undefined;
  
  // 解锁关卡
  unlockLevel(id: string): void;
  
  // 检查关卡是否已解锁
  isLevelUnlocked(id: string): boolean;
  
  // 获取当前关卡进度
  getCurrentProgress(): number;
}
```

---

## 4. 数据流设计

### 4.1 角色数据流

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  JSON配置       │ -> │ CharacterManager │ -> │ Character实例   │ -> │ GameEngine      │
│  (config/)      │    │ loadAllCharacters│    │ (运行时)        │    │ update/render   │
└─────────────────┘    └──────────────────┘    └─────────────────┘    └─────────────────┘
                                                                   │
                                                                   v
                                                          ┌─────────────────┐
                                                          │ 结算/持久化     │
                                                          │ (数据统计)      │
                                                          └─────────────────┘
```

**流程说明：**
1. `CharacterManager.loadAllCharacters()` 加载JSON配置
2. `createCharacter(id)` 创建运行时Character实例
3. GameEngine每帧调用`character.update(deltaTime)`更新状态
4. 战斗结束后输出结算数据

### 4.2 战斗数据流

```
┌─────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ 用户输入    │ -> │ InputController │ -> │ Character状态   │ -> │ BattleSystem    │
│ (键盘/触摸) │    │ 处理按键映射    │    │ 位置/动作变化   │    │ 攻击判定/伤害   │
└─────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
                                                                   │
                               ┌───────────────────────────────────┘
                               v
                        ┌─────────────────┐    ┌─────────────────┐
                        │ SkillManager    │ -> │ 目标Character   │
                        │ 技能/冷却/剑气  │    │ 受击/状态更新   │
                        └─────────────────┘    └─────────────────┘
                                                   │
                                                   v
                                          ┌─────────────────┐
                                          │ CharacterRenderer│
                                          │ Canvas渲染      │
                                          └─────────────────┘
```

**关键时序：**
1. 用户按下攻击键 → InputController记录状态
2. Character状态变为ATTACKING
3. BattleSystem检测攻击判定窗口
4. 命中则计算伤害 → 目标takeDamage
5. 目标状态变为HURT
6. CharacterRenderer每帧渲染角色状态

### 4.3 UI数据流

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ GameEngine      │ -> │ UI回调函数      │ -> │ ArkUI组件       │
│ 每帧更新状态    │    │ updateUIFromGame│    │ @State变量驱动  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                      │
        │ 更新内容:             │
        │ - 玩家/敌人血量       │
        │ - 技能冷却剩余        │
        │ - 剑气值              │
        │ - 战斗结束状态        │
```

**实现方式：**
- GameEngine设置`setUIUpdateCallback()`
- 回调函数更新@State变量
- ArkUI自动重新渲染相关组件

---

## 5. 模块依赖关系

### 5.1 依赖图

```
                    ┌─────────────────┐
                    │   GameEngine    │  ◄── 主引擎（无上游依赖）
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        v                    v                    v
┌───────────────┐   ┌───────────────┐   ┌─────────────────┐
│ CharacterManager│   │ BattleSystem │   │ InputController │
└───────┬───────┘   └───────┬───────┘   └─────────────────┘
        │                   │
        v                   │
┌───────────────┐           │
│   Character   │◄──────────┘
└───────┬───────┘
        │
        ├──────────┬──────────────────┐
        │          │                  │
        v          v                  v
┌───────────┐ ┌───────────┐    ┌─────────────┐
│SkillManager│ │ModeManager│    │ AIBehavior  │
└─────┬─────┘ └─────┬─────┘    └─────────────┘
      │             │
      v             │
┌───────────┐       │
│   Skill   │◄──────┘
└───────────┘
```

### 5.2 工具类依赖

```
utils/
├── CollisionDetector.ets  ──► Character, Character
├── AudioManager.ets       ──► 无外部依赖（单例）
└── ObjectPool.ets         ──► 通用（预留）
```

### 5.3 避免循环依赖的原则

1. **单向依赖**: GameEngine → 其他模块，其他模块不依赖GameEngine
2. **接口隔离**: 使用TypeScript接口定义依赖，而非具体类
3. **工具类独立**: utils/ 中工具类不依赖game/ 模块
4. **事件驱动**: 模块间通信通过回调或事件，避免直接方法调用

---

## 6. 扩展指南

### 6.1 添加新角色

**需要修改的文件：**

1. **`game/CharacterManager.ets`** - 在`loadDefaultCharacters()`中添加新角色配置

```typescript
// 添加角色配置
const newCharacter: CharacterData = {
  id: 'new_character_id',
  name: '新角色名',
  faction: 'faction_name',  // 4阵营之一：swordsman/taoist/demon/etc.
  color: '#HEXCOLOR',
  baseStats: {
    maxHp: 1200,
    currentHp: 1200,
    attack: 120,
    defense: 55,
    speed: 6
  },
  skills: [
    { /* 技能1配置 */ },
    { /* 技能2配置 */ },
    { /* 技能3配置 */ }
  ],
  ultimate: { /* 必杀技配置 */ }
};
characterConfigs.set(newCharacter.id, newCharacter);
```

2. **`models/Character.ets`** - 如需新机制，扩展Character类

3. **`components/CharacterRenderer.ets`** - 如需特殊外观，添加渲染逻辑

**配置项说明：**

| 字段 | 说明 | 推荐范围 |
|------|------|----------|
| maxHp | 最大生命值 | 800-1500 |
| attack | 攻击力 | 80-150 |
| defense | 防御力 | 40-80 |
| speed | 移动速度 | 4-8 |
| kiCost | 技能剑气消耗 | 10-30 |
| cooldown | 技能冷却(ms) | 5000-15000 |

### 6.2 添加新关卡

**需要修改/创建的文件：**

1. **`game/LevelSystem.ets`** - 添加关卡配置

```typescript
const LEVEL_CONFIGS: LevelData[] = [
  {
    id: 'level_1',
    name: '新手村',
    enemyId: 'ning_ya',
    enemyCount: 1,
    timeLimit: 99,
    background: 'village_background',
    winCondition: WinCondition.KILL_ALL
  },
  // 新关卡配置...
];
```

2. **`config/levels/`** - 可选：独立的JSON关卡配置文件

**关卡配置结构：**

```typescript
interface LevelData {
  id: string;              // 关卡唯一ID
  name: string;            // 显示名称
  enemyId: string;         // 敌方角色ID
  enemyCount: number;      // 敌人数（预留）
  timeLimit: number;       // 时间限制（秒）
  background: string;      // 背景资源标识
  winCondition: WinCondition;  // 胜利条件
}
```

### 6.3 调整数值

**数值配置入口：**

1. **角色属性**: `game/CharacterManager.ets` - `baseStats`
2. **技能数值**: `game/CharacterManager.ets` - `skills[]` 和 `ultimate`
3. **AI行为**: `models/AIBehavior.ets` - `AIBehaviorFactory`
4. **战斗参数**: `game/BattleSystem.ets` - `KI_FROM_ATTACK`, `KI_FROM_HIT`
5. **角色常量**: `models/Character.ets` - `GROUND_Y`, `ATTACK_DURATION`

**快速调整示例：**

```typescript
// 增加剑气获得量
static readonly KI_FROM_ATTACK = 20;  // 原15
static readonly KI_FROM_HIT = 15;     // 原10

// 调整AI难度
static createHard(): AIBehavior {
  return {
    difficulty: 'hard',
    reactionTime: 150,    // 降低反应时间（更快）
    blockRate: 0.7,       // 提高格挡率
    skillUsageRate: 0.6,  // 提高技能使用率
    // ...
  };
}
```

---

## 7. 核心类图

### 7.1 Character 类

```
┌─────────────────────────────────────┐
│            Character                │
├─────────────────────────────────────┤
│ - id: string                        │
│ - name: string                      │
│ - state: CharacterState             │
│ - stats: CharacterStats             │
│ - x, y: number                      │
│ - velocityX, velocityY: number      │
│ - facing: number (1/-1)             │
├─────────────────────────────────────┤
│ + update(deltaTime): void           │
│ + moveLeft/Right(): void            │
│ + stopMoving(): void                │
│ + jump(): void                      │
│ + attack(): void                    │
│ + takeDamage(damage): void          │
│ + start/stopBlock(): void           │
│ + useSkill(index): boolean          │
│ + useUltimate(): boolean            │
│ + switchMode(): boolean             │
│ + isDead/isAttacking(): boolean     │
│ + getSkillManager(): SkillManager   │
│ + getModeManager(): ModeManager     │
└─────────────────────────────────────┘
```

### 7.2 GameEngine 类

```
┌─────────────────────────────────────┐
│            GameEngine               │
├─────────────────────────────────────┤
│ - isRunning: boolean                │
│ - player: Character                 │
│ - enemy: Character                  │
│ - inputController: InputController  │
│ - aiController: AIController        │
│ - battleOver: boolean               │
│ - winner: Character                 │
│ - playerCombo, enemyCombo: number   │
│ - battleTimer: number               │
├─────────────────────────────────────┤
│ + constructor(canvas, difficulty)   │
│ + start(): void                     │
│ + stop(): void                      │
│ + handleKeyDown(key): void          │
│ + handleKeyUp(key): void            │
│ + getPlayer(): Character            │
│ + getEnemy(): Character             │
│ + isBattleOver(): boolean           │
│ + setUIUpdateCallback(cb): void     │
└─────────────────────────────────────┘
```

---

## 8. 附录

### 8.1 角色阵营

| 阵营ID | 阵营名称 | 代表角色 |
|--------|----------|----------|
| swordsman | 剑修 | 陈平安、宁姚、阿良、左右 |
| taoist | 道士 | （预留） |
| demon | 妖魔 | （预留） |
| mortal | 凡人 | （预留） |

### 8.2 AI难度对照表

| 难度 | 反应时间 | 格挡率 | 技能率 | 攻击间隔 | 连招 | 预判 |
|------|----------|--------|--------|----------|------|------|
| easy | 1000ms | 0% | 0% | 4000ms | ❌ | ❌ |
| normal | 500ms | 30% | 20% | 2500ms | ❌ | ❌ |
| hard | 200ms | 60% | 50% | 1500ms | ✅ | ✅ |
| extreme | 100ms | 80% | 80% | 800ms | ✅ | ✅ |

### 8.3 技能类型

| 类型 | 说明 | 示例 |
|------|------|------|
| active | 主动技能 | 攻击技、增益技 |
| passive | 被动技能 | （预留） |
| ultimate | 必杀技 | 需要100剑气 |

---

## 版本信息

| 版本 | 日期 | 说明 |
|------|------|------|
| 1.0 | 2024-02-01 | 初始架构设计 |

---

*文档生成时间: 2024-02-01*
*项目路径: ~/Code/happ/Jianlai/*
