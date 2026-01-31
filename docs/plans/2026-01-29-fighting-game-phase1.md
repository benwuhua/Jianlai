# 《剑来》格斗游戏实施计划 - 第一阶段：核心战斗

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**目标：** 搭建基础游戏框架，实现单个角色的移动和攻击，以及简单的碰撞检测和基础UI

**架构：** 使用Canvas 2D进行游戏渲染，组件化设计，分离游戏引擎、渲染器和UI层。采用状态驱动的方式管理角色状态和游戏循环。

**技术栈：** HarmonyOS ArkTS, Canvas 2D, @ohos.multimedia.audio (音效)

---

## Task 1: 创建游戏主引擎框架

**文件：**
- 创建: `entry/src/main/ets/game/GameEngine.ets`
- 修改: `entry/src/main/ets/pages/Index.ets`

**Step 1: 创建游戏引擎基础类**

创建 `entry/src/main/ets/game/GameEngine.ets`:

```typescript
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
```

**Step 2: 在Index页面中集成Canvas**

修改 `entry/src/main/ets/pages/Index.ets`:

```typescript
import { GameEngine } from '../game/GameEngine';

@Entry
@Component
struct Index {
  @State private canvasContext: CanvasRenderingContext2D | null = null;
  private gameEngine: GameEngine | null = null;

  build() {
    RelativeContainer() {
      Canvas(this.canvasContext)
        .id('GameCanvas')
        .width('100%')
        .height('100%')
        .onReady(() => {
          // Canvas准备好后，创建游戏引擎
          if (this.canvasContext) {
            this.gameEngine = new GameEngine(this.canvasContext);
            this.gameEngine.start();
          }
        })
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          right: { anchor: '__container__', align: HorizontalAlign.End }
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }

  // 初始化Canvas上下文
  aboutToAppear() {
    this.canvasContext = new CanvasRenderingContext2D();
  }

  // 清理资源
  aboutToDisappear() {
    if (this.gameEngine) {
      this.gameEngine.stop();
    }
  }
}
```

**Step 3: 在DevEco Studio中预览**

运行: 在DevEco Studio中打开项目，点击Preview按钮
预期: 显示黑色全屏Canvas，游戏循环运行（可用日志验证）

**Step 4: 添加调试日志验证循环**

修改 `GameEngine.ets` 的 `gameLoop` 方法:

```typescript
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'GameEngine';

private gameLoop(): void {
  if (!this.isRunning) return;

  const currentTime = Date.now();
  const deltaTime = currentTime - this.lastFrameTime;
  this.lastFrameTime = currentTime;

  // 每60帧打印一次日志
  if (currentTime % 1000 < 20) {
    hilog.info(DOMAIN, TAG, 'Game loop running, deltaTime: %{public}d', deltaTime);
  }

  this.update(deltaTime);
  this.render();

  requestAnimationFrame(() => this.gameLoop());
}
```

**Step 5: 提交**

```bash
git add entry/src/main/ets/game/GameEngine.ets entry/src/main/ets/pages/Index.ets
git commit -m "feat: create basic game engine with canvas render loop"
```

---

## Task 2: 创建角色数据模型和基础渲染

**文件：**
- 创建: `entry/src/main/ets/models/Character.ets`
- 创建: `entry/src/main/ets/components/CharacterRenderer.ets`
- 修改: `entry/src/main/ets/game/GameEngine.ets`

**Step 1: 定义角色数据模型**

创建 `entry/src/main/ets/models/Character.ets`:

```typescript
// 角色状态枚举
export enum CharacterState {
  IDLE = 'idle',
  WALKING = 'walking',
  ATTACKING = 'attacking',
  HURT = 'hurt',
  DEAD = 'dead'
}

// 角色属性接口
export interface CharacterStats {
  maxHp: number;
  currentHp: number;
  attack: number;
  defense: number;
  speed: number;
}

// 角色类
export class Character {
  id: string;
  name: string;
  state: CharacterState;
  stats: CharacterStats;

  // 位置和速度
  x: number;
  y: number;
  velocityX: number;
  velocityY: number;

  // 渲染属性
  width: number = 100;
  height: number = 150;
  color: string;

  // 面向方向 (1: 右, -1: 左)
  facing: number = 1;

  constructor(id: string, name: string, x: number, y: number, color: string) {
    this.id = id;
    this.name = name;
    this.x = x;
    this.y = y;
    this.color = color;
    this.state = CharacterState.IDLE;
    this.velocityX = 0;
    this.velocityY = 0;

    // 默认属性
    this.stats = {
      maxHp: 1000,
      currentHp: 1000,
      attack: 100,
      defense: 50,
      speed: 5
    };
  }

  // 更新位置
  update(deltaTime: number): void {
    this.x += this.velocityX;
    this.y += this.velocityY;

    // 简单的地面碰撞
    if (this.y > 500) {
      this.y = 500;
      this.velocityY = 0;
    }
  }

  // 向左移动
  moveLeft(): void {
    this.velocityX = -this.stats.speed;
    this.facing = -1;
    this.state = CharacterState.WALKING;
  }

  // 向右移动
  moveRight(): void {
    this.velocityX = this.stats.speed;
    this.facing = 1;
    this.state = CharacterState.WALKING;
  }

  // 停止移动
  stopMoving(): void {
    this.velocityX = 0;
    if (this.state === CharacterState.WALKING) {
      this.state = CharacterState.IDLE;
    }
  }

  // 跳跃
  jump(): void {
    if (this.y === 500) { // 在地面
      this.velocityY = -15;
    }
  }

  // 攻击
  attack(): void {
    this.state = CharacterState.ATTACKING;
    // TODO: 实现攻击逻辑
  }
}
```

**Step 2: 创建角色渲染器**

创建 `entry/src/main/ets/components/CharacterRenderer.ets`:

```typescript
import { Character } from '../models/Character';
import { CanvasRenderingContext2D } from '@kit.ArkGraphics2D';

export class CharacterRenderer {
  // 渲染角色
  static render(ctx: CanvasRenderingContext2D, character: Character): void {
    ctx.save();

    // 绘制角色身体（简单的矩形）
    ctx.fillStyle = character.color;
    ctx.fillRect(
      character.x - character.width / 2,
      character.y - character.height,
      character.width,
      character.height
    );

    // 绘制角色朝向指示器
    ctx.fillStyle = '#FFFFFF';
    const eyeX = character.x + (character.facing * 20);
    ctx.beginPath();
    ctx.arc(eyeX, character.y - character.height + 30, 8, 0, 2 * Math.PI);
    ctx.fill();

    // 绘制角色名称
    ctx.fillStyle = '#FFFFFF';
    ctx.font = '16px Arial';
    ctx.textAlign = 'center';
    ctx.fillText(character.name, character.x, character.y - character.height - 10);

    // 绘制血条
    const hpBarWidth = 80;
    const hpBarHeight = 8;
    const hpPercent = character.stats.currentHp / character.stats.maxHp;

    // 血条背景
    ctx.fillStyle = '#333333';
    ctx.fillRect(
      character.x - hpBarWidth / 2,
      character.y - character.height - 30,
      hpBarWidth,
      hpBarHeight
    );

    // 当前血量
    ctx.fillStyle = '#FF0000';
    ctx.fillRect(
      character.x - hpBarWidth / 2,
      character.y - character.height - 30,
      hpBarWidth * hpPercent,
      hpBarHeight
    );

    ctx.restore();
  }
}
```

**Step 3: 在游戏引擎中集成角色**

修改 `entry/src/main/ets/game/GameEngine.ets`:

```typescript
import { Character } from '../models/Character';
import { CharacterRenderer } from '../components/CharacterRenderer';

export class GameEngine {
  // ... 现有代码 ...

  // 游戏对象
  private player: Character;
  private enemy: Character;

  constructor(canvas: CanvasRenderingContext2D) {
    this.canvas = canvas;

    // 创建玩家角色
    this.player = new Character('player', '陈平安', 200, 500, '#4A90E2');

    // 创建敌人
    this.enemy = new Character('enemy', '敌人', 600, 500, '#E74C3C');
  }

  private update(deltaTime: number): void {
    // 更新角色
    this.player.update(deltaTime);
    this.enemy.update(deltaTime);
  }

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
```

**Step 4: 验证角色渲染**

在DevEco Studio中预览
预期: 看到两个矩形角色在屏幕上，一个蓝色（陈平安），一个红色（敌人），都有血条和名字

**Step 5: 提交**

```bash
git add entry/src/main/ets/models/Character.ets entry/src/main/ets/components/CharacterRenderer.ets entry/src/main/ets/game/GameEngine.ets
git commit -m "feat: add character model and renderer"
```

---

## Task 3: 实现角色输入控制

**文件：**
- 创建: `entry/src/main/ets/game/InputController.ets`
- 修改: `entry/src/main/ets/game/GameEngine.ets`
- 修改: `entry/src/main/ets/pages/Index.ets`

**Step 1: 创建输入控制器**

创建 `entry/src/main/ets/game/InputController.ets`:

```typescript
import { Character } from '../models/Character';

export class InputController {
  private character: Character;
  private keys: Map<string, boolean> = new Map();

  constructor(character: Character) {
    this.character = character;
  }

  // 按下按键
  onKeyDown(key: string): void {
    this.keys.set(key, true);
    this.handleInput();
  }

  // 释放按键
  onKeyUp(key: string): void {
    this.keys.delete(key);
    this.handleInput();
  }

  // 处理输入
  private handleInput(): void {
    // 移动控制
    if (this.keys.has('ArrowLeft') || this.keys.has('a')) {
      this.character.moveLeft();
    } else if (this.keys.has('ArrowRight') || this.keys.has('d')) {
      this.character.moveRight();
    } else {
      this.character.stopMoving();
    }

    // 跳跃控制
    if (this.keys.has('ArrowUp') || this.keys.has('w') || this.keys.has(' ')) {
      this.character.jump();
    }

    // 攻击控制
    if (this.keys.has('j') || this.keys.has('z')) {
      this.character.attack();
    }
  }
}
```

**Step 2: 在游戏引擎中集成输入控制**

修改 `entry/src/main/ets/game/GameEngine.ets`:

```typescript
import { InputController } from '../game/InputController';

export class GameEngine {
  // ... 现有代码 ...
  private inputController: InputController;

  constructor(canvas: CanvasRenderingContext2D) {
    this.canvas = canvas;

    this.player = new Character('player', '陈平安', 200, 500, '#4A90E2');
    this.enemy = new Character('enemy', '敌人', 600, 500, '#E74C3C');

    // 创建输入控制器
    this.inputController = new InputController(this.player);
  }

  // 提供输入控制接口
  handleKeyDown(key: string): void {
    this.inputController.onKeyDown(key);
  }

  handleKeyUp(key: string): void {
    this.inputController.onKeyUp(key);
  }
}
```

**Step 3: 在Index页面中添加键盘事件监听**

修改 `entry/src/main/ets/pages/Index.ets`:

```typescript
@Entry
@Component
struct Index {
  @State private canvasContext: CanvasRenderingContext2D | null = null;
  private gameEngine: GameEngine | null = null;

  build() {
    RelativeContainer() {
      Canvas(this.canvasContext)
        .id('GameCanvas')
        .width('100%')
        .height('100%')
        .onReady(() => {
          if (this.canvasContext) {
            this.gameEngine = new GameEngine(this.canvasContext);
            this.gameEngine.start();
          }
        })
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          right: { anchor: '__container__', align: HorizontalAlign.End }
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
    .onKeyEvent((event) => {
      // 处理键盘事件
      if (this.gameEngine) {
        if (event.type === KeyType.Down) {
          this.gameEngine.handleKeyDown(event.keyCode);
        } else if (event.type === KeyType.Up) {
          this.gameEngine.handleKeyUp(event.keyCode);
        }
      }
    })
  }

  // ... 其他代码保持不变 ...
}
```

**Step 4: 测试角色控制**

在DevEco Studio中预览并测试:
预期:
- 按方向键左/右或A/D键，角色左右移动
- 按方向键上或W键或空格键，角色跳跃
- 角色朝向随移动方向改变

**Step 5: 提交**

```bash
git add entry/src/main/ets/game/InputController.ets entry/src/main/ets/game/GameEngine.ets entry/src/main/ets/pages/Index.ets
git commit -m "feat: add keyboard input control for character movement"
```

---

## Task 4: 实现简单碰撞检测系统

**文件：**
- 创建: `entry/src/main/ets/utils/CollisionDetector.ets`
- 修改: `entry/src/main/ets/game/GameEngine.ets`

**Step 1: 创建碰撞检测工具类**

创建 `entry/src/main/ets/utils/CollisionDetector.ets`:

```typescript
import { Character } from '../models/Character';

export class CollisionDetector {
  // AABB碰撞检测（矩形碰撞）
  static checkAABB(char1: Character, char2: Character): boolean {
    const char1Left = char1.x - char1.width / 2;
    const char1Right = char1.x + char1.width / 2;
    const char1Top = char1.y - char1.height;
    const char1Bottom = char1.y;

    const char2Left = char2.x - char2.width / 2;
    const char2Right = char2.x + char2.width / 2;
    const char2Top = char2.y - char2.height;
    const char2Bottom = char2.y;

    return char1Left < char2Right &&
           char1Right > char2Left &&
           char1Top < char2Bottom &&
           char1Bottom > char2Top;
  }

  // 计算两个角色之间的距离
  static getDistance(char1: Character, char2: Character): number {
    const dx = char2.x - char1.x;
    const dy = char2.y - char1.y;
    return Math.sqrt(dx * dx + dy * dy);
  }

  // 检测攻击范围碰撞
  static checkAttackRange(attacker: Character, target: Character, range: number = 100): boolean {
    const distance = this.getDistance(attacker, target);
    return distance <= range;
  }

  // 将角色限制在屏幕边界内
  static clampToScreen(character: Character, screenWidth: number, screenHeight: number): void {
    const halfWidth = character.width / 2;

    if (character.x - halfWidth < 0) {
      character.x = halfWidth;
    }
    if (character.x + halfWidth > screenWidth) {
      character.x = screenWidth - halfWidth;
    }
  }
}
```

**Step 2: 在游戏引擎中应用碰撞检测**

修改 `entry/src/main/ets/game/GameEngine.ets`:

```typescript
import { CollisionDetector } from '../utils/CollisionDetector';

export class GameEngine {
  // ... 现有代码 ...

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
  }
}
```

**Step 3: 测试碰撞检测**

在DevEco Studio中预览并测试:
预期:
- 角色不能移出屏幕边界
- 两个角色碰撞时会被推开，不会重叠

**Step 4: 提交**

```bash
git add entry/src/main/ets/utils/CollisionDetector.ets entry/src/main/ets/game/GameEngine.ets
git commit -m "feat: implement AABB collision detection and screen boundaries"
```

---

## Task 5: 实现攻击和伤害系统

**文件：**
- 修改: `entry/src/main/ets/models/Character.ets`
- 修改: `entry/src/main/ets/game/GameEngine.ets`
- 创建: `entry/src/main/ets/game/BattleSystem.ets`

**Step 1: 扩展角色模型，添加攻击状态管理**

修改 `entry/src/main/ets/models/Character.ets`:

```typescript
export class Character {
  // ... 现有属性 ...

  // 攻击相关
  private attackCooldown: number = 0;
  private attackDuration: number = 0;
  private readonly ATTACK_COOLDOWN_TIME = 500; // ms
  private readonly ATTACK_DURATION = 300; // ms

  // 更新方法中添加冷却处理
  update(deltaTime: number): void {
    this.x += this.velocityX;
    this.y += this.velocityY;

    // 更新攻击冷却
    if (this.attackCooldown > 0) {
      this.attackCooldown -= deltaTime;
    }

    // 更新攻击持续时间
    if (this.attackDuration > 0) {
      this.attackDuration -= deltaTime;
      if (this.attackDuration <= 0) {
        this.state = CharacterState.IDLE;
      }
    }

    // 地面碰撞
    if (this.y > 500) {
      this.y = 500;
      this.velocityY = 0;
    }
  }

  // 重写攻击方法
  attack(): void {
    // 检查是否在冷却中
    if (this.attackCooldown > 0 || this.attackDuration > 0) {
      return;
    }

    this.state = CharacterState.ATTACKING;
    this.attackDuration = this.ATTACK_DURATION;
    this.attackCooldown = this.ATTACK_COOLDOWN_TIME;
  }

  // 受到伤害
  takeDamage(damage: number): void {
    const actualDamage = Math.max(1, damage - this.stats.defense);
    this.stats.currentHp = Math.max(0, this.stats.currentHp - actualDamage);
    this.state = CharacterState.HURT;

    // 受击硬直100ms
    setTimeout(() => {
      if (this.stats.currentHp > 0) {
        this.state = CharacterState.IDLE;
      } else {
        this.state = CharacterState.DEAD;
      }
    }, 100);
  }

  // 检查是否死亡
  isDead(): boolean {
    return this.stats.currentHp <= 0;
  }

  // 检查是否正在攻击
  isAttacking(): boolean {
    return this.attackDuration > 0;
  }
}
```

**Step 2: 创建战斗系统**

创建 `entry/src/main/ets/game/BattleSystem.ets`:

```typescript
import { Character } from '../models/Character';
import { CollisionDetector } from '../utils/CollisionDetector';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'BattleSystem';

export class BattleSystem {
  // 处理攻击判定
  static handleAttack(attacker: Character, target: Character): void {
    // 检查攻击者是否正在攻击
    if (!attacker.isAttacking()) {
      return;
    }

    // 检查是否在攻击范围内
    if (!CollisionDetector.checkAttackRange(attacker, target, 120)) {
      return;
    }

    // 检查朝向是否正确
    const dx = target.x - attacker.x;
    const isFacingTarget = (attacker.facing === 1 && dx > 0) ||
                          (attacker.facing === -1 && dx < 0);

    if (!isFacingTarget) {
      return;
    }

    // 造成伤害（避免重复判定：只在攻击开始时造成伤害）
    if (attacker['attackDuration'] > 200) {
      target.takeDamage(attacker.stats.attack);
      hilog.info(DOMAIN, TAG, '%{public}s hit %{public}s for %{public}d damage',
        attacker.name, target.name, attacker.stats.attack);
    }
  }

  // 检测战斗是否结束
  static isBattleOver(player: Character, enemy: Character): boolean {
    return player.isDead() || enemy.isDead();
  }

  // 获取胜利者
  static getWinner(player: Character, enemy: Character): Character | null {
    if (player.isDead() && enemy.isDead()) {
      return null; // 平局
    }
    if (player.isDead()) {
      return enemy;
    }
    if (enemy.isDead()) {
      return player;
    }
    return null; // 战斗未结束
  }
}
```

**Step 3: 在游戏引擎中集成战斗系统**

修改 `entry/src/main/ets/game/GameEngine.ets`:

```typescript
import { BattleSystem } from '../game/BattleSystem';

export class GameEngine {
  // ... 现有代码 ...
  private battleOver: boolean = false;

  private update(deltaTime: number): void {
    // 如果战斗结束，停止更新
    if (this.battleOver) {
      return;
    }

    // 更新角色位置
    this.player.update(deltaTime);
    this.enemy.update(deltaTime);

    // 屏幕边界碰撞
    if (this.canvas) {
      CollisionDetector.clampToScreen(this.player, this.canvas.width, this.canvas.height);
      CollisionDetector.clampToScreen(this.enemy, this.canvas.width, this.canvas.height);
    }

    // 角色间碰撞
    if (CollisionDetector.checkAABB(this.player, this.enemy)) {
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

    // 处理攻击判定
    BattleSystem.handleAttack(this.player, this.enemy);
    BattleSystem.handleAttack(this.enemy, this.player);

    // 检测战斗是否结束
    if (BattleSystem.isBattleOver(this.player, this.enemy)) {
      this.battleOver = true;
      const winner = BattleSystem.getWinner(this.player, this.enemy);
      if (winner) {
        hilog.info(DOMAIN, TAG, 'Battle over! Winner: %{public}s', winner.name);
      } else {
        hilog.info(DOMAIN, TAG, 'Battle over! Draw!');
      }
    }
  }
}
```

**Step 4: 测试攻击系统**

在DevEco Studio中预览并测试:
预期:
- 按J或Z键攻击，靠近敌人并朝向敌人时造成伤害
- 被攻击者血量减少
- 血量归零时角色死亡，战斗结束

**Step 5: 提交**

```bash
git add entry/src/main/ets/models/Character.ets entry/src/main/ets/game/BattleSystem.ets entry/src/main/ets/game/GameEngine.ets
git commit -m "feat: implement attack and damage system"
```

---

## Task 6: 创建基础UI组件（血条和攻击按钮）

**文件：**
- 创建: `entry/src/main/ets/components/HealthBar.ets`
- 创建: `entry/src/main/ets/components/SkillButton.ets`
- 修改: `entry/src/main/ets/pages/Index.ets`

**Step 1: 创建血条组件**

创建 `entry/src/main/ets/components/HealthBar.ets`:

```typescript
@Component
export struct HealthBar {
  @Prop currentHp: number;
  @Prop maxHp: number;
  @Prop name: string;
  @Prop position: 'top' | 'bottom' = 'top';

  build() {
    Column() {
      Text(this.name)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .margin({ bottom: 4 })

      Stack() {
        // 血条背景
        Rect()
          .width(200)
          .height(20)
          .fill('#333333')

        // 当前血量
        Rect()
          .width(200 * (this.currentHp / this.maxHp))
          .height(20)
          .fill(this.currentHp > this.maxHp * 0.3 ? '#FF0000' : '#FF6600')

        // 血量文字
        Text(`${this.currentHp}/${this.maxHp}`)
          .fontSize(12)
          .fontColor('#FFFFFF')
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 10, bottom: 10 })
    .alignItems(this.position === 'top' ? HorizontalAlign.Start : HorizontalAlign.End)
  }
}
```

**Step 2: 创建技能按钮组件**

创建 `entry/src/main/ets/components/SkillButton.ets`:

```typescript
@Component
export struct SkillButton {
  @Prop label: string;
  @Prop onAction: () => void = () => {};
  @State isPressed: boolean = false;

  build() {
    Stack() {
      Circle()
        .width(70)
        .height(70)
        .fill(this.isPressed ? '#4A90E2' : '#2C3E50')
        .stroke('#FFFFFF')
        .strokeWidth(2)

      Text(this.label)
        .fontSize(24)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
    }
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true;
        this.onAction();
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false;
      }
    })
  }
}
```

**Step 3: 在Index页面中集成UI组件**

修改 `entry/src/main/ets/pages/Index.ets`:

```typescript
import { HealthBar } from '../components/HealthBar';
import { SkillButton } from '../components/SkillButton';

@Entry
@Component
struct Index {
  @State private canvasContext: CanvasRenderingContext2D | null = null;
  private gameEngine: GameEngine | null = null;

  // 暴露角色状态给UI
  @State playerHp: number = 1000;
  @State playerMaxHp: number = 1000;
  @State enemyHp: number = 1000;
  @State enemyMaxHp: number = 1000;

  build() {
    Stack() {
      // 游戏Canvas层
      RelativeContainer() {
        Canvas(this.canvasContext)
          .id('GameCanvas')
          .width('100%')
          .height('100%')
          .onReady(() => {
            if (this.canvasContext) {
              this.gameEngine = new GameEngine(this.canvasContext);
              // 设置回调更新UI
              this.gameEngine.setUIUpdateCallback(this.updateUIFromGame.bind(this));
              this.gameEngine.start();
            }
          })
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            right: { anchor: '__container__', align: HorizontalAlign.End }
          })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#000000')

      // UI层
      Column() {
        // 顶部血条
        Row() {
          HealthBar({
            name: '陈平安',
            currentHp: this.playerHp,
            maxHp: this.playerMaxHp,
            position: 'top'
          })

          Blank()

          HealthBar({
            name: '敌人',
            currentHp: this.enemyHp,
            maxHp: this.enemyMaxHp,
            position: 'top'
          })
        }
        .width('100%')

        Blank()

        // 底部控制按钮
        Row() {
          SkillButton({
            label: '攻',
            onAction: () => {
              if (this.gameEngine) {
                this.gameEngine.handleKeyDown('j');
              }
            }
          })
          .margin({ right: 20 })

          SkillButton({
            label: '跳',
            onAction: () => {
              if (this.gameEngine) {
                this.gameEngine.handleKeyDown('w');
              }
            }
          })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .padding({ bottom: 30 })
      }
      .width('100%')
      .height('100%')
    }
  }

  // 从游戏引擎更新UI
  private updateUIFromGame(playerHp: number, playerMaxHp: number, enemyHp: number, enemyMaxHp: number): void {
    this.playerHp = playerHp;
    this.playerMaxHp = playerMaxHp;
    this.enemyHp = enemyHp;
    this.enemyMaxHp = enemyMaxHp;
  }

  // ... 其他方法保持不变 ...
}
```

**Step 4: 在游戏引擎中添加UI更新回调**

修改 `entry/src/main/ets/game/GameEngine.ets`:

```typescript
export class GameEngine {
  // ... 现有代码 ...
  private uiUpdateCallback?: (playerHp: number, playerMaxHp: number, enemyHp: number, enemyMaxHp: number) => void;

  // 设置UI更新回调
  setUIUpdateCallback(callback: (playerHp: number, playerMaxHp: number, enemyHp: number, enemyMaxHp: number) => void): void {
    this.uiUpdateCallback = callback;
  }

  // 在update方法中调用UI更新
  private update(deltaTime: number): void {
    // ... 现有更新逻辑 ...

    // 更新UI
    if (this.uiUpdateCallback) {
      this.uiUpdateCallback(
        this.player.stats.currentHp,
        this.player.stats.maxHp,
        this.enemy.stats.currentHp,
        this.enemy.stats.maxHp
      );
    }
  }
}
```

**Step 5: 测试UI组件**

在DevEco Studio中预览并测试:
预期:
- 顶部显示玩家和敌人的血条
- 血条随伤害实时更新
- 底部有攻击和跳跃按钮，点击可控制角色

**Step 6: 提交**

```bash
git add entry/src/main/ets/components/HealthBar.ets entry/src/main/ets/components/SkillButton.ets entry/src/main/ets/pages/Index.ets entry/src/main/ets/game/GameEngine.ets
git commit -m "feat: add UI components (health bar and skill buttons)"
```

---

## Task 7: 添加基础音效系统

**文件：**
- 创建: `entry/src/main/ets/utils/AudioManager.ets`
- 修改: `entry/src/main/ets/game/BattleSystem.ets`

**Step 1: 创建音效管理器**

创建 `entry/src/main/ets/utils/AudioManager.ets`:

```typescript
import { media } from '@kit.MediaKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'AudioManager';

export class AudioManager {
  private static instance: AudioManager;
  private audioRenderer: media.AVRecorder | null = null;

  private constructor() {}

  static getInstance(): AudioManager {
    if (!AudioManager.instance) {
      AudioManager.instance = new AudioManager();
    }
    return AudioManager.instance;
  }

  // 播放音效（简化版本，使用系统提示音）
  async playSound(soundType: 'attack' | 'hit' | 'jump'): Promise<void> {
    try {
      // TODO: 实际项目中应该播放资源文件中的音效
      // 这里使用日志代替，后续添加实际音效文件
      hilog.info(DOMAIN, TAG, 'Playing sound: %{public}s', soundType);

      // 实际实现示例（需要音频资源）:
      // const audioRenderer = await media.createAudioRenderer();
      // await audioRenderer.setSource(`resources/rawfile/sounds/${soundType}.mp3`);
      // await audioRenderer.start();
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to play sound: %{public}s', JSON.stringify(error));
    }
  }

  // 播放攻击音效
  playAttackSound(): void {
    this.playSound('attack');
  }

  // 播放受击音效
  playHitSound(): void {
    this.playSound('hit');
  }

  // 播放跳跃音效
  playJumpSound(): void {
    this.playSound('jump');
  }
}
```

**Step 2: 在战斗系统中集成音效**

修改 `entry/src/main/ets/game/BattleSystem.ets`:

```typescript
import { AudioManager } from '../utils/AudioManager';

export class BattleSystem {
  static handleAttack(attacker: Character, target: Character): void {
    if (!attacker.isAttacking()) {
      return;
    }

    if (!CollisionDetector.checkAttackRange(attacker, target, 120)) {
      return;
    }

    const dx = target.x - attacker.x;
    const isFacingTarget = (attacker.facing === 1 && dx > 0) ||
                          (attacker.facing === -1 && dx < 0);

    if (!isFacingTarget) {
      return;
    }

    // 造成伤害时播放音效
    if (attacker['attackDuration'] > 200) {
      target.takeDamage(attacker.stats.attack);
      AudioManager.getInstance().playHitSound();
      hilog.info(DOMAIN, TAG, '%{public}s hit %{public}s for %{public}d damage',
        attacker.name, target.name, attacker.stats.attack);
    }
  }
}
```

**Step 3: 在角色攻击时添加音效**

修改 `entry/src/main/ets/models/Character.ets`:

```typescript
import { AudioManager } from '../utils/AudioManager';

export class Character {
  // ... 现有代码 ...

  attack(): void {
    if (this.attackCooldown > 0 || this.attackDuration > 0) {
      return;
    }

    this.state = CharacterState.ATTACKING;
    this.attackDuration = this.ATTACK_DURATION;
    this.attackCooldown = this.ATTACK_COOLDOWN_TIME;

    // 播放攻击音效
    AudioManager.getInstance().playAttackSound();
  }

  jump(): void {
    if (this.y === 500) {
      this.velocityY = -15;
      // 播放跳跃音效
      AudioManager.getInstance().playJumpSound();
    }
  }
}
```

**Step 4: 测试音效**

在DevEco Studio中预览并测试:
预期:
- 攻击时在日志中看到 "Playing sound: attack"
- 击中敌人时看到 "Playing sound: hit"
- 跳跃时看到 "Playing sound: jump"

**Step 5: 提交**

```bash
git add entry/src/main/ets/utils/AudioManager.ets entry/src/main/ets/game/BattleSystem.ets entry/src/main/ets/models/Character.ets
git commit -m "feat: add basic audio system for sound effects"
```

---

## 完成标准

第一阶段完成后，游戏应该具备以下功能：

✅ 游戏主循环正常运行（60fps）
✅ 玩家可以使用键盘/触摸控制角色移动和跳跃
✅ 角色可以在屏幕中自由移动，不会超出边界
✅ 角色之间有碰撞检测，不会互相穿过
✅ 玩家可以攻击敌人，造成伤害
✅ 血条UI实时显示角色生命值
✅ 触摸按钮可以控制角色攻击和跳跃
✅ 攻击、受击、跳跃有音效提示
✅ 角色死亡时战斗结束

## 下一阶段预览

第二阶段将实现：
- 多角色选择系统
- 角色技能和连击系统
- AI对手逻辑
- 角色选择界面
- 更丰富的特效和动画
