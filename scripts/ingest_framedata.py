# -*- coding: utf-8 -*-
import urllib.request
import json
import re
import os

FAT_URL = 'https://fullmeter.com/fatfiles/release/SF6/FrameData/SF6FrameData.json'
OUT_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'assets', 'data', 'sf6_framedata.json')

CHAR_MAP = {
    'A.K.I.': 'aki',
    'Akuma': 'akuma',
    'Alex': 'alex',
    'Blanka': 'blanka',
    'C.Viper': 'cviper',
    'Cammy': 'cammy',
    'Chun-Li': 'chunli',
    'Dee Jay': 'deejay',
    'Dhalsim': 'dhalsim',
    'E.Honda': 'ehonda',
    'Ed': 'ed',
    'Elena': 'elena',
    'Guile': 'guile',
    'Ingrid': 'ingrid',
    'Jamie': 'jamie',
    'JP': 'jp',
    'Juri': 'juri',
    'Ken': 'ken',
    'Kimberly': 'kimberly',
    'Lily': 'lily',
    'Luke': 'luke',
    'M.Bison': 'bison',
    'Mai': 'mai',
    'Manon': 'manon',
    'Marisa': 'marisa',
    'Rashid': 'rashid',
    'Ryu': 'ryu',
    'Sagat': 'sagat',
    'Terry': 'terry',
    'Yasmine': 'yasmine',
    'Zangief': 'zangief',
}

# Chinese translation dictionary using Unicode escape sequences
TRANSLATIONS = {
    'Stand LP': '\u7ad9\u8f7b\u62f3 (5LP)',
    'Stand MP': '\u7ad9\u4e2d\u62f3 (5MP)',
    'Stand HP': '\u7ad9\u91cd\u62f3 (5HP)',
    'Stand LK': '\u7ad9\u8f7b\u811a (5LK)',
    'Stand MK': '\u7ad9\u4e2d\u811a (5MK)',
    'Stand HK': '\u7ad9\u91cd\u811a (5HK)',
    'Crouch LP': '\u8e72\u8f7b\u62f3 (2LP)',
    'Crouch MP': '\u8e72\u4e2d\u62f3 (2MP)',
    'Crouch HP': '\u8e72\u91cd\u62f3 (2HP)',
    'Crouch LK': '\u8e72\u8f7b\u811a (2LK)',
    'Crouch MK': '\u8e72\u4e2d\u811a (2MK)',
    'Crouch HK': '\u8e72\u91cd\u811a (2HK)',
    'Jump LP': '\u8df3\u8f7b\u62f3 (j.LP)',
    'Jump MP': '\u8df3\u4e2d\u62f3 (j.MP)',
    'Jump HP': '\u8df3\u91cd\u62f3 (j.HP)',
    'Jump LK': '\u8df3\u8f7b\u811a (j.LK)',
    'Jump MK': '\u8df3\u4e2d\u811a (j.MK)',
    'Jump HK': '\u8df3\u91cd\u811a (j.HK)',
    'Drive Impact': '\u6597\u6c14\u8ff8\u53d1 (Drive Impact)',
    'Drive Parry': '\u6597\u6c14\u62db\u67b6 (Drive Parry)',
    'Drive Rush': '\u6597\u6c14\u51b2\u523a (Drive Rush)',
    'Drive Reversal': '\u6597\u6c14\u53cd\u51fb (Drive Reversal)',
    'Shoulder Throw': '\u524d\u666e\u901a\u6295',
    'Somersault Throw': '\u540e\u666e\u901a\u6295',
    'Hadoken': '\u6ce2\u52a8\u62f3',
    'Shoryuken': '\u5347\u9f99\u62f3',
    'Tatsumaki Senpukyaku': '\u9f99\u5377\u65cb\u98ce\u811a',
    'High Blade Kick': '\u4e0a\u5203\u8fde\u811a',
    'Hashogeki': '\u6ce2\u638c\u51fb',
    'Denjin Charge': '\u7535\u5203\u70bc\u6c14',
    'Shinku Hadoken': 'SA1: \u771f\u7a7a\u6ce2\u52a8\u62f3',
    'Shin Hashogeki': 'SA2: \u771f\u00b7\u6ce2\u638c\u51fb',
    'Shin Shoryuken': 'SA3: \u771f\u00b7\u5347\u9f99\u62f3',
    'Shin Shoryuken (Critical Art)': 'CA: \u771f\u00b7\u5347\u9f99\u62f3',
    'Tiger Shot': '\u731b\u864e\u6ce2 (\u9ad8\u6bb5)',
    'Low Tiger Shot': '\u731b\u864e\u6ce2 (\u4f4e\u6bb5)',
    'High Tiger Shot': '\u731b\u864e\u6ce2 (\u9ad8\u6bb5)',
    'Tiger Uppercut': '\u731b\u864e\u5347\u9f99\u7834',
    'Tiger Knee Crush': '\u731b\u864e\u5347\u819d',
    'Tiger Cannon': 'SA1: \u731b\u864e\u52a0\u518c',
    'Tiger Rampage': 'SA2: \u731b\u864e\u72c2\u66b4',
    'Tiger Vanquish': 'SA3: \u731b\u864e\u5f81\u670d',
    'Spiral Arrow': '\u87ba\u65cb\u7bad',
    'Cannon Spike': '\u52a0\u518c\u9489',
    'Cannon Strike': '\u52a0\u518c\u4e0b\u843d',
    'Hooligan Combination': '\u6d41\u6c13\u7ec4\u5408',
    'Spinning Bird Kick': '\u65cb\u98ce\u811a',
    'Kikoken': '\u6c14\u529f\u62f3',
    'Lightning Legs': '\u767e\u88c2\u811a',
    'Hazanshu': '\u9738\u5c71\u8e74',
    'Sonic Boom': '\u97f3\u901f\u624b\u5200',
    'Flash Kick': '\u5012\u52fe\u8e22 (\u811a\u5200)',
    'Sand Blaster': '\u6c99\u5f39',
    'Flash Knuckle': '\u95ea\u7535\u91cd\u62f3',
    'Rising Uppercut': '\u5347\u9f99\u91cd\u62f3',
    'Double Lariat': '\u53cc\u91cd\u65cb\u8f6c\u91d1\u81c2\u52fe',
    'Screw Pile Driver': '\u87ba\u65cb\u6253\u6869 (SPD)',
    'Gohadoken': '\u8c6a\u6ce2\u52a8\u62f3',
    'Goshoryuken': '\u8c6a\u5347\u9f99\u62f3',
    'Tatsumaki Zankukyaku': '\u9f99\u5377\u65a9\u7a7a\u811a',
    'Ashura Senku': '\u963f\u4fee\u7f57\u95ea\u7a7a',
    'Hyakkishu': '\u767e\u9b3c\u88ad',
}

def clean_val(val, default='-'):
    if val is None:
        return default
    if isinstance(val, (int, float)):
        return str(val)
    s = str(val).strip()
    return s if s else default

def parse_variation_type(move_name):
    """Determine version prefix: L, M, H, OD, etc."""
    m = move_name.strip()
    if m.startswith('OD '):
        return 'OD (\u5f3a\u5316)', m[3:].strip()
    if m.startswith('LP ') or m.startswith('LK '):
        return 'L (\u8f7b)', m[3:].strip()
    if m.startswith('MP ') or m.startswith('MK '):
        return 'M (\u4e2d)', m[3:].strip()
    if m.startswith('HP ') or m.startswith('HK '):
        return 'H (\u91cd)', m[3:].strip()
    return None, m

def main():
    print(f"Fetching FAT database from {FAT_URL} ...")
    req = urllib.request.Request(FAT_URL, headers={'User-Agent': 'Mozilla/5.0'})
    content = urllib.request.urlopen(req, timeout=20).read()
    raw = json.loads(content.decode('utf-8'))
    print(f"Fetched {len(raw)} characters.")

    all_data = {}

    for fat_name, char_id in CHAR_MAP.items():
        if fat_name not in raw:
            print(f"Warning: {fat_name} not found in FAT!")
            continue

        char_raw = raw[fat_name]
        raw_moves = char_raw.get('moves', {}).get('normal', {})

        # Group moves by base move name
        specials_by_base = {}
        standalone_moves = []

        for raw_name, m in raw_moves.items():
            m_type = m.get('moveType', 'normal')
            var_type, base_name = parse_variation_type(raw_name)

            if m_type == 'special' and var_type:
                if base_name not in specials_by_base:
                    specials_by_base[base_name] = []
                specials_by_base[base_name].append((var_type, raw_name, m))
            else:
                standalone_moves.append((raw_name, m))

        processed_moves = []

        # Process standalone moves (normals, uniques, supers, throws, standalone specials)
        for raw_name, m in standalone_moves:
            m_type = m.get('moveType', 'normal')
            t_str = 'normal'
            if m_type == 'super':
                t_str = 'superArt'
            elif m_type == 'special':
                t_str = 'special'
            elif m_type == 'command':
                t_str = 'unique'
            elif 'throw' in raw_name.lower():
                t_str = 'throwTech'
            elif 'drive' in raw_name.lower():
                t_str = 'driveAction'

            dmg = m.get('dmg', 0)
            if isinstance(dmg, str):
                nums = re.findall(r'\d+', dmg)
                dmg_val = int(nums[0]) if nums else 0
            else:
                dmg_val = int(dmg) if dmg else 0

            # Notes / extra info
            extra = m.get('extraInfo', [])
            notes_str = '; '.join(extra) if isinstance(extra, list) else str(extra)

            processed_moves.append({
                'name': TRANSLATIONS.get(raw_name, raw_name),
                'command': clean_val(m.get('numCmd') or m.get('plnCmd')),
                'type': t_str,
                'damage': dmg_val,
                'startup': clean_val(m.get('startup')),
                'active': clean_val(m.get('active')),
                'recovery': clean_val(m.get('recovery')),
                'onBlock': clean_val(m.get('onBlock')),
                'onHit': clean_val(m.get('onHit')),
                'driveGaugeDamage': clean_val(m.get('DDoH'), '0'),
                'driveGaugeRecovery': clean_val(m.get('DGain'), '0'),
                'isCancelable': bool(m.get('xx')),
                'notes': notes_str,
                'variations': [],
            })

        # Process grouped specials with true variations
        for base_name, var_list in specials_by_base.items():
            order = {'L (\u8f7b)': 1, 'M (\u4e2d)': 2, 'H (\u91cd)': 3, 'OD (\u5f3a\u5316)': 4}
            sorted_vars = sorted(var_list, key=lambda x: order.get(x[0], 99))

            default_m = sorted_vars[0][2]
            for v_name, r_name, m_data in sorted_vars:
                if 'M' in v_name or '\u4e2d' in v_name:
                    default_m = m_data
                    break

            variations = []
            for v_name, r_name, m_data in sorted_vars:
                v_dmg = m_data.get('dmg', 0)
                if isinstance(v_dmg, str):
                    nums = re.findall(r'\d+', v_dmg)
                    v_dmg_val = int(nums[0]) if nums else 0
                else:
                    v_dmg_val = int(v_dmg) if v_dmg else 0

                v_extra = m_data.get('extraInfo', [])
                v_notes = '; '.join(v_extra) if isinstance(v_extra, list) else str(v_extra)

                v_inv = ''
                for note in (v_extra if isinstance(v_extra, list) else [str(v_extra)]):
                    if 'invincible' in note.lower() or 'armor' in note.lower() or 'airborne strikes' in note.lower():
                        v_inv = note
                        break

                variations.append({
                    'version': v_name,
                    'startup': clean_val(m_data.get('startup')),
                    'active': clean_val(m_data.get('active')),
                    'recovery': clean_val(m_data.get('recovery')),
                    'onBlock': clean_val(m_data.get('onBlock')),
                    'onHit': clean_val(m_data.get('onHit')),
                    'damage': v_dmg_val,
                    'invincible': v_inv,
                    'notes': v_notes,
                })

            base_dmg = default_m.get('dmg', 0)
            if isinstance(base_dmg, str):
                nums = re.findall(r'\d+', base_dmg)
                base_dmg_val = int(nums[0]) if nums else 0
            else:
                base_dmg_val = int(base_dmg) if base_dmg else 0

            cmd = clean_val(default_m.get('numCmd') or default_m.get('plnCmd'))
            generic_cmd = re.sub(r'(LP|MP|HP|PP)$', 'P', cmd)
            generic_cmd = re.sub(r'(LK|MK|HK|KK)$', 'K', generic_cmd)

            zh_name = TRANSLATIONS.get(base_name, base_name)

            processed_moves.append({
                'name': zh_name,
                'command': generic_cmd,
                'type': 'special',
                'damage': base_dmg_val,
                'startup': clean_val(default_m.get('startup')),
                'active': clean_val(default_m.get('active')),
                'recovery': clean_val(default_m.get('recovery')),
                'onBlock': clean_val(default_m.get('onBlock')),
                'onHit': clean_val(default_m.get('onHit')),
                'driveGaugeDamage': clean_val(default_m.get('DDoH'), '0'),
                'driveGaugeRecovery': clean_val(default_m.get('DGain'), '0'),
                'isCancelable': bool(default_m.get('xx')),
                'notes': '; '.join(default_m.get('extraInfo', [])) if isinstance(default_m.get('extraInfo'), list) else str(default_m.get('extraInfo', '')),
                'variations': variations,
            })

        all_data[char_id] = processed_moves
        print(f"[{char_id}] Processed {len(processed_moves)} moves ({len(specials_by_base)} grouped specials with true variations)")

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    with open(OUT_PATH, 'w', encoding='utf-8') as f:
        json.dump(all_data, f, ensure_ascii=False, indent=2)

    print(f"\nSUCCESS: Generated {OUT_PATH} covering {len(all_data)} characters!")

if __name__ == '__main__':
    main()
