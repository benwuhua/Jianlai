#!/usr/bin/env python3
"""
剑来游戏 UX 测试 Agent
自动测试编译、渲染和功能
"""

import subprocess
import os
import sys
import json
from pathlib import Path

PROJECT_DIR = "/Users/ryan/Code/happ/Jianlai"
DEVECO_SDK_HOME = "/Applications/DevEco-Studio.app/Contents/sdk"

class UXTester:
    def __init__(self):
        self.errors = []
        self.warnings = []
        
    def run_command(self, cmd, cwd=None):
        """运行命令并返回结果"""
        try:
            result = subprocess.run(
                cmd,
                shell=True,
                cwd=cwd or PROJECT_DIR,
                capture_output=True,
                text=True,
                timeout=300
            )
            return result
        except subprocess.TimeoutExpired:
            return None, "超时", ""
    
    def compile_project(self):
        """编译项目"""
        print("\n📦 编译项目...")
        os.chdir(PROJECT_DIR)
        os.environ["DEVECO_SDK_HOME"] = DEVECO_SDK_HOME
        
        result = self.run_command("./hvigorw assembleHap")
        
        if result and result.returncode == 0:
            print("✅ 编译成功！")
            return True
        else:
            output = result.stderr if result else ""
            print("❌ 编译失败！")
            print(output)
            
            # 检查是否是 Java 问题
            if "Java Runtime" in output or "Unable to locate a Java" in output:
                print("\n⚠️  需要安装 Java！")
                print("   运行: brew install openjdk@17")
                print("   然后设置 JAVA_HOME")
                self.warnings.append("缺少 Java 运行环境")
                
            self.parse_errors(output)
            return False
    
    def parse_errors(self, output):
        """解析错误信息"""
        for line in output.split("\n"):
            if "ERROR" in line and ".ets:" in line:
                # 提取错误文件
                parts = line.split(".ets:")
                if len(parts) >= 2:
                    file = parts[0].split("/")[-1] + ".ets"
                    error_msg = parts[1][:100]
                    self.errors.append(f"{file}: {error_msg}")
    
    def check_files(self):
        """检查关键文件"""
        print("\n🔍 检查关键文件...")
        
        key_files = [
            "entry/src/main/ets/pages/Index.ets",
            "entry/src/main/ets/game/GameEngine.ets",
            "entry/src/main/ets/components/CharacterRenderer.ets",
            "entry/src/main/ets/pages/MainMenu.ets",
        ]
        
        for file in key_files:
            path = Path(PROJECT_DIR) / file
            if path.exists():
                print(f"  ✅ {file}")
            else:
                print(f"  ❌ {file} 不存在！")
                self.errors.append(f"缺失文件: {file}")
    
    def check_rendering(self):
        """检查渲染代码"""
        print("\n🎨 检查渲染代码...")
        
        # 检查 GameEngine.render 是否有背景绘制
        render_file = Path(PROJECT_DIR) / "entry/src/main/ets/game/GameEngine.ets"
        if render_file.exists():
            content = render_file.read_text()
            
            # 检查背景色
            if "#87CEEB" in content or "fillRect" in content:
                print("  ✅ 有背景绘制代码")
            else:
                print("  ⚠️  可能缺少背景绘制")
                self.warnings.append("缺少背景绘制代码")
            
            # 检查 CharacterRenderer 调用
            if "CharacterRenderer.render" in content:
                print("  ✅ 有角色渲染调用")
            else:
                print("  ❌ 没有角色渲染调用！")
                self.errors.append("缺少角色渲染调用")
    
    def test_and_fix(self):
        """测试并自动修复"""
        print("\n🧪 开始测试...")
        
        # 1. 编译
        if not self.compile_project():
            print("\n⚠️  编译失败，跳过功能测试")
            return False
        
        # 2. 检查文件
        self.check_files()
        
        # 3. 检查渲染
        self.check_rendering()
        
        # 4. 输出结果
        print("\n" + "="*50)
        print("  测试结果")
        print("="*50)
        
        if self.errors:
            print(f"\n❌ 发现 {len(self.errors)} 个错误：")
            for i, err in enumerate(self.errors, 1):
                print(f"   {i}. {err}")
        
        if self.warnings:
            print(f"\n⚠️  发现 {len(self.warnings)} 个警告：")
            for i, warn in enumerate(self.warnings, 1):
                print(f"   {i}. {warn}")
        
        if not self.errors:
            print("\n✅ 所有测试通过！")
            return True
        else:
            print("\n⚠️  需要修复问题后才能提交")
            return False
    
    def commit_and_push(self, message=None):
        """提交并推送"""
        if self.errors:
            print("❌ 有错误不能提交！")
            return False
        
        os.chdir(PROJECT_DIR)
        
        # 检查是否有变更
        result = self.run_command("git status --short")
        if not result or not result.stdout.strip():
            print("📝 没有变更需要提交")
            return True
        
        # 默认消息
        msg = message or "fix: UX 测试修复"
        
        # 提交
        print(f"\n📤 提交: {msg}")
        self.run_command(f'git add -A && git commit -m "{msg}"')
        
        # 推送
        print("🚀 推送中...")
        result = self.run_command("git push")
        
        if result and result.returncode == 0:
            print("✅ 推送成功！")
            return True
        else:
            print("❌ 推送失败！")
            return False


def main():
    tester = UXTester()
    
    print("="*50)
    print("  剑来游戏 - UX 测试 Agent")
    print("="*50)
    
    # 运行测试
    success = tester.test_and_fix()
    
    if success and tester.errors:
        # 有错误但编译通过，尝试修复
        print("\n🔧 自动修复中...")
        # 这里可以添加自动修复逻辑
        tester.commit_and_push("fix: UX 测试自动修复")
    elif success:
        tester.commit_and_push("chore: UX 测试通过")


if __name__ == "__main__":
    main()
