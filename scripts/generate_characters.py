#!/usr/bin/env python3
"""生成剑来游戏角色贴图"""
import json
import os

# 角色配置
CHARACTERS = [
    {"id": "chen_pingan", "name": "陈平安", "color": "#4A90E2", "faction": "swordsman"},
    {"id": "zhong_kui", "name": "钟离", "color": "#8B4513", "faction": "geo"},
    {"id": "ning_ya", "name": "宁姚", "color": "#FF69B4", "faction": "swordsman"},
    {"id": "yu_li_zi", "name": "郁泥子", "color": "#696969", "faction": "taoist"},
    {"id": "cao_qing_lang", "name": "曹晴朗", "color": "#FFD700", "faction": "scholar"},
    {"id": "aliang", "name": "阿良", "color": "#FF4500", "faction": "warrior"},
    {"id": "po_jun", "name": "破军", "color": "#800080", "faction": "general"},
    {"id": "wen_shu", "name": "文圣", "color": "#2F4F4F", "faction": "scholar"},
    {"id": "xu_mao", "name": "徐徐猫", "color": "#FFA07A", "faction": "beast"},
    {"id": "luo_shi_huang", "name": "洛柿黄", "color": "#FFA500", "faction": "merchant"},
]

OUTPUT_DIR = "/Users/ryan/Code/happ/Jianlai/entry/src/main/resources/rawfile/characters"

def create_character_image(char_info):
    """使用 Python 原生模块生成简单贴图"""
    import struct
    import zlib
    
    width, height = 128, 256
    color = char_info["color"]
    
    # 解析颜色
    r = int(color[1:3], 16)
    g = int(color[3:5], 16)
    b = int(color[5:7], 16)
    
    # 生成 PNG 图片数据
    def create_png(width, height, r, g, b):
        def output_chunk(chunk_type, data):
            chunk_len = len(data)
            chunk = chunk_type + data
            checksum = zlib.crc32(chunk) & 0xffffffff
            return struct.pack('>I', chunk_len) + chunk + struct.pack('>I', checksum)
        
        # PNG 签名
        png = b'\x89PNG\r\n\x1a\n'
        
        # IHDR
        ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
        png += output_chunk(b'IHDR', ihdr_data)
        
        # IDAT - 生成图像数据
        raw_data = b''
        for y in range(height):
            raw_data += b'\x00'  # 过滤字节
            for x in range(width):
                # 创建人形轮廓
                cx, cy = width // 2, height // 2
                
                # 头部
                if y < 60:
                    # 圆形头部
                    dist = ((x - cx) ** 2 + (y - 50) ** 2) ** 0.5
                    if dist < 35:
                        raw_data += bytes([r, g, b])
                    elif dist < 38:
                        # 边缘
                        raw_data += bytes([max(0, r-30), max(0, g-30), max(0, b-30)])
                    else:
                        raw_data += bytes([0, 0, 0, 0])
                # 身体
                elif y < 180:
                    # 身体主体
                    if 35 < x < 93:
                        raw_data += bytes([r, g, b])
                    elif (34 < x < 36 or 92 < x < 94) and 80 < y < 180:
                        # 边缘
                        raw_data += bytes([max(0, r-30), max(0, g-30), max(0, b-30)])
                    else:
                        raw_data += bytes([0, 0, 0, 0])
                # 腿部
                elif y < 256:
                    if (40 < x < 58) or (70 < x < 88):
                        raw_data += bytes([r, g, b])
                    else:
                        raw_data += bytes([0, 0, 0, 0])
                else:
                    raw_data += bytes([0, 0, 0, 0])
        
        compressed = zlib.compress(raw_data, 9)
        png += output_chunk(b'IDAT', compressed)
        
        # IEND
        png += output_chunk(b'IEND', b'')
        
        return png
    
    return create_png(width, height, r, g, b)

def main():
    print("正在生成角色贴图...")
    
    for char in CHARACTERS:
        char_id = char["id"]
        print(f"  生成 {char['name']}...")
        
        png_data = create_character_image(char)
        
        # 保存 PNG
        output_path = os.path.join(OUTPUT_DIR, f"{char_id}.png")
        with open(output_path, 'wb') as f:
            f.write(png_data)
    
    print(f"\n完成！生成了 {len(CHARACTERS)} 个角色贴图到:\n{OUTPUT_DIR}")

if __name__ == "__main__":
    main()
