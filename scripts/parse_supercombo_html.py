# -*- coding: utf-8 -*-
"""
Parser to convert scraped Supercombo Wiki raw HTML / tables into sf6_framedata.json
"""

import os
import sys
import json
import re
from bs4 import BeautifulSoup

DATA_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'assets', 'data')
RAW_DIR = os.path.join(DATA_DIR, 'supercombo_raw')
OUT_FILE = os.path.join(DATA_DIR, 'sf6_framedata.json')

def clean(val):
    if not val:
        return '-'
    s = str(val).strip()
    return s if s else '-'

def parse_html_character(char_id, html_content):
    soup = BeautifulSoup(html_content, 'html.parser')
    moves = []

    # Supercombo Wiki uses data-move-name or tables with th/td
    tables = soup.find_all('table', class_='wikitable')
    for table in tables:
        rows = table.find_all('tr')
        if not rows:
            continue
        
        headers = [th.get_text(strip=True).lower() for th in rows[0].find_all(['th', 'td'])]
        # Check if table looks like frame data table
        if not any('startup' in h or 'block' in h or 'damage' in h for h in headers):
            continue

        for tr in rows[1:]:
            cells = [td.get_text(strip=True) for td in tr.find_all(['td', 'th'])]
            if len(cells) < 4:
                continue

            # Standard move row extraction
            move_name = cells[0] if len(cells) > 0 else ''
            startup = cells[1] if len(cells) > 1 else '-'
            active = cells[2] if len(cells) > 2 else '-'
            recovery = cells[3] if len(cells) > 3 else '-'
            on_block = cells[4] if len(cells) > 4 else '-'
            on_hit = cells[5] if len(cells) > 5 else '-'
            damage = 0
            if len(cells) > 6:
                d_match = re.search(r'\d+', cells[6])
                if d_match:
                    damage = int(d_match.group(0))

            m_type = 'normal'
            if 'sa1' in move_name.lower() or 'sa2' in move_name.lower() or 'sa3' in move_name.lower() or 'ca' in move_name.lower():
                m_type = 'superArt'
            elif any(k in move_name.lower() for k in ['236', '214', '623', '421', '22', '41236', '63214']):
                m_type = 'special'
            elif any(k in move_name.lower() for k in ['6mp', '6hp', '4hp', '6hk', '4hk', '3hk', '3hp', 'tc']):
                m_type = 'unique'

            moves.append({
                'name': move_name,
                'command': move_name,
                'type': m_type,
                'damage': damage,
                'startup': clean(startup),
                'active': clean(active),
                'recovery': clean(recovery),
                'onBlock': clean(on_block),
                'onHit': clean(on_hit),
                'isCancelable': False,
                'notes': '',
                'variations': []
            })

    return moves

def main():
    if not os.path.exists(RAW_DIR):
        print(f"RAW_DIR {RAW_DIR} does not exist.")
        return

    html_files = [f for f in os.listdir(RAW_DIR) if f.endswith('.html')]
    print(f"Found {len(html_files)} raw HTML files in {RAW_DIR}")

    all_data = {}
    if os.path.exists(OUT_FILE):
        try:
            with open(OUT_FILE, 'r', encoding='utf-8') as f:
                all_data = json.load(f)
        except Exception:
            all_data = {}

    updated = 0
    for hf in html_files:
        char_id = hf.replace('.html', '').lower()
        filepath = os.path.join(RAW_DIR, hf)
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        moves = parse_html_character(char_id, content)
        if moves:
            all_data[char_id] = moves
            updated += 1
            print(f"  Parsed {len(moves)} moves for {char_id}")

    with open(OUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(all_data, f, ensure_ascii=False, indent=2)

    print(f"Updated {updated} characters in {OUT_FILE}")

if __name__ == '__main__':
    main()
