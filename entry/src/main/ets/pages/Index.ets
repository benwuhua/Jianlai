import { GameEngine } from '../game/GameEngine';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { router } from '@kit.ArkUI';
import { HealthBar } from '../components/HealthBar';
import { SkillButton } from '../components/SkillButton';
import { SkillButtonBar } from '../components/SkillButtonBar';
import { CharacterManager } from '../game/CharacterManager';
import { SkillConfig } from '../models/Skill';
import { AIDifficulty } from '../models/AIBehavior';
import { PauseMenu } from '../components/PauseMenu';
import { KOScreen } from '../components/KOScreen';

const DOMAIN = 0x0000;
const TAG = 'Index';

// 使用 ArkTS 标准 Canvas 类型
type GameCanvas = CanvasRenderingContext2D;

@Entry
@Component
struct Index {
  @State private canvasContext: GameCanvas | null = null;
  private gameEngine: GameEngine | null = null;

  // 导航参数
  @State private characterId: string = '';
  @State private difficulty: string = 'normal';
  @State private playerName: string = '陈平安';

  // 暴露角色状态给UI
  @State playerHp: number = 1000;
  @State playerMaxHp: number = 1000;
  @State enemyHp: number = 1000;
  @State enemyMaxHp: number = 1000;

  // 技能和剑气状态
  @State playerSkills: SkillConfig[] = [];
  @State playerUltimate: SkillConfig | null = null;
  @State skillCooldowns: number[] = [0, 0, 0];
  @State ultimateCooldown: number = 0;
  @State currentKi: number = 0;
  @State maxKi: number = 100;
  @State canUseSkills: boolean[] = [true, true, true];
  @State canUseUltimate: boolean = false;

  // 战斗结束状态
  @State battleOver: boolean = false;
  @State winner: string = '';
  @State isVictory: boolean = false;

  // 暂停状态
  @State isPaused: boolean = false;

  build() {
    Stack() {
      // 游戏Canvas层
      RelativeContainer() {
        Canvas(this.canvasContext)
          .id('GameCanvas')
          .width('100%')
          .height('100%')
          .onReady(() => {
            try {
              if (this.canvasContext) {
                hilog.info(DOMAIN, TAG, 'Canvas initialized successfully');
                // 根据难度映射
                const difficultyMap: Record<string, AIDifficulty> = {
                  'easy': 'easy',
                  'normal': 'normal',
                  'hard': 'hard',
                  'expert': 'extreme'
                };
                const aiDifficulty = difficultyMap[this.difficulty] || 'normal';

                this.gameEngine = new GameEngine(this.canvasContext, aiDifficulty, this.characterId);
                // 设置回调更新UI (使用箭头函数替代 bind)
                this.gameEngine.setUIUpdateCallback(
                  (playerHp: number, playerMaxHp: number, enemyHp: number, enemyMaxHp: number,
                   battleOver: boolean = false, winnerName: string = '', isVictory: boolean = false) => {
                    this.updateUIFromGame(playerHp, playerMaxHp, enemyHp, enemyMaxHp, battleOver, winnerName, isVictory);
                  }
                );
                this.gameEngine.start();
              } else {
                hilog.error(DOMAIN, TAG, 'Canvas context is null');
              }
            } catch (error) {
              hilog.error(DOMAIN, TAG, 'Failed to initialize game engine: %{public}s', JSON.stringify(error));
            }
          })
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            right: { anchor: '__container__', align: HorizontalAlign.End }
          })
          .onKeyEvent((event) => {
            // 处理键盘事件
            if (this.gameEngine) {
              if (event.type === 2) { // KeyType.Down = 2
                const keyCode = event.keyCode.toString();

                // 暂停键（P键或ESC键）
                if (keyCode === '27' || keyCode === '80' || keyCode === 'p') { // ESC=27, P=80
                  this.togglePause();
                } else if (!this.isPaused && !this.battleOver) {
                  // 暂停状态下不处理其他按键
                  this.gameEngine.handleKeyDown(keyCode);
                }
              } else if (event.type === 3) { // KeyType.Up = 3
                if (!this.isPaused && !this.battleOver) {
                  this.gameEngine.handleKeyUp(event.keyCode.toString());
                }
              }
            }
          })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#000000')

      // KO/战斗结束界面
      // KOScreen({
      //   isVisible: this.battleOver,
      //   winner: this.winner,
      //   isVictory: this.isVictory,
      //   onRestart: () => {
      //     this.restartGame();
      //   },
      //   onQuit: () => {
      //     router.replaceUrl({ url: 'pages/MainMenu' });
      //   }
      // })

      // UI层
      Column() {
        // 顶部返回按钮和血条
        Column() {
          // 返回按钮
          Row() {
            Button('返回')
              .fontSize(14)
              .backgroundColor('#2C3E50')
              .onClick(() => {
                router.back();
              })

            Blank()
            Blank()
          }
          .width('100%')
          .padding({ left: 10, right: 10, top: 5 })

          // 血条
          Row() {
            HealthBar({
              name: this.playerName,
              currentHp: this.playerHp,
              maxHp: this.playerMaxHp,
              barPosition: 'top'
            })

            Blank()

            HealthBar({
              name: '敌人',
              currentHp: this.enemyHp,
              maxHp: this.enemyMaxHp,
              barPosition: 'top'
            })
          }
          .width('100%')
        }
        .width('100%')

        Blank()

        // 底部技能按钮栏
        SkillButtonBar({
          skills: this.playerSkills,
          ultimate: this.playerUltimate,
          cooldowns: this.skillCooldowns,
          ultimateCooldown: this.ultimateCooldown,
          currentKi: this.currentKi,
          maxKi: this.maxKi,
          canUseSkills: this.canUseSkills,
          canUseUltimate: this.canUseUltimate,
          onSkillPress: (index: number) => {
            if (this.gameEngine) {
              this.gameEngine.handleKeyDown((index + 1).toString());
            }
          },
          onUltimatePress: () => {
            if (this.gameEngine) {
              this.gameEngine.handleKeyDown('4');
            }
          }
        })
        .margin({ bottom: 20 })

        // 基础控制按钮
        Row() {
          SkillButton({
            label: '攻',
            onAction: () => {
              if (this.gameEngine) {
                this.gameEngine.handleKeyDown('j');
              }
            }
          })
          .onTouch((event: TouchEvent) => {
            if (this.gameEngine) {
              if (event.type === 3 || event.type === 4) { // TouchType.Up = 3, Cancel = 4
                this.gameEngine.handleKeyUp('j');
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
          .onTouch((event: TouchEvent) => {
            if (this.gameEngine) {
              if (event.type === 3 || event.type === 4) { // TouchType.Up = 3, Cancel = 4
                this.gameEngine.handleKeyUp('w');
              }
            }
          })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .padding({ bottom: 20 })
      }
      .width('100%')
      .height('100%')

      // KO/战斗结束界面（暂时注释 - hvigor bug）
      // KOScreen({...})

      // 暂停菜单（暂时注释 - hvigor bug）
      // PauseMenu({...})
    }
  }

  // 切换暂停状态
  private togglePause(): void {
    if (this.gameEngine) {
      this.isPaused = this.gameEngine.togglePause();
    }
  }

  // 重新开始游戏
  private restartGame(): void {
    // 重新加载页面
    router.replaceUrl({ url: 'pages/Index', params: {
      characterId: this.characterId,
      difficulty: this.difficulty
    }});
  }

  // 初始化Canvas上下文
  async aboutToAppear() {
    this.canvasContext = new CanvasRenderingContext2D();

    // 获取导航参数
    const params = router.getParams() as Record<string, string>;
    this.characterId = params['characterId'] || 'chen_pingan';
    this.difficulty = params['difficulty'] || 'normal';

    hilog.info(DOMAIN, TAG, 'Starting battle with character: %{public}s, difficulty: %{public}s',
      this.characterId, this.difficulty);

    // 加载角色数据
    const manager = CharacterManager.getInstance();
    await manager.loadAllCharacters();

    const characterConfig = manager.getCharacterConfig(this.characterId);
    if (characterConfig) {
      this.playerName = characterConfig.name;
      this.playerSkills = characterConfig.skills || [];
      this.playerUltimate = characterConfig.ultimate || null;
      hilog.info(DOMAIN, TAG, 'Player character: %{public}s with %{public}d skills',
        characterConfig.name, this.playerSkills.length);
    }

    // 预加载角色管理器数据，确保GameEngine可以访问
    hilog.info(DOMAIN, TAG, 'CharacterManager preloaded with %{public}d characters',
      manager.getAllCharacters().length);
  }

  // 清理资源
  aboutToDisappear() {
    if (this.gameEngine) {
      this.gameEngine.stop();
    }
  }

  // 从游戏引擎更新UI
  private updateUIFromGame(
    playerHp: number,
    playerMaxHp: number,
    enemyHp: number,
    enemyMaxHp: number,
    battleOver: boolean = false,
    winnerName: string = '',
    isVictory: boolean = false
  ): void {
    this.playerHp = playerHp;
    this.playerMaxHp = playerMaxHp;
    this.enemyHp = enemyHp;
    this.enemyMaxHp = enemyMaxHp;

    // 更新战斗结束状态
    this.battleOver = battleOver;
    this.winner = winnerName;
    this.isVictory = isVictory;

    // 更新技能和剑气数据
    if (this.gameEngine && !battleOver) {
      const player = this.gameEngine.getPlayer();
      const skillManager = player.getSkillManager();

      if (skillManager) {
        // 更新剑气
        this.currentKi = skillManager.getCurrentKi();
        this.maxKi = skillManager.getMaxKi();

        // 更新技能冷却
        this.skillCooldowns = [
          skillManager.getSkillCooldownRemaining(0),
          skillManager.getSkillCooldownRemaining(1),
          skillManager.getSkillCooldownRemaining(2)
        ];

        this.ultimateCooldown = skillManager.getUltimateCooldownRemaining();

        // 更新技能可用状态
        const c0 = skillManager.canUseSkill(0);
        const c1 = skillManager.canUseSkill(1);
        const c2 = skillManager.canUseSkill(2);
        this.canUseSkills = [c0 || false, c1 || false, c2 || false];

        this.canUseUltimate = (skillManager.canUseUltimate() || false);
      }
    }
  }
}
