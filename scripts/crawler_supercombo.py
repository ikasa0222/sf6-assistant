# Supercombo GG SF6 Combos & Move Data Crawler
# Scrapes structured combo data & frame data from https://wiki.supercombo.gg/w/Street_Fighter_6

import os
import sys
import json
import re
import time
from bs4 import BeautifulSoup
from playwright.sync_api import sync_playwright

CHARACTERS = [
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
    ('ed', 'Ed'),
    ('marisa', 'Marisa'),
    ('jp', 'JP'),
    ('rashid', 'Rashid'),
    ('aki', 'A.K.I.'),
    ('mai', 'Mai'),
    ('elena', 'Elena'),
    ('jamie', 'Jamie'),
    ('kimberly', 'Kimberly'),
    ('ehonda', 'E._Honda'),
    ('blanka', 'Blanka'),
    ('lily', 'Lily'),
    ('manon', 'Manon'),
    ('dhalsim', 'Dhalsim'),
]

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'assets', 'data')
OUTPUT_FILE = os.path.join(OUTPUT_DIR, 'sf6_combos.json')

def parse_html_combos(char_id, html):
    soup = BeautifulSoup(html, 'html.parser')
    res = []
    combo_idx = 1
    for table in soup.find_all('table', class_='wikitable'):
        ths = [th.get_text(strip=True) for th in table.find_all('th')]
        starter = 'Normal Hit'
        if ths:
            for s in ['Punish Counter', 'Counter Hit', 'Normal Hit', 'Drive Rush', 'Drive Impact', 'Anti-Air', 'Stun']:
                if s.lower() in ths[0].lower():
                    starter = s
                    break
            else:
                starter = ths[0]
        
        rows = table.find_all('tr')
        for r in rows:
            cells = [td.get_text(strip=True) for td in r.find_all(['td', 'th'])]
            if not cells or cells[0] in ['Combo', 'Starter', 'Damage'] or 'Combo' in cells:
                continue
            if len(cells) >= 3:
                combo_text = cells[0].strip()
                if len(combo_text) < 3 or combo_text == 'Combo':
                    continue
                pos = cells[1].strip() if len(cells) > 1 else 'Anywhere'
                dmg = cells[2].strip() if len(cells) > 2 else '-'
                drive = cells[3].strip() if len(cells) > 3 else '0'
                super_g = cells[4].strip() if len(cells) > 4 else '0'
                diff = cells[5].strip() if len(cells) > 5 else 'Easy'
                notes = cells[6].strip() if len(cells) > 6 else ''
                
                res.append({
                    'id': f'{char_id}_{combo_idx}',
                    'characterId': char_id,
                    'starterType': starter,
                    'comboSequence': combo_text,
                    'position': pos,
                    'damage': dmg,
                    'driveGauge': drive,
                    'superGauge': super_g,
                    'difficulty': diff,
                    'notes': notes,
                    'source': 'Supercombo GG'
                })
                combo_idx += 1
    return res

def crawl_all(target_chars=None):
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    all_data = {}
    if os.path.exists(OUTPUT_FILE):
        try:
            with open(OUTPUT_FILE, 'r', encoding='utf-8') as f:
                all_data = json.load(f)
        except Exception:
            all_data = {}

    to_crawl = CHARACTERS
    if target_chars:
        targets = [t.lower() for t in target_chars]
        to_crawl = [c for c in CHARACTERS if c[0] in targets or c[1].lower() in targets]

    print(f'Starting crawl for {len(to_crawl)} characters from Supercombo GG...')

    with sync_playwright() as p:
        browser = p.chromium.launch(channel='msedge', headless=True)
        context = browser.new_context(
            user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0',
            viewport={'width': 1280, 'height': 800}
        )
        page = context.new_page()

        for char_id, wiki_name in to_crawl:
            url = f'https://wiki.supercombo.gg/w/Street_Fighter_6/{wiki_name}/Combos'
            print(f'Fetching {wiki_name} -> {url}')
            try:
                page.goto(url, wait_until='domcontentloaded', timeout=25000)
                page.wait_for_timeout(2000)
                html = page.content()
                combos = parse_html_combos(char_id, html)
                print(f'  Successfully parsed {len(combos)} combos for {wiki_name}')
                if combos:
                    all_data[char_id] = combos
                time.sleep(1)
            except Exception as e:
                print(f'  Failed fetching {wiki_name}: {e}')

        browser.close()

    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(all_data, f, ensure_ascii=False, indent=2)
    print(f'All combos saved to {OUTPUT_FILE} (Total characters: {len(all_data)})')

if __name__ == '__main__':
    args = sys.argv[1:]
    crawl_all(args if args else None)
