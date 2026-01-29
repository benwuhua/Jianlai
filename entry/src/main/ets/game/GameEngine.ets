import { hilog } from '@kit.PerformanceAnalysisKit';
import { Character } from '../models/Character';
import { CharacterRenderer } from '../components/CharacterRenderer';
import { InputController } from './InputController';
import { CollisionDetector } from '../utils/CollisionDetector';

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

  constructor(canvas: CanvasRenderingContext2D) {
    if (!canvas) {
      throw new Error('Canvas context cannot be null');
    }
    this.canvas = canvas;

    // 创建玩家角色
    this.player = new Character('player', '陈平安', 200, 500, '#4A90E2');

    // 创建敌人
    this.enemy = new Character('enemy', '敌人', 600, 500, '#E74C3C');

    // 创建输入控制器
    this.inputController = new InputController(this.player);

    hilog.info(DOMAIN, TAG, 'GameEngine initialized successfully');
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
    }

    // TODO: 在Task 5中添加BattleSystem攻击判定
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
    this.inputController.onKeyDown(key);
  }

  handleKeyUp(key: string): void {
    this.inputController.onKeyUp(key);
  }
}
