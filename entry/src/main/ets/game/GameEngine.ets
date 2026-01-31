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

export class GameEngine {
  // 常量定义
  private static readonly LOG_FRAME_INTERVAL = 60; // 每60帧打印一次日志

  private isRunning: boolean = false;
  private lastFrameTime: number = 0;
  private canvas: CanvasRenderingContext2D | null = null;
  private frameCount: number = 0; // 帧计数器

  // 游戏对象
  private player: Character;
  private enemy: Character;
  private inputController: InputController;
  private aiController: AIController | null = null;
  private difficulty: AIDifficulty = 'normal';
  private battleOver: boolean = false;
  private winner: Character | null = null;
  private uiUpdateCallback?: (playerHp: number, playerMaxHp: number, enemyHp: number, enemyMaxHp: number, battleOver: boolean, winnerName: string, isVictory: boolean) => void;

  constructor(canvas: CanvasRenderingContext2D, difficulty: AIDifficulty = 'normal', playerCharacterId?: string) {
    if (!canvas) {
      throw new Error('Canvas context cannot be null');
    }
    this.canvas = canvas;
    this.difficulty = difficulty;

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

    // 请求下一帧
    requestAnimationFrame(() => this.gameLoop());
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

    // 屏幕边界碰撞
    if (this.canvas) {
      CollisionDetector.clampToScreen(this.player, this.canvas.width, this.canvas.height);
      CollisionDetector.clampToScreen(this.enemy, this.canvas.width, this.canvas.height);
    }

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

      // 碰撞响应后再次检查边界约束，防止角色被推到屏幕外
      if (this.canvas) {
        CollisionDetector.clampToScreen(this.player, this.canvas.width, this.canvas.height);
        CollisionDetector.clampToScreen(this.enemy, this.canvas.width, this.canvas.height);
      }
    }

    // 处理攻击判定
    BattleSystem.handleAttack(this.player, this.enemy);
    BattleSystem.handleAttack(this.enemy, this.player);

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

      this.uiUpdateCallback(
        this.player.stats.currentHp,
        this.player.stats.maxHp,
        this.enemy.stats.currentHp,
        this.enemy.stats.maxHp,
        this.battleOver,
        winnerName,
        isVictory
      );
    }
  }

  // 渲染画面（每帧调用）
  private render(): void {
    if (!this.canvas) return;

    // 清空画布
    this.canvas.clearRect(0, 0, this.canvas.width, this.canvas.height);

    // 绘制背景（简单的地面）
    this.canvas.fillStyle = '#2C3E50';
    this.canvas.fillRect(0, 0, this.canvas.width, this.canvas.height);

    // 绘制地面
    this.canvas.fillStyle = '#34495E';
    this.canvas.fillRect(0, 500, this.canvas.width, this.canvas.height - 500);

    // 渲染角色
    CharacterRenderer.render(this.canvas, this.player);
    CharacterRenderer.render(this.canvas, this.enemy);
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
  setUIUpdateCallback(callback: (playerHp: number, playerMaxHp: number, enemyHp: number, enemyMaxHp: number) => void): void {
    this.uiUpdateCallback = callback;
  }
}
