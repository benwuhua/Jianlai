import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { CollisionDetector } from '../utils/CollisionDetector';
import { Character } from '../models/Character';

export default function CollisionDetectorTest() {
  describe('CollisionDetectorTest', () => {
    let char1: Character;
    let char2: Character;

    beforeEach(() => {
      char1 = new Character('char1', '角色1', 100, 500, '#4A90E2');
      char1.width = 100;
      char1.height = 150;

      char2 = new Character('char2', '角色2', 200, 500, '#E74C3C');
      char2.width = 100;
      char2.height = 150;
    });

    afterEach(() => {
      char1 = null;
      char2 = null;
    });

    afterAll(() => {
      // 清理
    });

    // 测试AABB碰撞检测
    it('testAABBCollision', 0, () => {
      char1.x = 100;
      char2.x = 150; // 重叠

      const result = CollisionDetector.checkAABB(char1, char2);
      expect(result).assertTrue();
    });

    it('testAABBNoCollision', 0, () => {
      char1.x = 100;
      char2.x = 300; // 距离100像素

      const result = CollisionDetector.checkAABB(char1, char2);
      expect(result).assertFalse();
    });

    // 测试距离计算
    it('testGetDistance', 0, () => {
      char1.x = 0;
      char1.y = 0;
      char2.x = 300;
      char2.y = 400; // 距离 = sqrt(300^2 + 400^2) = 500

      const distance = CollisionDetector.getDistance(char1, char2);
      expect(distance).assertEqual(500);
    });

    it('testGetDistanceSamePosition', 0, () => {
      char1.x = 100;
      char1.y = 100;
      char2.x = 100;
      char2.y = 100;

      const distance = CollisionDetector.getDistance(char1, char2);
      expect(distance).assertEqual(0);
    });

    // 测试攻击范围检测
    it('testAttackRangeInRange', 0, () => {
      char1.x = 100;
      char2.x = 150; // 距离50

      const result = CollisionDetector.checkAttackRange(char1, char2, 100);
      expect(result).assertTrue();
    });

    it('testAttackRangeOutOfRange', 0, () => {
      char1.x = 100;
      char2.x = 200; // 距离100

      const result = CollisionDetector.checkAttackRange(char1, char2, 80);
      expect(result).assertFalse();
    });

    it('testAttackRangeExactlyAtEdge', 0, () => {
      char1.x = 100;
      char2.x = 200; // 距离100

      const result = CollisionDetector.checkAttackRange(char1, char2, 100);
      expect(result).assertTrue();
    });

    // 测试屏幕边界限制
    it('testClampToScreen', 0, () => {
      char1.x = -50;
      CollisionDetector.clampToScreen(char1, 800, 600);
      expect(char1.x).assertEqual(50); // width/2 = 50

      char1.x = 900;
      CollisionDetector.clampToScreen(char1, 800, 600);
      expect(char1.x).assertEqual(750); // 800 - 50
    });

    it('testClampYAxis', 0, () => {
      char1.y = -50;
      CollisionDetector.clampToScreen(char1, 800, 600);
      expect(char1.y).assertEqual(150); // height = 150

      char1.y = 700;
      CollisionDetector.clampToScreen(char1, 800, 600);
      expect(char1.y).assertEqual(600);
    });

    // 测试空值处理
    it('testNullCharacter', 0, () => {
      expect(CollisionDetector.checkAABB(null, char2)).assertFalse();
      expect(CollisionDetector.checkAABB(char1, null)).assertFalse();
      expect(CollisionDetector.getDistance(null, char2)).assertEqual(0);
      expect(CollisionDetector.getDistance(char1, null)).assertEqual(0);
      expect(CollisionDetector.checkAttackRange(null, char2, 100)).assertFalse();
      CollisionDetector.clampToScreen(null, 800, 600); // 不应该崩溃
    });

    // 测试垂直距离
    it('testVerticalDistance', 0, () => {
      char1.x = 100;
      char1.y = 500;
      char2.x = 100;
      char2.y = 450; // 垂直距离50

      const distance = CollisionDetector.getDistance(char1, char2);
      expect(distance).assertEqual(50);
    });

    // 测试对角线距离
    it('testDiagonalDistance', 0, () => {
      char1.x = 0;
      char1.y = 0;
      char2.x = 100;
      char2.y = 100; // 对角线距离 sqrt(20000) ≈ 141.42

      const distance = CollisionDetector.getDistance(char1, char2);
      expect(Math.abs(distance - 141.42)).assertLessThan(0.1);
    });

    // 测试边界情况
    it('testEdgeCollision', 0, () => {
      // 角色1右边 = 角色2左边
      char1.x = 100;
      char1.width = 100; // 右边界 = 150
      char2.x = 150;
      char2.width = 100; // 左边界 = 100

      const result = CollisionDetector.checkAABB(char1, char2);
      expect(result).assertTrue();
    });

    // 测试反向攻击范围
    it('testAttackRangeBehind', 0, () => {
      char1.x = 200;
      char1.facing = -1; // 朝向左
      char2.x = 150; // 在左边

      const result = CollisionDetector.checkAttackRange(char1, char2, 100);
      expect(result).assertTrue();
    });
  });
}
