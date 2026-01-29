// AI难度级别
export type AIDifficulty = 'easy' | 'normal' | 'hard' | 'extreme';

// AI行为配置
export interface AIBehavior {
  difficulty: AIDifficulty;
  reactionTime: number;      // 反应时间（毫秒）
  blockRate: number;         // 格挡概率 (0-1)
  skillUsageRate: number;    // 技能使用率 (0-1)
  attackInterval: number;    // 攻击间隔（毫秒）
  canCombo: boolean;         // 是否会连招
  canPredict: boolean;       // 是否会预判
}

// 默认AI配置
export const DEFAULT_AI_BEHAVIOR: Record<AIDifficulty, AIBehavior> = {
  easy: {
    difficulty: 'easy',
    reactionTime: 1000,
    blockRate: 0.0,
    skillUsageRate: 0.0,
    attackInterval: 4000,
    canCombo: false,
    canPredict: false
  },
  normal: {
    difficulty: 'normal',
    reactionTime: 500,
    blockRate: 0.3,
    skillUsageRate: 0.2,
    attackInterval: 2500,
    canCombo: false,
    canPredict: false
  },
  hard: {
    difficulty: 'hard',
    reactionTime: 200,
    blockRate: 0.6,
    skillUsageRate: 0.5,
    attackInterval: 1500,
    canCombo: true,
    canPredict: true
  },
  extreme: {
    difficulty: 'extreme',
    reactionTime: 100,
    blockRate: 0.8,
    skillUsageRate: 0.8,
    attackInterval: 800,
    canCombo: true,
    canPredict: true
  }
};
