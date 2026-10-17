# -*- coding: utf-8 -*-
"""
Supercombo SF6 Wiki Real CDP Crawler
Connects to user's Edge browser running on port 9222 to scrape authentic frame data.
"""

import sys
import os
import json
import time
import re
from playwright.sync_api import sync_playwright

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'assets', 'data')
RAW_DIR = os.path.join(OUTPUT_DIR, 'supercombo_raw')
OUTPUT_FILE = os.path.join(OUTPUT_DIR, 'sf6_wiki_framedata.json')

# Full 32 character list (including Arjun)
ROSTER_SLUGS = [
    ('ryu', 'Ryu'),
    ('ken', 'Ken'),
    ('luke', 'Luke'),
    ('cammy', 'Cammy'),
    ('chunli', 'Chun-Li'),
    ('guile', 'Guile'),
    ('zangief', 'Zangief'),
    ('juri', 'Juri'),
    ('akuma', 'Akuma'),
    ('bison', 'M._Bison'),
    ('terry', 'Terry'),
    ('arjun', 'Arjun'),
    ('ed', 'Ed'),
    ('rashid', 'Rashid'),
    ('aki', 'A.K.I.'),
    ('marisa', 'Marisa'),
    ('jp', 'JP'),
    ('manon', 'Manon'),
    ('deejay', 'Dee_Jay'),
    ('ehonda', 'E._Honda'),
    ('dhalsim', 'Dhalsim'),
    ('blanka', 'Blanka'),
    ('lily', 'Lily'),
    ('jamie', 'Jamie'),
    ('kimberly', 'Kimberly'),
    ('mai', 'Mai'),
    ('elena', 'Elena'),
    ('sagat', 'Sagat'),
    ('cviper', 'C._Viper'),
    ('alex', 'Alex'),
    ('ingrid', 'Ingrid'),
    ('yasmine', 'Yasmine'),
]

def main():
    print("=" * 60)
    print("  Supercombo Wiki SF6 CDP 真实数据采集爬虫")
    print("=" * 60)
    print("正在连接调试浏览器 http://127.0.0.1:9222 ...")

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    os.makedirs(RAW_DIR, exist_ok=True)

    with sync_playwright() as p:
        try:
            browser = p.chromium.connect_over_cdp("http://127.0.0.1:9222")
        except Exception as e:
            print(f"\n[ERROR] 无法连接到 127.0.0.1:9222！错误信息: {e}")
            print("请确认已经运行了 scripts/open_browser_for_crawler.bat 且 Edge 正常打开！")
            sys.exit(1)

        contexts = browser.contexts
        if not contexts:
            print("[ERROR] 未找到浏览器上下文！")
            sys.exit(1)

        page = contexts[0].pages[0] if contexts[0].pages else contexts[0].new_page()
        print(f"✔ 成功连接！当前页面标题: {page.title()} | URL: {page.url}")

        all_char_data = {}

        total = len(ROSTER_SLUGS)
        for idx, (char_id, wiki_name) in enumerate(ROSTER_SLUGS):
            target_url = f"https://wiki.supercombo.gg/w/Street_Fighter_6/{wiki_name}"
            print(f"\n[{idx+1}/{total}] 正在抓取格斗家: {wiki_name} ({char_id}) ...")
            print(f"  URL: {target_url}")

            try:
                page.goto(target_url, timeout=45000)
                page.wait_for_timeout(3000)

                # Check if Cloudflare challenged
                title = page.title()
                if "Just a moment" in title or "Cloudflare" in title or "Attention Required" in title:
                    print(f"  [WAIT] 检测到 Cloudflare 盾，请在浏览器中完成验证！等待中...")
                    page.wait_for_function("() => !document.title.includes('Just a moment') && !document.title.includes('Cloudflare')", timeout=60000)
                    print(f"  [OK] 验证通过！继续抓取...")
                    page.wait_for_timeout(2000)

                # Save raw HTML backup
                raw_html = page.content()
                raw_path = os.path.join(RAW_DIR, f"{char_id}.html")
                with open(raw_path, 'w', encoding='utf-8') as rf:
                    rf.write(raw_html)

                # Extract move tables and metadata
                extracted = page.evaluate("""() => {
                    const res = {
                        title: document.title,
                        moves: [],
                        tables: []
                    };

                    // 1. Extract from standard wikitables
                    const tables = document.querySelectorAll('table.wikitable');
                    tables.forEach((t, tIdx) => {
                        const tableData = [];
                        t.querySelectorAll('tr').forEach(tr => {
                            const row = [];
                            tr.querySelectorAll('th, td').forEach(cell => {
                                row.push(cell.innerText.trim());
                            });
                            if (row.length > 0) tableData.push(row);
                        });
                        if (tableData.length > 0) {
                            res.tables.push({ index: tIdx, rows: tableData });
                        }
                    });

                    // 2. Extract from Supercombo move cards/containers
                    const moveCards = document.querySelectorAll('.move-card, .cargo-data-move, [data-move-name]');
                    moveCards.forEach(card => {
                        res.moves.push({
                            name: card.getAttribute('data-move-name') || card.querySelector('.move-name')?.innerText?.trim() || '',
                            input: card.querySelector('.move-input')?.innerText?.trim() || '',
                            rawText: card.innerText.trim()
                        });
                    });

                    return res;
                }""")

                all_char_data[char_id] = {
                    'char_id': char_id,
                    'wiki_name': wiki_name,
                    'url': target_url,
                    'tables_count': len(extracted.get('tables', [])),
                    'moves_count': len(extracted.get('moves', [])),
                    'data': extracted
                }

                print(f"  ✔ 成功抓取: {wiki_name} -> 提取到 {len(extracted.get('tables', []))} 张表格，已保存原始 HTML 至 {raw_path}")

            except Exception as ex:
                print(f"  ✖ 抓取 {wiki_name} 出错: {ex}")

        # Save all scraped data to sf6_wiki_framedata.json
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            json.dump(all_char_data, f, ensure_ascii=False, indent=2)

        print("\n" + "=" * 60)
        print(f"✔ 全部抓取完毕！共保存 {len(all_char_data)} 位角色真实数据至:")
        print(f"  {OUTPUT_FILE}")
        print("=" * 60)

if __name__ == '__main__':
    main()
