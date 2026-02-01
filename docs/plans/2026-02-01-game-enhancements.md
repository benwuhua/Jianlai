# 游戏增强功能实现计划

**创建日期**: 2026-02-01
**项目**: Jianlai 格斗游戏 (HarmonyOS/ArkTS)
**版本**: 1.0

---

## 目录

1. [概述](#概述)
2. [功能优先级](#功能优先级)
3. [功能一：暂停菜单 (高优先级)](#功能一暂停菜单-高优先级)
4. [功能二：音效系统 (高优先级)](#功能二音效系统-高优先级)
5. [功能三：KO/胜利效果 (中等优先级)](#功能三ko胜利效果-中等优先级)
6. [测试命令](#测试命令)
7. [实施时间线](#实施时间线)

---

## 概述

本文档详细描述了为 Jianlai 格斗游戏添加三项关键功能的完整实现计划：

1. **暂停菜单** - 按 ESC 或 P 键暂停游戏，显示恢复、重新开始、退出选项
2. **音效系统** - 完整的 AudioManager 实现，包含攻击、受击、跳跃、技能、KO 音效
3. **KO/胜利效果** - 战斗结束时的视觉特效，包括 KO 文字动画、角色淡出、重启按钮

### 现有项目结构

```
/Users/ryan/Code/happ/Jianlai/
├── entry/src/main/ets/
│   ├── game/
│   │   ├── GameEngine.ets      # 游戏主引擎
│   │   ├── BattleSystem.ets    # 战斗系统
│   │   ├── InputController.ets # 输入控制
│   │   └── ...
│   ├── pages/
│   │   └── Index.ets           # 游戏主页面
│   ├── components/
│   │   ├── CharacterRenderer.ets
│   │   └── ...
│   ├── utils/
│   │   └── AudioManager.ets    # 音效管理器(待完善)
│   └── models/
│       └── Character.ets
└── docs/
    └── plans/
```

---

## 功能优先级

| 优先级 | 功能 | 预估工时 | 依赖 |
|--------|------|----------|------|
| 高 | 暂停菜单 | 4-6 小时 | 无 |
| 高 | 音效系统 | 6-8 小时 | AudioManager 基础 |
| 中 | KO/胜利效果 | 4-6 小时 | 游戏结束状态 |

---

## 功能一：暂停菜单 (高优先级)

### 1.1 需求分析

**功能描述**: 当玩家按下 ESC 或 P 键时，暂停游戏循环，显示暂停菜单。

**功能要求**:
- 按 ESC 或 P 键触发暂停
- 显示半透明黑色背景遮罩
- 菜单选项: 继续游戏、重新开始、返回主菜单
- 暂停时游戏停止更新，但保持渲染
- 暂停状态下按任意菜单键或再次按 P/ESC 恢复

### 1.2 实现步骤

#### 步骤 1: 修改 GameEngine 添加暂停状态

**文件**: `/Users/ryan/Code/happ/Jianlai/entry/src/main/ets/game/GameEngine.ets`

```typescript
// 在 GameEngine 类中添加暂停相关状态和方法
export class GameEngine {
  // ... 现有属性 ...

  // 暂停状态（新增）
  private isPaused: boolean = false;
  private pauseCallback?: () => void;
  private resumeCallback?: () => void;

  // ... 现有构造函数和方法 ...

  // 设置暂停状态变化回调
  setPauseCallbacks(onPause: () => void, onResume: () => void): void {
    this.pauseCallback = onPause;
    this.resumeCallback = onResume;
  }

  // 切换暂停状态
  togglePause(): boolean {
    this.isPaused = !this.isPaused;

    if (this.isPaused) {
      hilog.info(DOMAIN, TAG, 'Game paused');
      if (this.pauseCallback) {
        this.pauseCallback();
      }
    } else {
      hilog.info(DOMAIN, TAG, 'Game resumed');
      // 重置帧时间，避免暂停期间的时间差
      this.lastFrameTime = Date.now();
      if (this.resumeCallback) {
        this.resumeCallback();
      }
    }

    return this.isPaused;
  }

  // 检查是否暂停
  isGamePaused(): boolean {
    return this.isPaused;
  }

  // 修改游戏循环以支持暂停
  private gameLoop(): void {
    if (!this.isRunning) return;

    // 暂停状态下只渲染，不更新逻辑
    if (this.isPaused) {
      this.render();
      setTimeout(() => this.gameLoop(), 16);
      return;
    }

    const currentTime = Date.now();
    const deltaTime = currentTime - this.lastFrameTime;
    this.lastFrameTime = currentTime;
    this.frameCount++;

    this.update(deltaTime);
    this.render();

    setTimeout(() => this.gameLoop(), 16);
  }

  // 修改 update 方法支持暂停
  private update(deltaTime: number): void {
    // 如果战斗结束或游戏暂停，停止更新
    if (this.battleOver || this.isPaused) {
      return;
    }

    // ... 其余现有更新逻辑 ...
  }

  // 添加重新开始功能
  restart(): void {
    hilog.info(DOMAIN, TAG, 'Restarting game');

    // 重置玩家状态
    this.player = this.createPlayer(this.characterId || 'chen_pingan');
    this.enemy = this.createEnemy('ning_ya');

    // 重置战斗状态
    this.battleOver = false;
    this.winner = null;
    this.battleTimer = BattleSystem.BATTLE_DURATION;
    this.lastTimerUpdate = 0;

    // 重置连击
    this.playerCombo = 0;
    this.enemyCombo = 0;
    this.comboTimer = 0;

    // 重置特效
    this.screenShake = 0;
    this.hitStop = 0;

    // 重置暂停状态
    this.isPaused = false;

    hilog.info(DOMAIN, TAG, 'Game restarted successfully');
  }

  // 保存角色ID用于重启
  private characterId?: string;
}
```

#### 步骤 2: 创建暂停菜单组件

**文件**: `/Users/ryan/Code/happ/Jianlai/entry/src/main/ets/components/PauseMenu.ets`

```typescript
import { router } from '@kit.ArkUI';

@Component
struct PauseMenu {
  @Prop isVisible: boolean = false;
  onResume: () => void = () => {};
  onRestart: () => void = () => {};
  onQuit: () => void = () => {};

  build() {
    if (!this.isVisible) {
      return;
    }

    // 背景遮罩
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor('#000000')
      .opacity(0.7)

    // 菜单内容
    Column() {
      // 标题
      Text('暂停')
        .fontSize(48)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 60 })

      // 继续游戏按钮
      Button('继续游戏')
        .width(250)
        .height(60)
        .fontSize(24)
        .fontColor('#FFFFFF')
        .backgroundColor('#4A90E2')
        .borderRadius(10)
        .onClick(() => {
          this.onResume();
        })
        .margin({ bottom: 20 })

      // 重新开始按钮
      Button('重新开始')
        .width(250)
        .height(60)
        .fontSize(24)
        .fontColor('#FFFFFF')
        .backgroundColor('#27AE60')
        .borderRadius(10)
        .onClick(() => {
          this.onRestart();
        })
        .margin({ bottom: 20 })

      // 返回主菜单按钮
      Button('返回主菜单')
        .width(250)
        .height(60)
        .fontSize(24)
        .fontColor('#FFFFFF')
        .backgroundColor('#E74C3C')
        .borderRadius(10)
        .onClick(() => {
          this.onQuit();
        })
        .margin({ bottom: 20 })
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
}

export { PauseMenu };
```

#### 步骤 3: 修改 Index.ets 集成暂停菜单

**文件**: `/Users/ryan/Code/happ/Jianlai/entry/src/main/ets/pages/Index.ets`

```typescript
import { PauseMenu } from '../components/PauseMenu';

// 在 Index struct 中添加
@State private showPauseMenu: boolean = false;

// 在 build() 方法的 Stack 中添加 PauseMenu
Stack() {
  // ... 现有 Canvas 和 UI ...

  // 暂停菜单（新增）
  PauseMenu({
    isVisible: this.showPauseMenu,
    onResume: () => {
      this.showPauseMenu = false;
      if (this.gameEngine) {
        this.gameEngine.togglePause();
      }
    },
    onRestart: () => {
      this.showPauseMenu = false;
      if (this.gameEngine) {
        this.gameEngine.restart();
        // 重置UI状态
        this.battleOver = false;
        this.winner = '';
        this.isVictory = false;
      }
    },
    onQuit: () => {
      router.replaceUrl({ url: 'pages/MainMenu' });
    }
  })
}

// 在 onKeyEvent 中处理暂停键
.onKeyEvent((event) => {
  if (event.keyCode === 27 || event.keyCode === 80) { // ESC = 27, P = 80
    if (event.type === 2) { // KeyDown
      if (this.gameEngine) {
        this.showPauseMenu = this.gameEngine.togglePause();
      }
    }
    return;
  }

  // ... 现有键盘处理 ...
})
```

### 1.3 文件清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `entry/src/main/ets/game/GameEngine.ets` | 修改 | 添加暂停状态和方法 |
| `entry/src/main/ets/components/PauseMenu.ets` | 新建 | 暂停菜单组件 |
| `entry/src/main/ets/pages/Index.ets` | 修改 | 集成暂停菜单和处理暂停键 |

---

## 功能二：音效系统 (高优先级)

### 2.1 需求分析

**功能描述**: 实现完整的音效管理系统，支持游戏中的各种音效播放。

**功能要求**:
- AudioManager 单例模式
- 支持音效类型: 攻击、受击、跳跃、技能、KO
- 音效音量控制
- 音效资源文件结构
- 异步加载和播放

### 2.2 实现步骤

#### 步骤 1: 创建音效资源目录结构

```bash
mkdir -p /Users/ryan/Code/happ/Jianlai/entry/src/main/resources/rawfile/sounds
```

**建议的音频文件结构**:
```
rawfile/sounds/
├── attack.wav         # 普通攻击
├── heavy_attack.wav   # 重攻击
├── hit.wav            # 受击
├── jump.wav           # 跳跃
├── skill_1.wav        # 技能1
├── skill_2.wav        # 技能2
├── skill_3.wav        # 技能3
├── ultimate.wav       # 必杀技
├── ko.wav             # KO音效
├── victory.wav        # 胜利音效
└── bgm.mp3            # 背景音乐(可选)
```

#### 步骤 2: 完善 AudioManager.ets

**文件**: `/Users/ryan/Code/happ/Jianlai/entry/src/main/ets/utils/AudioManager.ets`

```typescript
import { media } from '@kit.MediaKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'AudioManager';

// 音效类型枚举
export enum SoundType {
  ATTACK = 'attack',
  HEAVY_ATTACK = 'heavy_attack',
  HIT = 'hit',
  JUMP = 'jump',
  SKILL_1 = 'skill_1',
  SKILL_2 = 'skill_2',
  SKILL_3 = 'skill_3',
  ULTIMATE = 'ultimate',
  KO = 'ko',
  VICTORY = 'victory'
}

// 音频播放器封装
class SoundPlayer {
  private audioRenderer: media.AudioRenderer | null = null;
  private isPlaying: boolean = false;
  private soundType: SoundType;

  constructor(soundType: SoundType) {
    this.soundType = soundType;
  }

  async initialize(resourceId: number): Promise<void> {
    try {
      this.audioRenderer = await media.createAudioRenderer();
      await this.audioRenderer.setStreamType(media.AudioStreamType.MUSIC);
      hilog.info(DOMAIN, TAG, 'SoundPlayer initialized for: %{public}s', this.soundType);
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to initialize SoundPlayer: %{public}s', JSON.stringify(error));
    }
  }

  async play(volume: number = 1.0): Promise<void> {
    if (this.isPlaying || !this.audioRenderer) {
      return;
    }

    try {
      this.isPlaying = true;
      await this.audioRenderer.setVolume(volume);
      await this.audioRenderer.start();

      this.audioRenderer.on('end', () => {
        this.isPlaying = false;
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to play sound: %{public}s', JSON.stringify(error));
      this.isPlaying = false;
    }
  }

  async stop(): Promise<void> {
    if (this.audioRenderer && this.isPlaying) {
      try {
        await this.audioRenderer.stop();
        this.isPlaying = false;
      } catch (error) {
        hilog.error(DOMAIN, TAG, 'Failed to stop sound: %{public}s', JSON.stringify(error));
      }
    }
  }

  release(): void {
    if (this.audioRenderer) {
      this.audioRenderer.release();
      this.audioRenderer = null;
    }
  }
}

export class AudioManager {
  private static instance: AudioManager;
  private players: Map<SoundType, SoundPlayer> = new Map();
  private loadedSounds: Set<SoundType> = new Set();
  private masterVolume: number = 1.0;
  private sfxVolume: number = 1.0;

  private constructor() {
    this.initializeSounds();
  }

  static getInstance(): AudioManager {
    if (!AudioManager.instance) {
      AudioManager.instance = new AudioManager();
    }
    return AudioManager.instance;
  }

  private async initializeSounds(): Promise<void> {
    const sounds: SoundType[] = [
      SoundType.ATTACK, SoundType.HIT, SoundType.JUMP,
      SoundType.SKILL_1, SoundType.SKILL_2, SoundType.SKILL_3,
      SoundType.ULTIMATE, SoundType.KO, SoundType.VICTORY
    ];

    for (const sound of sounds) {
      await this.loadSound(sound);
    }
  }

  private async loadSound(soundType: SoundType): Promise<boolean> {
    if (this.loadedSounds.has(soundType)) {
      return true;
    }

    try {
      const resourceMgr = getContext().resourceManager;
      const resourceId = this.getResourceId(soundType);

      if (resourceId < 0) {
        hilog.warn(DOMAIN, TAG, 'Sound resource not found: %{public}s', soundType);
        return false;
      }

      const player = new SoundPlayer(soundType);
      await player.initialize(resourceId);
      this.players.set(soundType, player);
      this.loadedSounds.add(soundType);
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to load sound: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  private getResourceId(soundType: SoundType): number {
    const resourceMap: Record<SoundType, number> = {
      [SoundType.ATTACK]: $r('app.rawfile.sounds.attack').id,
      [SoundType.HEAVY_ATTACK]: $r('app.rawfile.sounds.heavy_attack').id,
      [SoundType.HIT]: $r('app.rawfile.sounds.hit').id,
      [SoundType.JUMP]: $r('app.rawfile.sounds.jump').id,
      [SoundType.SKILL_1]: $r('app.rawfile.sounds.skill_1').id,
      [SoundType.SKILL_2]: $r('app.rawfile.sounds.skill_2').id,
      [SoundType.SKILL_3]: $r('app.rawfile.sounds.skill_3').id,
      [SoundType.ULTIMATE]: $r('app.rawfile.sounds.ultimate').id,
      [SoundType.KO]: $r('app.rawfile.sounds.ko').id,
      [SoundType.VICTORY]: $r('app.rawfile.sounds.victory').id
    };
    return resourceMap[soundType] || -1;
  }

  async playSound(soundType: SoundType, volume?: number): Promise<void> {
    if (!this.loadedSounds.has(soundType)) {
      const loaded = await this.loadSound(soundType);
      if (!loaded) return;
    }

    const player = this.players.get(soundType);
    if (player) {
      const soundVolume = volume !== undefined ? volume : this.sfxVolume;
      await player.play(this.masterVolume * soundVolume);
    }
  }

  // 便捷播放方法
  playAttackSound(): void { this.playSound(SoundType.ATTACK); }
  playHitSound(): void { this.playSound(SoundType.HIT); }
  playJumpSound(): void { this.playSound(SoundType.JUMP); }
  playSkillSound(index: number): void {
    const sounds = [SoundType.SKILL_1, SoundType.SKILL_2, SoundType.SKILL_3];
    if (index >= 0 && index < sounds.length) {
      this.playSound(sounds[index]);
    }
  }
  playUltimateSound(): void { this.playSound(SoundType.ULTIMATE); }
  playKOSound(): void { this.playSound(SoundType.KO); }
  playVictorySound(): void { this.playSound(SoundType.VICTORY); }

  // 音量控制
  setMasterVolume(volume: number): void {
    this.masterVolume = Math.max(0, Math.min(1, volume));
  }

  setSfxVolume(volume: number): void {
    this.sfxVolume = Math.max(0, Math.min(1, volume));
  }

  getMasterVolume(): number { return this.masterVolume; }
  getSfxVolume(): number { return this.sfxVolume; }

  async stopAll(): Promise<void> {
    for (const player of this.players.values()) {
      await player.stop();
    }
  }

  release(): void {
    for (const player of this.players.values()) {
      player.release();
    }
    this.players.clear();
    this.loadedSounds.clear();
  }
}
```

#### 步骤 3: 在 BattleSystem 中集成音效

**文件**: `/Users/ryan/Code/happ/Jianlai/entry/src/main/ets/game/BattleSystem.ets`

```typescript
// 在 handleAttack 方法中，找到 AudioManager.getInstance().playHitSound();
// 在其后添加攻击音效
if (attacker.canDealDamage()) {
  const actualDamage = Math.max(1, attacker.stats.attack - target.stats.defense);
  target.takeDamage(actualDamage);
  attacker.addKi(BattleSystem.KI_FROM_ATTACK);
  target.addKi(BattleSystem.KI_FROM_HIT);

  // 播放受击和攻击音效
  AudioManager.getInstance().playHitSound();
  AudioManager.getInstance().playAttackSound();
}
```

#### 步骤 4: 在 Character 中添加跳跃音效

**文件**: `/Users/ryan/Code/happ/Jianlai/entry/src/main/ets/models/Character.ets`

```typescript
// 在 Character 类中添加 AudioManager 导入
import { AudioManager } from '../utils/AudioManager';

// 在 jump() 方法中
jump(): void {
  if (this.y >= this.groundY && !this.isJumping) {
    this.isJumping = true;
    this.velocityY = -this.jumpForce;
    this.y = this.groundY;
    AudioManager.getInstance().playJumpSound();
  }
}

// 在 attack() 方法中
attack(): void {
  if (this.canAttack()) {
    this.state = CharacterState.ATTACKING;
    this.attackTimer = this.attackDuration;
    AudioManager.getInstance().playAttackSound();
  }
}
```

### 2.3 文件清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `entry/src/main/resources/rawfile/sounds/` | 新建 | 音效资源目录 |
| `entry/src/main/ets/utils/AudioManager.ets` | 重写 | 完整的音效管理器 |
| `entry/src/main/ets/game/BattleSystem.ets` | 修改 | 集成攻击和受击音效 |
| `entry/src/main/ets/models/Character.ets` | 修改 | 集成跳跃和攻击音效 |

---

## 功能三：KO/胜利效果 (中等优先级)

### 3.1 需求分析

**功能描述**: 当角色被击败时，显示 KO 效果，包括文字动画、角色淡出、胜利界面。

**功能要求**:
- 战斗结束时显示 "KO!" 或 "Victory" 文字
- 文字动画效果（放大、闪烁）
- 失败角色淡出效果
- 胜利/失败界面
- 重新开始和返回菜单按钮

### 3.2 实现步骤

#### 步骤 1: 创建 KO 效果管理器

**文件**: `/Users/ryan/Code/happ/Jianlai/entry/src/main/ets/game/KOEffectsManager.ets`

```typescript
import { Character } from '../models/Character';
import { AudioManager, SoundType } from '../utils/AudioManager';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'KOEffectsManager';

export interface KOEffectState {
  isActive: boolean;
  animationProgress: number;
  koTextAlpha: number;
  koTextScale: number;
  defeatedCharacterAlpha: number;
  winner: Character | null;
  isPlayerVictory: boolean;
}

export class KOEffectsManager {
  private state: KOEffectState = {
    isActive: false,
    animationProgress: 0,
    koTextAlpha: 0,
    koTextScale: 0.5,
    defeatedCharacterAlpha: 1,
    winner: null,
    isPlayerVictory: false
  };

  private animationFrameId: number = 0;
  private canvas: CanvasRenderingContext2D | null = null;
  private screenWidth: number = 360;
  private screenHeight: number = 640;

  private static readonly KO_TEXT_APPEAR_DURATION = 500;
  private static readonly CHARACTER_FADE_DURATION = 1500;
  private static readonly FINAL_DELAY = 2000;

  constructor() {}

  initialize(canvas: CanvasRenderingContext2D, screenWidth: number, screenHeight: number): void {
    this.canvas = canvas;
    this.screenWidth = screenWidth;
    this.screenHeight = screenHeight;
  }

  triggerKO(winner: Character, loser: Character, isPlayerVictory: boolean): void {
    if (this.state.isActive) return;

    hilog.info(DOMAIN, TAG, 'Triggering KO effect. Winner: %{public}s', winner.name);

    this.state = {
      isActive: true,
      animationProgress: 0,
      koTextAlpha: 0,
      koTextScale: 0.5,
      defeatedCharacterAlpha: 1,
      winner: winner,
      isPlayerVictory: isPlayerVictory
    };

    AudioManager.getInstance().playKOSound();
    this.startAnimation();
  }

  private startAnimation(): void {
    const animate = () => {
      if (!this.state.isActive) return;
      this.update(16);
      this.render();
      if (this.state.animationProgress < 1) {
        this.animationFrameId = requestAnimationFrame(animate);
      }
    };
    this.animationFrameId = requestAnimationFrame(animate);
  }

  update(deltaTime: number): void {
    const totalDuration = KOEffectsManager.KO_TEXT_APPEAR_DURATION +
                         KOEffectsManager.CHARACTER_FADE_DURATION +
                         KOEffectsManager.FINAL_DELAY;
    this.state.animationProgress = Math.min(1, this.state.animationProgress + deltaTime / totalDuration);

    // KO文字动画 (0-0.25)
    if (this.state.animationProgress < 0.25) {
      const progress = this.state.animationProgress / 0.25;
      this.state.koTextAlpha = this.easeOutCubic(progress);
      this.state.koTextScale = 0.5 + 0.5 * this.easeOutBack(progress);
    }
    // 角色淡出 (0.25-0.6)
    else if (this.state.animationProgress < 0.6) {
      this.state.koTextAlpha = 1;
      this.state.koTextScale = 1;
      const progress = (this.state.animationProgress - 0.25) / 0.35;
      this.state.defeatedCharacterAlpha = 1 - this.easeOutCubic(progress);
    }
    // 最终延迟 (0.6-1.0)
    else {
      this.state.koTextAlpha = 1;
      this.state.koTextScale = 1;
      this.state.defeatedCharacterAlpha = 0;
    }
  }

  render(): void {
    if (!this.canvas) return;
    const ctx = this.canvas;

    // 背景遮罩
    ctx.fillStyle = `rgba(0, 0, 0, ${this.state.koTextAlpha * 0.3})`;
    ctx.fillRect(0, 0, this.screenWidth, this.screenHeight);

    // KO文字
    this.renderKOText(ctx);
    this.renderWinnerInfo(ctx);
  }

  private renderKOText(ctx: CanvasRenderingContext2D): void {
    if (this.state.koTextAlpha <= 0) return;

    ctx.save();
    const centerX = this.screenWidth / 2;
    const centerY = this.screenHeight / 2 - 100;

    ctx.fillStyle = `rgba(0, 0, 0, ${this.state.koTextAlpha * 0.5})`;
    ctx.font = `bold ${72 * this.state.koTextScale}px Arial`;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText('K.O.!', centerX + 4, centerY + 4);

    const textColor = this.state.isPlayerVictory ? '#FFD700' : '#FF4444';
    ctx.fillStyle = this.state.koTextAlpha > 0 ? textColor : '#FFFFFF';
    ctx.fillText('K.O.!', centerX, centerY);

    ctx.restore();
  }

  private renderWinnerInfo(ctx: CanvasRenderingContext2D): void {
    if (!this.state.winner || this.state.koTextAlpha < 0.5) return;

    ctx.save();
    const centerX = this.screenWidth / 2;
    const centerY = this.screenHeight / 2 + 50;

    ctx.fillStyle = `rgba(255, 255, 255, ${this.state.koTextAlpha})`;
    ctx.font = `bold ${36 * this.state.koTextScale}px Arial`;
    ctx.textAlign = 'center';
    ctx.fillText(this.state.winner.name, centerX, centerY);

    const resultText = this.state.isPlayerVictory ? 'Victory' : 'Defeat';
    const resultColor = this.state.isPlayerVictory ? '#FFD700' : '#FF6666';
    ctx.fillStyle = resultColor;
    ctx.font = `bold ${24 * this.state.koTextScale}px Arial`;
    ctx.fillText(resultText, centerX, centerY + 50);

    ctx.restore();
  }

  getDefeatedCharacterAlpha(): number {
    return this.state.defeatedCharacterAlpha;
  }

  isEffectComplete(): boolean {
    return this.state.animationProgress >= 1;
  }

  isActive(): boolean {
    return this.state.isActive;
  }

  reset(): void {
    this.state = {
      isActive: false,
      animationProgress: 0,
      koTextAlpha: 0,
      koTextScale: 0.5,
      defeatedCharacterAlpha: 1,
      winner: null,
      isPlayerVictory: false
    };
    if (this.animationFrameId) {
      cancelAnimationFrame(this.animationFrameId);
    }
  }

  private easeOutCubic(t: number): number {
    return 1 - Math.pow(1 - t, 3);
  }

  private easeOutBack(t: number): number {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    return 1 + c3 * Math.pow(t - 1, 3) + c1 * Math.pow(t - 1, 2);
  }
}
```

#### 步骤 2: 修改 GameEngine 集成 KO 效果

**文件**: `/Users/ryan/Code/happ/Jianlai/entry/src/main/ets/game/GameEngine.ets`

```typescript
import { KOEffectsManager } from './KOEffectsManager';

export class GameEngine {
  // ... 现有属性 ...

  // KO 效果管理器
  private koEffectsManager: KOEffectsManager;

  constructor(canvas: CanvasRenderingContext2D, difficulty: AIDifficulty = 'normal',
              playerCharacterId?: string, screenWidth?: number, screenHeight?: number) {
    // ... 现有初始化 ...
    this.koEffectsManager = new KOEffectsManager();
    // 初始化KO效果管理器
    this.koEffectsManager.initialize(canvas, this.screenWidth, this.screenHeight);
  }

  private render(): void {
    if (!this.canvas) return;

    const width = this.screenWidth;
    const height = this.screenHeight;

    this.canvas.clearRect(0, 0, width, height);

    this.canvas.save();
    if (this.screenShake > 0 && !this.koEffectsManager.isActive()) {
      const shakeX = (Math.random() - 0.5) * this.screenShake * 2;
      const shakeY = (Math.random() - 0.5) * this.screenShake * 2;
      this.canvas.translate(shakeX, shakeY);
    }

    this.canvas.fillStyle = '#2C3E50';
    this.canvas.fillRect(0, 0, width, height);
    this.canvas.fillStyle = '#34495E';
    this.canvas.fillRect(0, 500, width, height - 500);

    // 渲染角色（应用KO淡出效果）
    if (this.koEffectsManager.isActive()) {
      const alpha = this.koEffectsManager.getDefeatedCharacterAlpha();
      const enemy = this.getEnemy();
      this.renderWithAlpha(enemy, alpha);
    } else {
      CharacterRenderer.render(this.canvas, this.player);
      CharacterRenderer.render(this.canvas, this.enemy);
    }

    this.renderCombo(this.canvas);
    this.canvas.restore();

    // 渲染KO效果
    if (this.koEffectsManager.isActive()) {
      this.koEffectsManager.render();
    }
  }

  private renderWithAlpha(character: Character, alpha: number): void {
    if (!this.canvas || alpha <= 0) return;
    this.canvas.save();
    this.canvas.globalAlpha = alpha;
    CharacterRenderer.render(this.canvas, character);
    this.canvas.restore();
  }

  private update(deltaTime: number): void {
    // 如果战斗结束，更新KO效果
    if (this.battleOver) {
      if (this.koEffectsManager.isActive()) {
        this.koEffectsManager.update(deltaTime);
      }
      return;
    }
    // ... 其余更新逻辑 ...
  }

  private update(deltaTime: number): void {
    if (this.battleOver || this.isPaused) {
      if (this.koEffectsManager.isActive()) {
        this.koEffectsManager.update(deltaTime);
      }
      return;
    }

    // ... 其他更新逻辑 ...

    // 检测战斗结束
    if (BattleSystem.isBattleOver(this.player, this.enemy)) {
      this.battleOver = true;
      this.winner = BattleSystem.getWinner(this.player, this.enemy);

      const isPlayerVictory = this.winner === this.player;
      const winnerName = this.winner ? this.winner.name : '平局';

      hilog.info(DOMAIN, TAG, 'Battle over! Winner: %{public}s', winnerName);

      // 初始化KO效果管理器并触发效果
      this.koEffectsManager.initialize(this.canvas!, this.screenWidth, this.screenHeight);
      this.koEffectsManager.triggerKO(this.winner!, this.winner === this.player ? this.enemy : this.player, isPlayerVictory);

      // 播放胜利音效
      if (isPlayerVictory) {
        AudioManager.getInstance().playVictorySound();
      }

      // 更新UI
      if (this.uiUpdateCallback) {
        this.uiUpdateCallback(
          this.player.stats.currentHp,
          this.player.stats.maxHp,
          this.enemy.stats.currentHp,
          this.enemy.stats.maxHp,
          true,
          winnerName,
          isPlayerVictory,
          this.playerCombo,
          this.enemyCombo
        );
      }
    }
  }
}
```

#### 步骤 3: 创建 KO 胜利 UI 组件

**文件**: `/Users/ryan/Code/happ/Jianlai/entry/src/main/ets/components/VictoryScreen.ets`

```typescript
import { router } from '@kit.ArkUI';

@Component
struct VictoryScreen {
  @Prop isVictory: boolean = false;
  @Prop winnerName: string = '';
  onRestart: () => void = () => {};
  onQuit: () => void = () => {};

  build() {
    Column() {
      Blank()

      // KO文字动画
      Text('K.O.!')
        .fontSize(72)
        .fontColor(this.isVictory ? '#FFD700' : '#FF4444')
        .fontWeight(FontWeight.Bold)
        .animation({
          duration: 500,
          curve: Curve.EaseOut
        })

      // 胜利/失败文字
      Text(this.isVictory ? 'Victory' : 'Defeat')
        .fontSize(36)
        .fontColor('#FFFFFF')
        .margin({ top: 20 })

      // 获胜者名称
      Text(`${this.winnerName} 获胜`)
        .fontSize(24)
        .fontColor('#CCCCCC')
        .margin({ top: 10, bottom: 40 })

      // 操作按钮
      Row({ space: 20 }) {
        Button('再来一局')
          .width(150)
          .height(50)
          .fontSize(18)
          .fontColor('#FFFFFF')
          .backgroundColor('#27AE60')
          .borderRadius(10)
          .onClick(() => {
            this.onRestart();
          })

        Button('返回菜单')
          .width(150)
          .height(50)
          .fontSize(18)
          .fontColor('#FFFFFF')
          .backgroundColor('#E74C3C')
          .borderRadius(10)
          .onClick(() => {
            this.onQuit();
          })
      }
      .margin({ bottom: 100 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#000000DD')
  }
}

export { VictoryScreen };
```

#### 步骤 4: 修改 Index.ets 集成 KO 效果

**文件**: `/Users/ryan/Code/happ/Jianlai/entry/src/main/ets/pages/Index.ets`

```typescript
import { VictoryScreen } from '../components/VictoryScreen';

// 在 build() 方法中，替换现有的战斗结束界面
if (this.battleOver) {
  VictoryScreen({
    isVictory: this.isVictory,
    winnerName: this.winner,
    onRestart: () => {
      if (this.gameEngine) {
        this.gameEngine.restart();
        this.battleOver = false;
        this.winner = '';
        this.isVictory = false;
      }
    },
    onQuit: () => {
      router.replaceUrl({ url: 'pages/MainMenu' });
    }
  })
}
```

### 3.3 文件清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `entry/src/main/ets/game/KOEffectsManager.ets` | 新建 | KO 效果动画管理器 |
| `entry/src/main/ets/game/GameEngine.ets` | 修改 | 集成 KO 效果 |
| `entry/src/main/ets/components/VictoryScreen.ets` | 新建 | 胜利/失败 UI 界面 |
| `entry/src/main/ets/pages/Index.ets` | 修改 | 集成 KO UI |

---

## 测试命令

### 本地构建测试

```bash
# 进入项目目录
cd /Users/ryan/