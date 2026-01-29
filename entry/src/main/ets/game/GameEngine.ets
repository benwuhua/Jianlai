import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'GameEngine';

export class GameEngine {
  private isRunning: boolean = false;
  private lastFrameTime: number = 0;
  private canvas: CanvasRenderingContext2D | null = null;

  constructor(canvas: CanvasRenderingContext2D) {
    this.canvas = canvas;
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

    // 每60帧打印一次日志
    if (currentTime % 1000 < 20) {
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
    // TODO: 实现更新逻辑
  }

  // 渲染画面（每帧调用）
  private render(): void {
    if (!this.canvas) return;

    // 清空画布
    this.canvas.clearRect(0, 0, this.canvas.width, this.canvas.height);

    // TODO: 渲染游戏对象
  }
}
