@echo off & python -x "%~f0" %* & pause & exit /b
# -*- coding: utf-8 -*-
import sys
import os
import re

# ==========================================
# 完整 64 卦 物理翻譯與符號映射字典 (支援簡繁體)
# ==========================================
HEX_DATA = {
    "乾为天": ("Heaven over Heaven", "䷀"), "乾為天": ("Heaven over Heaven", "䷀"),
    "坤为地": ("Earth over Earth", "䷁"), "坤為地": ("Earth over Earth", "䷁"),
    "水雷屯": ("Water over Thunder", "䷂"),
    "山水蒙": ("Mountain over Water", "䷃"),
    "水天需": ("Water over Heaven", "䷄"),
    "天水讼": ("Heaven over Water", "䷅"), "天水訟": ("Heaven over Water", "䷅"),
    "地水师": ("Earth over Water", "䷆"), "地水師": ("Earth over Water", "䷆"),
    "水地比": ("Water over Earth", "䷇"),
    "风天小畜": ("Wind over Heaven", "䷈"), "風天小畜": ("Wind over Heaven", "䷈"),
    "天泽履": ("Heaven over Lake", "䷉"), "天澤履": ("Heaven over Lake", "䷉"),
    "地天泰": ("Earth over Heaven", "䷊"),
    "天地否": ("Heaven over Earth", "䷋"),
    "天火同人": ("Heaven over Fire", "䷌"),
    "火天大有": ("Fire over Heaven", "䷍"),
    "地山谦": ("Earth over Mountain", "䷎"), "地山謙": ("Earth over Mountain", "䷎"),
    "雷地豫": ("Thunder over Earth", "䷏"),
    "泽雷随": ("Lake over Thunder", "䷐"), "澤雷隨": ("Lake over Thunder", "䷐"),
    "山风蛊": ("Mountain over Wind", "䷑"), "山風蠱": ("Mountain over Wind", "䷑"),
    "地泽临": ("Earth over Lake", "䷒"), "地澤臨": ("Earth over Lake", "䷒"),
    "风地观": ("Wind over Earth", "䷓"), "風地觀": ("Wind over Earth", "䷓"),
    "火雷噬嗑": ("Fire over Thunder", "䷔"),
    "山火贲": ("Mountain over Fire", "䷕"), "山火賁": ("Mountain over Fire", "䷕"),
    "山地剥": ("Mountain over Earth", "䷖"), "山地剝": ("Mountain over Earth", "䷖"),
    "地雷复": ("Earth over Thunder", "䷗"), "地雷復": ("Earth over Thunder", "䷗"),
    "天雷无妄": ("Heaven over Thunder", "䷘"), "天雷無妄": ("Heaven over Thunder", "䷘"),
    "山天大畜": ("Mountain over Heaven", "䷙"),
    "山雷颐": ("Mountain over Thunder", "䷚"), "山雷頤": ("Mountain over Thunder", "䷚"),
    "泽风大过": ("Lake over Wind", "䷛"), "澤風大過": ("Lake over Wind", "䷛"),
    "坎为水": ("Water over Water", "䷜"), "坎為水": ("Water over Water", "䷜"),
    "离为火": ("Fire over Fire", "䷝"), "離為火": ("Fire over Fire", "䷝"),
    "泽山咸": ("Lake over Mountain", "䷞"), "澤山咸": ("Lake over Mountain", "䷞"),
    "雷风恒": ("Thunder over Wind", "䷟"), "雷風恆": ("Thunder over Wind", "䷟"),
    "天山遁": ("Heaven over Mountain", "䷠"),
    "雷天大壮": ("Thunder over Heaven", "䷡"), "雷天大壯": ("Thunder over Heaven", "䷡"),
    "火地晋": ("Fire over Earth", "䷢"), "火地晉": ("Fire over Earth", "䷢"),
    "地火明夷": ("Earth over Fire", "䷣"),
    "风火家人": ("Wind over Fire", "䷤"), "風火家人": ("Wind over Fire", "䷤"),
    "火泽睽": ("Fire over Lake", "䷥"), "火澤睽": ("Fire over Lake", "䷥"),
    "水山蹇": ("Water over Mountain", "䷦"),
    "雷水解": ("Thunder over Water", "䷧"),
    "山泽损": ("Mountain over Lake", "䷨"), "山澤損": ("Mountain over Lake", "䷨"),
    "风雷益": ("Wind over Thunder", "䷩"), "風雷益": ("Wind over Thunder", "䷩"),
    "泽天夬": ("Lake over Heaven", "䷪"), "澤天夬": ("Lake over Heaven", "䷪"),
    "天风姤": ("Heaven over Wind", "䷫"), "天風姤": ("Heaven over Wind", "䷫"),
    "泽地萃": ("Lake over Earth", "䷬"), "澤地萃": ("Lake over Earth", "䷬"),
    "地风升": ("Earth over Wind", "䷭"), "地風升": ("Earth over Wind", "䷭"),
    "泽水困": ("Lake over Water", "䷮"), "澤水困": ("Lake over Water", "䷮"),
    "水风井": ("Water over Wind", "䷯"), "水風井": ("Water over Wind", "䷯"),
    "泽火革": ("Lake over Fire", "䷰"), "澤火革": ("Lake over Fire", "䷰"),
    "火风鼎": ("Fire over Wind", "䷱"), "火風鼎": ("Fire over Wind", "䷱"),
    "震为雷": ("Thunder over Thunder", "䷲"), "震為雷": ("Thunder over Thunder", "䷲"),
    "艮为山": ("Mountain over Mountain", "䷳"), "艮為山": ("Mountain over Mountain", "䷳"),
    "风山渐": ("Wind over Mountain", "䷴"), "風山漸": ("Wind over Mountain", "䷴"),
    "雷泽归妹": ("Thunder over Lake", "䷵"), "雷澤歸妹": ("Thunder over Lake", "䷵"),
    "雷火丰": ("Thunder over Fire", "䷶"), "雷火豐": ("Thunder over Fire", "䷶"),
    "火山旅": ("Fire over Mountain", "䷷"),
    "巽为风": ("Wind over Wind", "䷸"), "巽為風": ("Wind over Wind", "䷸"),
    "兑为泽": ("Lake over Lake", "䷹"), "兌為澤": ("Lake over Lake", "䷹"),
    "风水涣": ("Wind over Water", "䷺"), "風水渙": ("Wind over Water", "䷺"),
    "水泽节": ("Water over Lake", "䷻"), "水澤節": ("Water over Lake", "䷻"),
    "风泽中孚": ("Wind over Lake", "䷼"), "風澤中孚": ("Wind over Lake", "䷼"),
    "雷山小过": ("Thunder over Mountain", "䷽"), "雷山小過": ("Thunder over Mountain", "䷽"),
    "水火既济": ("Water over Fire", "䷾"), "水火既濟": ("Water over Fire", "䷾"),
    "火水未济": ("Fire over Water", "䷿"), "火水未濟": ("Fire over Water", "䷿")
}

def update_yaml(content):
    """清理文件頭部的 YAML 結構"""
    def repl(match):
        zh_line, zh_val, en_line, en_val = match.groups()
        clean_zh = zh_val.strip("'\" ")
        
        if clean_zh in HEX_DATA:
            en_trans, _ = HEX_DATA[clean_zh]
            # 保持原有的引號格式
            if zh_val.startswith("'"):
                new_en = f"'{en_trans}'"
            elif zh_val.startswith('"'):
                new_en = f'"{en_trans}"'
            else:
                new_en = f"'{en_trans}'" # 安全起見，統一加上引號
            return f"{zh_line}{zh_val}{en_line}{new_en}"
        return match.group(0)

    # 匹配相鄰的 zh: 與 en:
    pattern = re.compile(r'([ \t]*zh:[ \t]*)([^\n]+)(\r?\n[ \t]*en:[ \t]*)([^\n]+)')
    return pattern.sub(repl, content)

def update_markdown_list(content):
    """更新 ### 🧬 卦象参数 區塊"""
    def repl(match):
        prefix = match.group(1) 
        rest = match.group(2)
        # 提取中文卦名
        m_name = re.match(r'^[*]*([^/a-zA-Z䷀-䷿\s*]+)', rest.strip())
        if m_name:
            clean_zh = m_name.group(1)
            if clean_zh in HEX_DATA:
                en_trans, symbol = HEX_DATA[clean_zh]
                return f"{prefix}{clean_zh} {symbol} / *{en_trans}*"
        return match.group(0)
        
    pattern = re.compile(r'(^[ \t]*-[ \t]*\*\*(?:本卦 Base|变卦 Transformed)\*\*[：:][ \t]*)([^\n]+)', re.MULTILINE)
    return pattern.sub(repl, content)

def update_raw_logs(content):
    """更新 📜 原始推演记录 中的離散卦象，智慧清除拼音並附加符號與翻譯"""
    def log_repl(match):
        zh_name = match.group(1)
        en_trans, symbol = HEX_DATA[zh_name]
        return f"{zh_name} {symbol} ({en_trans})"
        
    names_pattern = '|'.join(HEX_DATA.keys())
    # 鎖定英文字母與拼音聲調（不傷及中文解釋，如 "上坤☷"）
    pinyin_chars = r"A-Za-zāáǎàōóǒòēéěèīíǐìūúǔùǖǘǚǜü\s\-"
    pinyin_regex = rf"(?:(?:[ \t]*[（(][{pinyin_chars}]+[)）])|(?:[ \t]*/[ \t]*[{pinyin_chars}]+))"
    pattern = re.compile(rf'({names_pattern}){pinyin_regex}?')
    
    lines = content.split('\n')
    new_lines =[]
    for line in lines:
        # 跳過已經處理過的 YAML 區塊與 Markdown 列表區塊
        if line.strip().startswith(('zh:', 'en:', 'base:', 'transformed:')):
            new_lines.append(line)
            continue
        if '- **本卦 Base**:' in line or '- **变卦 Transformed**:' in line:
            new_lines.append(line)
            continue
            
        # 只針對包含特定特徵的上下文行進行替換
        if any(kw in line for kw in['🔮', '【本卦', '【变卦', '卦象', '之卦']):
            # 事先剝離舊的六爻卦符，保證程式可重複運行（Idempotent）
            for sym in set(v[1] for v in HEX_DATA.values()):
                line = line.replace(f" {sym}", "").replace(sym, "")
            line = pattern.sub(log_repl, line)
            
        new_lines.append(line)
        
    return '\n'.join(new_lines)

def process_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        original_content = content
        
        # 依序執行三個模組的替換
        content = update_yaml(content)
        content = update_markdown_list(content)
        content = update_raw_logs(content)
        
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✅ 翻譯統一成功: {os.path.basename(filepath)}")
        else:
            print(f"⏭️ 格式已標準，無需修改: {os.path.basename(filepath)}")
            
    except Exception as e:
        print(f"❌ 處理失敗: {os.path.basename(filepath)} ({e})")

def get_md_files(paths):
    files =[]
    for p in paths:
        if os.path.isfile(p) and p.lower().endswith('.md'):
            files.append(p)
        elif os.path.isdir(p):
            for root, _, fns in os.walk(p):
                for fn in fns:
                    if fn.lower().endswith('.md'):
                        files.append(os.path.join(root, fn))
    return files

if __name__ == '__main__':
    paths = sys.argv[1:]
    print("="*60)
    print("☯️ VibeIChing 卦象翻譯與物理符號統一工具")
    print("="*60)
    
    if not paths:
        print("\n💡 提示: 請選中單個 Markdown 文件，或整個資料夾，拖拽到此 BAT 檔圖標上放開即可。")
    else:
        files = get_md_files(paths)
        if not files:
            print("⚠️ 未找到任何 Markdown (.md) 文件！")
        else:
            for f in files:
                process_file(f)
    print("\n執行結束。")