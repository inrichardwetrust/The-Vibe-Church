@echo off & python -x "%~f0" %* & pause & exit /b
# -*- coding: utf-8 -*-
import sys
import os
import re

def process_file(file_path):
    filename = os.path.basename(file_path)
    
    try:
        # 以 UTF-8 讀取文件
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"❌ 讀取失敗: {filename} ({e})")
        return

    # ==========================================
    # 1. 提取並解析 Polymarket 原始複製文本
    # ==========================================
    # 正則匹配格式 (相容 Won/Lost, 價格¢或$, 以及利潤和ROI)
    raw_pattern = re.compile(
        r'(Won|Lost)\s+Market icon\s+(.*?)\s+([\d\.]+)\s+(Yes|No)\s+at\s+([\$0-9\.¢]+)\s+\$[\d\.]+\s+\$[\d\.]+\s+([-\$\d\.]+)\s+\(([-\d\.]+)%\)',
        re.IGNORECASE
    )
    
    match = raw_pattern.search(content)
    if not match:
        print(f"⏭️ 跳過: {filename}")
        print(f"   (未在文件中找到 Polymarket 原始文本，缺少 Won/Lost ... Market icon 等特徵)")
        return
        
    raw_status = match.group(1).title()      # Won 或 Lost
    raw_action = match.group(4).upper()      # YES 或 NO
    
    # 處理價格 (可能是 16¢ 也可能是 $0.16)
    price_str = match.group(5)
    if '¢' in price_str:
        raw_price = float(price_str.replace('¢', '')) / 100.0
    elif '$' in price_str:
        raw_price = float(price_str.replace('$', ''))
    else:
        raw_price = float(price_str)
        
    # 處理利潤與 ROI
    raw_profit_str = match.group(6).replace('$', '').replace(',', '')
    raw_profit = float(raw_profit_str)
    raw_roi = float(match.group(7))
    
    # 轉換為你的文檔標準格式
    expected_outcome = 'correct' if raw_status == 'Won' else 'incorrect'
    expected_action = f"BUY {raw_action}"
    
    print(f"📄 檢查文件: {filename}")
    print(f"   [提取真實數據] 結果: {expected_outcome} | 動作: {expected_action} | 價格: {raw_price} | 利潤: {raw_profit} | ROI: {raw_roi}%")
    
    errors =[]
    
    # 核心驗證函數
    def check_values(found_list, expected_val, name, is_float=False):
        if not found_list:
            errors.append(f"{name} 缺失: 文件中未找到此欄位")
            return
        for val in set(found_list):
            if is_float:
                try:
                    f_val = float(val)
                    # 允許 0.01 的浮點數誤差 (例如 0.1500001 和 0.15)
                    if abs(f_val - expected_val) > 0.011:
                        errors.append(f"{name} 錯誤: 真實應為 {expected_val}, 但文件中寫為 {f_val}")
                except ValueError:
                    pass
            else:
                if str(val).lower().strip() != str(expected_val).lower().strip():
                    errors.append(f"{name} 錯誤: 真實應為 '{expected_val}', 但文件中寫為 '{val}'")

    # ==========================================
    # 2. 從文件頭 YAML 與 內文 Markdown 提取各項數據並進行比對
    # ==========================================
    
    # A. 檢查 Outcome (correct / incorrect)
    outcomes = re.findall(r'outcome:\s*[\'"]?(correct|incorrect)[\'"]?', content, re.IGNORECASE) + \
               re.findall(r'\*\*Standard Outcome\*\*[：:]\s*[`\'"]?(correct|incorrect)[`\'"]?', content, re.IGNORECASE)
    check_values(outcomes, expected_outcome, "🎯 Outcome (正確/錯誤)")

    # B. 檢查 Trade Action (BUY YES / BUY NO)
    actions = re.findall(r'trade_action:\s*[\'"]?([^"\'\n]+)[\'"]?', content, re.IGNORECASE) + \
              re.findall(r'\*\*Trade Action\*\*[：:]\s*[`\'"]?([^`\'\n]+)[`\'"]?', content, re.IGNORECASE)
    actions = [a.strip() for a in actions]
    check_values(actions, expected_action, "🛍️ Trade Action (買入方向)")

    # C. 檢查 Entry Price (買入價格)
    prices = re.findall(r'entry_price:\s*([-\d\.]+)', content) + \
             re.findall(r'Entry\s*\$([-\d\.]+)', content)
    check_values(prices, raw_price, "💲 Entry Price (買入價格)", is_float=True)

    # D. 檢查 Profit (利潤)
    profits = re.findall(r'profit_usd:\s*([-\d\.]+)', content) + \
              re.findall(r'\*\*Profit\*\*[：:]\s*\$?([-\d\.]+)', content)
    check_values(profits, raw_profit, "💰 Profit (利潤)", is_float=True)

    # E. 檢查 ROI (回報率)
    rois = re.findall(r'roi_percent:\s*([-\d\.]+)', content) + \
           re.findall(r'ROI:\s*([-\d\.]+)\s*%', content)
    check_values(rois, raw_roi, "📈 ROI (回報率)", is_float=True)

    # ==========================================
    # 3. 輸出結果
    # ==========================================
    if errors:
        print("   ❌ 發現不匹配:")
        for err in set(errors):
            print(f"      - {err}")
    else:
        print("   ✅ 核對通過: (所有數據與原始文本完全匹配無誤)")

if __name__ == '__main__':
    files = sys.argv[1:]
    
    print("="*65)
    print("⚖️ Polymarket 投注數據一致性核查工具")
    print("="*65)
    
    if not files:
        print("\n💡 提示: 請選中一個或多個 Markdown 文件，將它們拖拽到此 BAT 檔圖標上放開即可。")
    else:
        for f in files:
            if os.path.isfile(f):
                process_file(f)
                print("-" * 65)
            else:
                print(f"⚠️ 無效的路徑: {f}")
    
    print("\n執行結束。")