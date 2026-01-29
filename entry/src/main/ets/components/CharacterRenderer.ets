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
