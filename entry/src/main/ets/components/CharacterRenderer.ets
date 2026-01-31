import { Character, CharacterState } from '../models/Character';

// Canvas 2D 上下文类型
interface Canvas2DContext {
  fillStyle: string | CanvasGradient | CanvasPattern;
  font: string;
  fillText: string, x: number, y: number, maxWidth?: number): void;
  fillRect(x: number, y: number, width: number, height: number): void;
  strokeStyle: string | CanvasGradient | CanvasPattern;
  lineWidth: number;
  strokeRect(x: number, y: number, width: number, height: number): void;
  beginPath(): void;
  closePath(): void;
  arc(x: number, y: number, radius: number, startAngle: number, endAngle: number): void;
  save(): void;
  restore(): void;
  clearRect(x: number, y: number, width: number, height: number): void;
}

export class CharacterRenderer {
  // 渲染角色
  static render(ctx: Canvas2DContext, character: Character): void {
    ctx.save();

    // 绘制技能特效（在角色后面）
    this.renderSkillEffect(ctx, character);

    // 绘制攻击特效
    this.renderAttackEffect(ctx, character);

    // 绘制角色身体（简单的矩形）
    let bodyColor = character.color;

    // 武夫模式：颜色变为深红色
    if (character.getCurrentMode() === 'alternate') {
      bodyColor = '#8B0000'; // 深红色
    }

    ctx.fillStyle = bodyColor;
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

    // 绘制模式标签（如果有）
    this.renderModeLabel(ctx, character);

    // 绘制血条
    this.renderHealthBar(ctx, character);

    // 绘制剑气槽
    this.renderKiBar(ctx, character);

    ctx.restore();
  }

  // 绘制技能特效
  private static renderSkillEffect(ctx: Canvas2DContext, character: Character): void {
    if (character.state === CharacterState.CASTING_SKILL) {
      const skillManager = character.getSkillManager();
      if (skillManager && skillManager.getCurrentKi() >= 90) {
        // 必杀技特效：金色光圈
        ctx.strokeStyle = '#FFD700';
        ctx.lineWidth = 5;
        ctx.beginPath();
        ctx.arc(character.x, character.y - character.height / 2, 80, 0, 2 * Math.PI);
        ctx.stroke();

        // 金色填充
        ctx.fillStyle = 'rgba(255, 215, 0, 0.2)';
        ctx.fill();
      } else {
        // 普通技能特效：蓝色光圈
        ctx.strokeStyle = '#4A90E2';
        ctx.lineWidth = 3;
        ctx.beginPath();
        ctx.arc(character.x, character.y - character.height / 2, 60, 0, 2 * Math.PI);
        ctx.stroke();

        // 蓝色填充
        ctx.fillStyle = 'rgba(74, 144, 226, 0.2)';
        ctx.fill();
      }
    }

    // 模式切换特效
    if (character.state === CharacterState.MODE_SWITCHING) {
      ctx.strokeStyle = '#FF4500';
      ctx.lineWidth = 5;
      ctx.beginPath();
      ctx.arc(character.x, character.y - character.height / 2, 100, 0, 2 * Math.PI);
      ctx.stroke();

      // 橙色填充
      ctx.fillStyle = 'rgba(255, 69, 0, 0.3)';
      ctx.fill();
    }
  }

  // 绘制攻击特效
  private static renderAttackEffect(ctx: Canvas2DContext, character: Character): void {
    if (character.isAttacking()) {
      const attackRange = 120;
      const direction = character.facing;

      // 攻击范围半圆
      ctx.fillStyle = 'rgba(255, 0, 0, 0.3)';
      ctx.beginPath();

      if (direction > 0) {
        // 向右攻击
        ctx.arc(character.x, character.y - character.height / 2, attackRange, -Math.PI / 2, Math.PI / 2);
      } else {
        // 向左攻击
        ctx.arc(character.x, character.y - character.height / 2, attackRange, Math.PI / 2, -Math.PI / 2);
      }

      ctx.fill();
    }
  }

  // 绘制模式标签
  private static renderModeLabel(ctx: Canvas2DContext, character: Character): void {
    if (character.hasAlternateMode()) {
      const mode = character.getCurrentMode();
      const modeText = mode === 'alternate' ? '武夫' : '剑修';

      ctx.fillStyle = mode === 'alternate' ? '#FF4500' : '#4A90E2';
      ctx.font = '12px Arial';
      ctx.textAlign = 'center';
      ctx.fillText(modeText, character.x, character.y - character.height - 55);
    }
  }

  // 绘制血条
  private static renderHealthBar(ctx: Canvas2DContext, character: Character): void {
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
    const hpColor = hpPercent > 0.3 ? '#FF0000' : '#FF6600';
    ctx.fillStyle = hpColor;
    ctx.fillRect(
      character.x - hpBarWidth / 2,
      character.y - character.height - 30,
      hpBarWidth * hpPercent,
      hpBarHeight
    );
  }

  // 绘制剑气槽
  private static renderKiBar(ctx: Canvas2DContext, character: Character): void {
    const kiBarWidth = 60;
    const kiBarHeight = 5;
    const kiPercent = character.getKiPercent();

    // 剑气槽背景
    ctx.fillStyle = '#333333';
    ctx.fillRect(
      character.x - kiBarWidth / 2,
      character.y - character.height - 20,
      kiBarWidth,
      kiBarHeight
    );

    // 当前剑气（金色）
    ctx.fillStyle = '#FFD700';
    ctx.fillRect(
      character.x - kiBarWidth / 2,
      character.y - character.height - 20,
      kiBarWidth * kiPercent,
      kiBarHeight
    );
  }
}
