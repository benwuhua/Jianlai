// 测试用例汇总导出
// 这个文件用于集中导入和运行所有测试用例

import CharacterTest from './Character.test';
import SkillTest from './Skill.test';
import SkillManagerTest from './SkillManager.test';
import CharacterManagerTest from './CharacterManager.test';
import BattleSystemTest from './BattleSystem.test';
import ModeManagerTest from './ModeManager.test';
import CollisionDetectorTest from './CollisionDetector.test';

// 默认导出所有测试套件
export default function allTests() {
  CharacterTest();
  SkillTest();
  SkillManagerTest();
  CharacterManagerTest();
  BattleSystemTest();
  ModeManagerTest();
  CollisionDetectorTest();
}
