import { hilog } from '@kit.PerformanceAnalysisKit';
import { Character } from '../models/Character';
import { CharacterRenderer } from '../components/CharacterRenderer';
import { InputController } from './InputController';
import { CollisionDetector } from '../utils/CollisionDetector';
import { BattleSystem } from './BattleSystem';
import { AIController, AIState } from './AIController';
import { AIDifficulty } from '../models/AIBehavior';
import { CharacterManager } from './CharacterManager';

const DOMAIN = 0x0000;
const TAG = 'GameEngine';

// Canvas 上下文类型（使用 ArkTS 标准类型）
type GameCanvas = CanvasRenderingContext2D;

export class GameEngine {
  // 常量定义
  private static readonly LOG_FRAME_INTERVAL = 60; // 每60帧打印一次日志

  private isRunning: boolean = false;
  private lastFrameTime: number = 0;
  private canvas: GameCanvas | null = null;
  private frameCount: number = 0; // 帧计数器

  // 游戏对象
  private player: Character;
  private enemy: Character;
  private inputController: InputController;
  private aiController: AIController | null = null;
  private difficulty: AIDifficulty = 'normal';
  private battleOver: boolean = false;
  private winner: Character | null = null;
  private uiUpdateCallback?: (playerHp: number, playerMaxHp: number, enemyHp: number, enemyMaxHp: number, battleOver: boolean, winnerName: string, isVictory: boolean, playerCombo: number, enemyCombo: number) => void;

  // 屏幕尺寸（HarmonyOS CanvasRenderingContext2D 没有 width/height）
  private screenWidth: number = 360;  // 默认宽度
  private screenHeight: number = 640; // 默认高度

  // 连击系统
  private playerCombo: number = 0;
  private enemyCombo: number = 0;
  private comboTimer: number = 0;
  private static readonly COMBO_TIMEOUT = 2000; // 2秒内无攻击则连击归零

  // 战斗特效
  private screenShake: number = 0;
  private hitStop: number = 0;

  // 倒计时系统
  private battleTimer: number = 99; // 99秒倒计时
  private lastTimerUpdate: number = 0;
  private static readonly BATTLE_DURATION = 99; // 战斗时长（秒）
  private static readonly TIMER_UPDATE_INTERVAL = 1000; // 1秒更新一次

  constructor(canvas: CanvasRenderingContext2D, difficulty: AIDifficulty = 'normal', playerCharacterId?: string, screenWidth?: number, screenHeight?: number) {
    if (!canvas) {
      throw new Error('Canvas context cannot be null');
    }
    this.canvas = canvas;
    this.difficulty = difficulty;

    // 设置屏幕尺寸（如果提供）
    if (screenWidth) this.screenWidth = screenWidth;
    if (screenHeight) this.screenHeight = screenHeight;

    // 创建角色（使用CharacterManager或默认创建）
    this.player = this.createPlayer(playerCharacterId || 'chen_pingan');
    this.enemy = this.createEnemy('ning_ya'); // 默认敌人为宁姚

    // 创建输入控制器
    this.inputController = new InputController(this.player);

    // 创建AI控制器
    this.aiController = new AIController(this.enemy, this.player, this.difficulty);

    // 初始化战斗状态
    this.battleOver = false;

    hilog.info(DOMAIN, TAG, 'GameEngine initialized with difficulty: %{public}s, player: %{public}s, enemy: %{public}s',
      this.difficulty, this.player.name, this.enemy.name);
  }

  // 创建玩家角色
  private createPlayer(characterId: string): Character {
    const manager = CharacterManager.getInstance();
    const character = manager.createCharacter(characterId);

    if (character) {
      character.x = 200;
      return character;
    }

    // 默认角色
    const defaultChar = new Character('player', '陈平安', 200, 500, '#4A90E2');
    return defaultChar;
  }

  // 创建敌人角色
  private createEnemy(characterId: string): Character {
    const manager = CharacterManager.getInstance();
    const character = manager.createCharacter(characterId);

    if (character) {
      character.x = 600;
      character.facing = -1; // 面向左
      return character;
    }

    // 默认敌人
    const defaultChar = new Character('enemy', '敌人', 600, 500, '#E74C3C');
    defaultChar.facing = -1;
    return defaultChar;
  }

  // 设置难度
  setDifficulty(difficulty: AIDifficulty): void {
    this.difficulty = difficulty;
    if (this.aiController) {
      this.aiController.setDifficulty(difficulty);
    }
    hilog.info(DOMAIN, TAG, 'Difficulty set to: %{public}s', difficulty);
  }

  // 启动游戏循环
  start(): void {
    this.isRunning = true;
    this.lastFrameTime = Date.now();
    this.gameLoop();
  }

  // 停止游戏循环
  stop(): void {
    this.isRunning = false;
  }

  // 游戏主循环
  private gameLoop(): void {
    if (!this.isRunning) return;

    const currentTime = Date.now();
    const deltaTime = currentTime - this.lastFrameTime;
    this.lastFrameTime = currentTime;
    this.frameCount++;

    // 每60帧打印一次日志
    if (this.frameCount % GameEngine.LOG_FRAME_INTERVAL === 0) {
      hilog.info(DOMAIN, TAG, 'Game loop running, deltaTime: %{public}d', deltaTime);
    }

    // 更新游戏状态
    this.update(deltaTime);

    // 渲染画面
    this.render();

    // 使用 setTimeout 请求下一帧（约60FPS）
    setTimeout(() => this.gameLoop(), 16);
  }

  // 更新游戏逻辑（每帧调用）
  private update(deltaTime: number): void {
    // 如果战斗结束，停止更新
    if (this.battleOver) {
      return;
    }

    // 更新AI
    if (this.aiController) {
      this.aiController.update(deltaTime);
    }

    // 更新角色位置
    this.player.update(deltaTime);
    this.enemy.update(deltaTime);

    // 屏幕边界碰撞（使用 screenWidth/screenHeight）
    CollisionDetector.clampToScreen(this.player, this.screenWidth, this.screenHeight);
    CollisionDetector.clampToScreen(this.enemy, this.screenWidth, this.screenHeight);

    // 检测角色间碰撞
    if (CollisionDetector.checkAABB(this.player, this.enemy)) {
      // 简单的碰撞响应：互相推开
      const overlap = (this.player.width + this.enemy.width) / 2 -
                     Math.abs(this.player.x - this.enemy.x);

      if (this.player.x < this.enemy.x) {
        this.player.x -= overlap / 2;
        this.enemy.x += overlap / 2;
      } else {
        this.player.x += overlap / 2;
        this.enemy.x -= overlap / 2;
      }

      // 碰撞响应后再次检查边界约束
      CollisionDetector.clampToScreen(this.player, this.screenWidth, this.screenHeight);
      CollisionDetector.clampToScreen(this.enemy, this.screenWidth, this.screenHeight);
    }

    // 处理攻击判定
    BattleSystem.handleAttack(this.player, this.enemy);
    const playerHitEnemy = BattleSystem.handleAttack(this.player, this.enemy);
    const enemyHitPlayer = BattleSystem.handleAttack(this.enemy, this.player);

    // 更新连击计数
    if (playerHitEnemy) {
      this.playerCombo++;
      this.enemyCombo = 0; // 敌人被击中，重置敌人连击
      this.comboTimer = GameEngine.COMBO_TIMEOUT;
      this.screenShake = 5; // 屏幕震动
      this.hitStop = 50; // 顿帧效果
    }
    if (enemyHitPlayer) {
      this.enemyCombo++;
      this.playerCombo = 0; // 玩家被击中，重置玩家连击
      this.comboTimer = GameEngine.COMBO_TIMEOUT;
      this.screenShake = 5;
      this.hitStop = 50;
    }

    // 连击计时器
    this.comboTimer -= deltaTime;
    if (this.comboTimer <= 0) {
      this.playerCombo = 0;
      this.enemyCombo = 0;
    }

    // 更新特效
    if (this.screenShake > 0) {
      this.screenShake -= deltaTime / 10;
    }
    if (this.hitStop > 0) {
      this.hitStop -= deltaTime;
    }

    // 更新倒计时（每1000ms更新一次）
    this.lastTimerUpdate += deltaTime;
    if (this.lastTimerUpdate >= GameEngine.TIMER_UPDATE_INTERVAL && !this.battleOver) {
      this.battleTimer -= Math.floor(this.lastTimerUpdate / 1000);
      this.lastTimerUpdate = this.lastTimerUpdate % 1000;
      
      // 时间到则停止战斗
      if (this.battleTimer <= 0) {
        this.battleTimer = 0;
        // 时间到根据血量判断胜负
        if (this.player.stats.currentHp > this.enemy.stats.currentHp) {
          this.winner = this.player;
          this.battleOver = true;
        } else if (this.enemy.stats.currentHp > this.player.stats.currentHp) {
          this.winner = this.enemy;
          this.battleOver = true;
        } else {
          this.battleOver = true; // 平局
        }
        hilog.info(DOMAIN, TAG, 'Time up! Battle over. Winner: %{public}s', this.winner?.name || 'Draw');
      }
    }

    // 检测战斗是否结束
    if (BattleSystem.isBattleOver(this.player, this.enemy)) {
      this.battleOver = true;
      this.winner = BattleSystem.getWinner(this.player, this.enemy);
      if (this.winner) {
        hilog.info(DOMAIN, TAG, 'Battle over! Winner: %{public}s', this.winner.name);
      } else {
        hilog.info(DOMAIN, TAG, 'Battle over! Draw!');
      }
    }

    // 更新UI
    if (this.uiUpdateCallback) {
      const isVictory = this.winner === this.player;
      const winnerName = this.winner ? this.winner.name : '平局';

      // 如果有顿帧效果，跳过几帧不更新UI
      if (this.hitStop <= 0) {
        this.uiUpdateCallback(
          this.player.stats.currentHp,
          this.player.stats.maxHp,
          this.enemy.stats.currentHp,
          this.enemy.stats.maxHp,
          this.battleOver,
          winnerName,
          isVictory,
          this.playerCombo,
          this.enemyCombo
        );
      }
    }
  }

  // 渲染画面（每帧调用）
  private render(): void {
    if (!this.canvas) return;

    // 使用屏幕尺寸渲染
    const width = this.screenWidth;
    const height = this.screenHeight;

    // 清空画布
    this.canvas.clearRect(0, 0, width, height);

    // 应用屏幕震动
    this.canvas.save();
    if (this.screenShake > 0) {
      const shakeX = (Math.random() - 0.5) * this.screenShake * 2;
      const shakeY = (Math.random() - 0.5) * this.screenShake * 2;
      this.canvas.translate(shakeX, shakeY);
    }

    // 绘制背景（简单的地面）
    this.canvas.fillStyle = '#2C3E50';
    this.canvas.fillRect(0, 0, width, height);

    // 绘制地面
    this.canvas.fillStyle = '#34495E';
    this.canvas.fillRect(0, 500, width, height - 500);

    // 渲染角色
    CharacterRenderer.render(this.canvas, this.player);
    CharacterRenderer.render(this.canvas, this.enemy);

    // 渲染连击数
    this.renderCombo(this.canvas);

    // 恢复画布（取消震动偏移）
    this.canvas.restore();
  }

  // 渲染连击数
  private renderCombo(ctx: CanvasRenderingContext2D): void {
    // 玩家连击（左上角）
    if (this.playerCombo > 1) {
      ctx.save();
      ctx.fillStyle = '#FFD700';
      ctx.font = 'bold 24px Arial';
      ctx.textAlign = 'left';
      ctx.fillText(`${this.playerCombo} HIT!`, 20, 100);
      ctx.restore();
    }

    // 敌人连击（右上角）
    if (this.enemyCombo > 1) {
      ctx.save();
      ctx.fillStyle = '#FF4444';
      ctx.font = 'bold 24px Arial';
      ctx.textAlign = 'right';
      ctx.fillText(`${this.enemyCombo} HIT!`, this.screenWidth - 20, 100);
      ctx.restore();
    }
  }

  // 提供输入控制接口
  handleKeyDown(key: string): void {
    // 技能快捷键: 1, 2, 3 (技能), 4 (必杀), V (模式切换)
    if (key === '1') {
      this.player.useSkill(0);
    } else if (key === '2') {
      this.player.useSkill(1);
    } else if (key === '3') {
      this.player.useSkill(2);
    } else if (key === '4') {
      this.player.useUltimate();
    } else if (key === 'v' || key === 'V') {
      this.player.switchMode();
    } else {
      this.inputController.onKeyDown(key);
    }
  }

  handleKeyUp(key: string): void {
    this.inputController.onKeyUp(key);
  }

  // 获取玩家角色（用于UI访问）
  getPlayer(): Character {
    return this.player;
  }

  // 设置UI更新回调
  setUIUpdateCallback(callback: (playerHp: number, playerMaxHp: number, enemyHp: number, enemyMaxHp: number, battleOver: boolean, winnerName: string, isVictory: boolean, playerCombo: number, enemyCombo: number) => void): void {
    this.uiUpdateCallback = callback;
  }

  // 获取倒计时（用于UI）
  getBattleTime(): number {
    return this.battleTimer;
  }

  // 获取敌人角色
  getEnemy(): Character {
    return this.enemy;
  }

  // 获取战斗是否结束
  isBattleOver(): boolean {
    return this.battleOver;
  }

  // 获取是否胜利
  isVictory(): boolean {
    return this.winner === this.player;
  }

  // 获取胜利者名称
  getWinnerName(): string {
    return this.winner ? this.winner.name : '';
  }

  // 获取玩家连击数
  getPlayerCombo(): number {
    return this.playerCombo;
  }

  // 获取敌人连击数
  getEnemyCombo(): number {
    return this.enemyCombo;
  }
}
