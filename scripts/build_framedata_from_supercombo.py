# -*- coding: utf-8 -*-
import json
import os
import re

DATA_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'assets', 'data')
INPUT_FILE = os.path.join(DATA_DIR, 'supercombo_all_tables.json')
OUTPUT_FILE = os.path.join(DATA_DIR, 'sf6_framedata.json')

# Chinese translation dictionary for common move names
ZH_NORMALS = {
    '5LP': '站立轻拳 (5LP)',
    '5MP': '站立中拳 (5MP)',
    '5HP': '站立重拳 (5HP)',
    '5LK': '站立轻脚 (5LK)',
    '5MK': '站立中脚 (5MK)',
    '5HK': '站立重脚 (5HK)',
    '2LP': '蹲下轻拳 (2LP)',
    '2MP': '蹲下中拳 (2MP)',
    '2HP': '蹲下重拳 (2HP)',
    '2LK': '蹲下轻脚 (2LK)',
    '2MK': '蹲下中脚 (2MK)',
    '2HK': '蹲下重脚 (2HK)',
    '8LP': '垂直跳跃轻拳 (8LP)',
    '8MP': '垂直跳跃中拳 (8MP)',
    '8HP': '垂直跳跃重拳 (8HP)',
    '8LK': '垂直跳跃轻脚 (8LK)',
    '8MK': '垂直跳跃中脚 (8MK)',
    '8HK': '垂直跳跃重脚 (8HK)',
    '9LP': '前跳轻拳 (j.LP)',
    '9MP': '前跳中拳 (j.MP)',
    '9HP': '前跳重拳 (j.HP)',
    '9LK': '前跳轻脚 (j.LK)',
    '9MK': '前跳中脚 (j.MK)',
    '9HK': '前跳重脚 (j.HK)',
    'j.LP': '跳跃轻拳 (j.LP)',
    'j.MP': '跳跃中拳 (j.MP)',
    'j.HP': '跳跃重拳 (j.HP)',
    'j.LK': '跳跃轻脚 (j.LK)',
    'j.MK': '跳跃中脚 (j.MK)',
    'j.HK': '跳跃重脚 (j.HK)',
}

def clean_val(v, default='-'):
    if v is None:
        return default
    s = str(v).strip()
    return s if s else default

def parse_character_tables(char_id, tables):
    moves = []

    for t in tables:
        if len(t) < 7:
            continue

        # Check if table has move identifier
        id_cell = t[0][0] if len(t[0]) > 0 else ''
        if not id_cell or '\n' not in id_cell:
            continue

        # Header with command and name
        cmd_header = t[1][0] if len(t[1]) > 0 else ''
        parts = cmd_header.split('\n\n')
        input_cmd = parts[0].split('\xa0')[0].strip() if parts else ''
        en_name = parts[1].strip() if len(parts) > 1 else input_cmd

        # Parse stats
        damage = 0
        cancel_str = ''
        startup = '-'
        active = '-'
        recovery = '-'
        on_block = '-'
        on_hit = '-'
        invincible = ''
        notes = ''

        for r_idx, row in enumerate(t):
            if 'Damage' in row:
                d_idx = row.index('Damage')
                if r_idx + 1 < len(t) and d_idx < len(t[r_idx + 1]):
                    dmg_str = t[r_idx + 1][d_idx]
                    match = re.search(r'\d+', dmg_str)
                    if match:
                        damage = int(match.group(0))
            if 'Cancel' in row:
                c_idx = row.index('Cancel')
                if r_idx + 1 < len(t) and c_idx < len(t[r_idx + 1]):
                    cancel_str = t[r_idx + 1][c_idx]

            if 'Startup' in row:
                st_idx = row.index('Startup')
                if r_idx + 1 < len(t) and st_idx < len(t[r_idx + 1]):
                    startup = clean_val(t[r_idx + 1][st_idx])
            if 'Active' in row:
                ac_idx = row.index('Active')
                if r_idx + 1 < len(t) and ac_idx < len(t[r_idx + 1]):
                    active = clean_val(t[r_idx + 1][ac_idx])
            if 'Recovery' in row:
                rec_idx = row.index('Recovery')
                if r_idx + 1 < len(t) and rec_idx < len(t[r_idx + 1]):
                    recovery = clean_val(t[r_idx + 1][rec_idx])

            if 'Block Advantage' in row:
                blk_idx = row.index('Block Advantage')
                if r_idx + 1 < len(t) and blk_idx < len(t[r_idx + 1]):
                    on_block = clean_val(t[r_idx + 1][blk_idx])
            if 'Hit Advantage' in row:
                hit_idx = row.index('Hit Advantage')
                if r_idx + 1 < len(t) and hit_idx < len(t[r_idx + 1]):
                    on_hit = clean_val(t[r_idx + 1][hit_idx])

            if 'Invuln' in row:
                inv_idx = row.index('Invuln')
                if r_idx + 1 < len(t) and inv_idx < len(t[r_idx + 1]):
                    inv = clean_val(t[r_idx + 1][inv_idx])
                    if inv != '-':
                        invincible = inv

            if 'Notes' in row:
                n_idx = row.index('Notes')
                if r_idx + 1 < len(t) and n_idx < len(t[r_idx + 1]):
                    notes = clean_val(t[r_idx + 1][n_idx], '')

        # Classify MoveType
        # Clean command
        clean_cmd = input_cmd.replace(' ', '')
        m_type = 'normal'
        name_zh = ZH_NORMALS.get(clean_cmd, en_name)

        if any(sa in clean_cmd.lower() for sa in ['236236', '214214', 'sa1', 'sa2', 'sa3', 'ca']):
            m_type = 'superArt'
            if '236236' in clean_cmd or '214214' in clean_cmd:
                name_zh = f"SA: {en_name}"
        elif any(c in clean_cmd for c in ['236', '214', '623', '421', '22', '41236', '63214', '4蓄6', '2蓄8', '[4]6', '[2]8']):
            m_type = 'special'
        elif any(tc in clean_cmd for tc in ['>', '~', '6HP', '6MP', '4HP', '4MP', '6HK', '6MK', '4HK', '3HK', '3HP']):
            m_type = 'unique'
        elif 'throw' in en_name.lower() or 'lp+lk' in clean_cmd.lower():
            m_type = 'throwTech'
        elif 'drive' in en_name.lower():
            m_type = 'driveAction'

        is_cancelable = bool(cancel_str and cancel_str != '-' and cancel_str != '')

        moves.append({
            'name': name_zh,
            'command': clean_cmd,
            'type': m_type,
            'damage': damage,
            'startup': startup,
            'active': active,
            'recovery': recovery,
            'onBlock': on_block,
            'onHit': on_hit,
            'driveGaugeDamage': '0',
            'driveGaugeRecovery': '0',
            'isCancelable': is_cancelable,
            'notes': notes if notes != '-' else '',
            'variations': []
        })

    return moves

def main():
    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    all_framedata = {}
    total_moves = 0

    for char_id, char_info in data.items():
        tables = char_info.get('tables', [])
        moves = parse_character_tables(char_id, tables)
        all_framedata[char_id] = moves
        total_moves += len(moves)
        normals = [m for m in moves if m['type'] == 'normal']
        specials = [m for m in moves if m['type'] == 'special']
        supers = [m for m in moves if m['type'] == 'superArt']
        uniques = [m for m in moves if m['type'] == 'unique']
        print(f"{char_id:10s} | Total: {len(moves):2d} | Normals: {len(normals):2d} | Specials: {len(specials):2d} | Supers: {len(supers):2d} | Uniques: {len(uniques):2d}")

    with open(OUTPUT_FILE, 'w', encoding='utf-8') as out_f:
        json.dump(all_framedata, out_f, ensure_ascii=False, indent=2)

    print(f"\n[SUCCESS] Successfully parsed {len(all_framedata)} characters ({total_moves} moves) into {OUTPUT_FILE}!")

if __name__ == '__main__':
    main()
