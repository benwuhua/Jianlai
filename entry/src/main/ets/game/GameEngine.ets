import { hilog } from '@kit.PerformanceAnalysisKit';
import { Character } from '../models/Character';
import { CharacterRenderer } from '../components/CharacterRenderer';

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

  constructor(canvas: CanvasRenderingContext2D) {
    if (!canvas) {
      throw new Error('Canvas context cannot be null');
    }
    this.canvas = canvas;

    // 创建玩家角色
    this.player = new Character('player', '陈平安', 200, 500, '#4A90E2');

    // 创建敌人
    this.enemy = new Character('enemy', '敌人', 600, 500, '#E74C3C');

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
    // 更新角色
    this.player.update(deltaTime);
    this.enemy.update(deltaTime);
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
}
