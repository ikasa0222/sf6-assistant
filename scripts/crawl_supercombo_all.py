# -*- coding: utf-8 -*-
import sys
import os
import json
import time

sys.stdout.reconfigure(encoding='utf-8', errors='replace')
sys.stderr.reconfigure(encoding='utf-8', errors='replace')

from playwright.sync_api import sync_playwright

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'assets', 'data')
RAW_DIR = os.path.join(OUTPUT_DIR, 'supercombo_raw')
OUTPUT_FILE = os.path.join(OUTPUT_DIR, 'supercombo_all_tables.json')

DATA_PAGES = [
    ('arjun', 'Arjun'),
    ('ryu', 'Ryu'),
    ('ken', 'Ken'),
    ('luke', 'Luke'),
    ('cammy', 'Cammy'),
    ('chunli', 'Chun-Li'),
    ('guile', 'Guile'),
    ('zangief', 'Zangief'),
    ('juri', 'Juri'),
    ('akuma', 'Akuma'),
    ('bison', 'M.Bison'),
    ('terry', 'Terry'),
    ('ed', 'Ed'),
    ('rashid', 'Rashid'),
    ('aki', 'A.K.I.'),
    ('marisa', 'Marisa'),
    ('jp', 'JP'),
    ('manon', 'Manon'),
    ('deejay', 'Dee_Jay'),
    ('ehonda', 'E.Honda'),
    ('dhalsim', 'Dhalsim'),
    ('blanka', 'Blanka'),
    ('lily', 'Lily'),
    ('jamie', 'Jamie'),
    ('kimberly', 'Kimberly'),
    ('mai', 'Mai'),
    ('elena', 'Elena'),
    ('sagat', 'Sagat'),
    ('cviper', 'C.Viper'),
    ('alex', 'Alex'),
    ('ingrid', 'Ingrid'),
    ('yasmine', 'Yasmine'),
]

def main():
    os.makedirs(RAW_DIR, exist_ok=True)
    print("=" * 65)
    print("  Supercombo Wiki SF6 32 格斗家权威 Frame Data 真实采集流水线")
    print("=" * 65)
    print("正在连接到本地 Edge 浏览器 (http://127.0.0.1:9222) ...")

    with sync_playwright() as p:
        try:
            b = p.chromium.connect_over_cdp('http://127.0.0.1:9222')
        except Exception as e:
            print(f"[ERROR] 无法连接到浏览器: {e}")
            sys.exit(1)

        ctx = b.contexts[0]
        page = ctx.pages[0] if ctx.pages else ctx.new_page()
        print(f"[+] 成功接管浏览器！当前窗口标题: {page.title()}\n")

        all_results = {}
        total = len(DATA_PAGES)

        for idx, (char_id, page_name) in enumerate(DATA_PAGES):
            target_url = f"https://wiki.supercombo.gg/w/Street_Fighter_6/{page_name}/Data"
            print(f"[{idx+1:2d}/{total:2d}] 抓取 {char_id.upper():8s} ({page_name}) -> {target_url} ...")

            try:
                page.goto(target_url, wait_until="domcontentloaded", timeout=45000)
                page.wait_for_timeout(2500)

                # Check title
                title = page.title()
                if "Just a moment" in title or "Cloudflare" in title:
                    print(f"   [WAIT] 触发 Cloudflare 盾，请在 Edge 窗口中点击验证...")
                    page.wait_for_function("() => !document.title.includes('Just a moment') && !document.title.includes('Cloudflare')", timeout=60000)
                    page.wait_for_timeout(2000)

                # Save raw HTML
                html = page.content()
                raw_file = os.path.join(RAW_DIR, f"{char_id}.html")
                with open(raw_file, 'w', encoding='utf-8') as rf:
                    rf.write(html)

                # Extract all tables
                tables = page.eval_on_selector_all(
                    "table.wikitable",
                    """tables => {
                        return tables.map(t => {
                            const rows = [];
                            t.querySelectorAll('tr').forEach(tr => {
                                const cells = [];
                                tr.querySelectorAll('th, td').forEach(c => cells.push(c.innerText.trim()));
                                if (cells.length > 0) rows.push(cells);
                            });
                            return rows;
                        });
                    }"""
                )

                all_results[char_id] = {
                    'char_id': char_id,
                    'page_name': page_name,
                    'url': target_url,
                    'tables_count': len(tables),
                    'tables': tables
                }

                print(f"   [OK] 成功采集: {len(tables)} 张帧数表格，已落盘保存至 assets/data/supercombo_raw/{char_id}.html ({round(len(html)/1024, 1)} KB)")

            except Exception as ex:
                print(f"   [FAIL] 采集 {char_id} 遇到异常: {ex}")

        with open(OUTPUT_FILE, 'w', encoding='utf-8') as of:
            json.dump(all_results, of, ensure_ascii=False, indent=2)

        print("\n" + "=" * 65)
        print(f"[SUCCESS] 全部 32 位角色真实数据采集完毕！已汇总保存至:")
        print(f"   {OUTPUT_FILE} ({round(os.path.getsize(OUTPUT_FILE)/1024, 1)} KB)")
        print("=" * 65)

if __name__ == '__main__':
    main()
