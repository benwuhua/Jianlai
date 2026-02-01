import { Character, CharacterState } from '../models/Character';
import { resourceManager } from '@kit.ArkUI';

// 使用 ArkTS 标准 CanvasRenderingContext2D 类型
type Canvas2DContext = CanvasRenderingContext2D;

// 贴图缓存
const textureCache: Map<string, ImageBitmap> = new Map();

export class CharacterRenderer {
  // 预加载角色贴图
  static async preloadTextures(characterIds: string[]): Promise<void> {
    const context = getContext();
    const resourceManager = context.resourceManager;
    
    for (const id of characterIds) {
      try {
        const rawFile = await resourceManager.getRawFileContent(`characters/${id}.png`);
        const buffer = rawFile.buffer;
        const imageBitmap = await createImageBitmap(new Blob([buffer]));
        textureCache.set(id, imageBitmap);
      } catch (err) {
        console.error(`Failed to load texture for ${id}: ${err}`);
      }
    }
  }

  // 渲染角色
  static render(ctx: Canvas2DContext, character: Character): void {
    ctx.save();

    // 绘制技能特效（在角色后面）
    CharacterRenderer.renderSkillEffect(ctx, character);

    // 绘制攻击特效
    CharacterRenderer.renderAttackEffect(ctx, character);

    // 尝试加载并绘制贴图
    const texture = textureCache.get(character.id);
    if (texture) {
      // 绘制贴图
      const scale = character.height / texture.height;
      const drawWidth = texture.width * scale;
      const drawHeight = character.height;
      
      ctx.drawImage(
        texture,
        character.x - drawWidth / 2,
        character.y - drawHeight,
        drawWidth,
        drawHeight
      );
    } else {
      // 回退到颜色块绘制
      CharacterRenderer.renderFallbackCharacter(ctx, character);
    }

    // 绘制角色名称
    ctx.fillStyle = '#FFFFFF';
    ctx.font = '16px Arial';
    ctx.textAlign = 'center';
    ctx.fillText(character.name, character.x, character.y - character.height - 10);

    // 绘制模式标签（如果有）
    CharacterRenderer.renderModeLabel(ctx, character);

    // 绘制血条
    CharacterRenderer.renderHealthBar(ctx, character);

    // 绘制剑气槽
    CharacterRenderer.renderKiBar(ctx, character);

    ctx.restore();
  }

  // 回退绘制（纯色块）
  private static renderFallbackCharacter(ctx: Canvas2DContext, character: Character): void {
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
