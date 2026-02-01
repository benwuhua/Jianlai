#!/bin/bash
# 剑来游戏 UX 测试脚本

set -e

echo "========================================"
echo "  剑来游戏 - UX 测试脚本"
echo "========================================"

PROJECT_DIR="/Users/ryan/Code/happ/Jianlai"
cd "$PROJECT_DIR"

# 设置环境变量
export DEVECO_SDK_HOME="/Applications/DevEco-Studio.app/Contents/sdk"

echo ""
echo "1️⃣  清理并编译项目..."
echo "========================================"
./hvigorw clean 2>/dev/null || true
./hvigorw assembleHap

echo ""
echo "2️⃣  检查编译结果..."
echo "========================================"
if [ $? -eq 0 ]; then
    echo "✅ 编译成功！"
    
    # 检查生成的 HAP 文件
    HAP_FILE=$(find . -name "*.hap" -type f 2>/dev/null | head -1)
    if [ -n "$HAP_FILE" ]; then
        echo "📦 HAP 文件: $HAP_FILE"
    fi
else
    echo "❌ 编译失败！"
    exit 1
fi

echo ""
echo "3️⃣  检查代码变更..."
echo "========================================"
git status --short

echo ""
echo "4️⃣  待测试项..."
echo "========================================"
echo "  □ MainMenu 入口页面"
echo "  □ CharacterSelect 角色选择"
echo "  □ DifficultySelect 难度选择"  
echo "  □ Index 战斗页面"
echo "  □ Canvas 渲染"
echo "  □ 角色显示"
echo "  □ 背景显示"

echo ""
echo "========================================"
echo "  测试完成！请在真机上验证 UX。"
echo "========================================"
