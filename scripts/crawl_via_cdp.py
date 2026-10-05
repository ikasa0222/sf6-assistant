# Script to crawl Supercombo SF6 Wiki by connecting to user's running browser via CDP
# Usage:
# 1. Close all Edge windows, then run in terminal:
#    & "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --remote-debugging-port=9222 "https://wiki.supercombo.gg/w/Street_Fighter_6"
# 2. Run: python scripts/crawl_via_cdp.py

import sys
import os
import json
import time
import re
from playwright.sync_api import sync_playwright

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'assets', 'data')
OUTPUT_FILE = os.path.join(OUTPUT_DIR, 'sf6_wiki_framedata.json')

def main():
    print("Connecting to browser on http://127.0.0.1:9222...")
    with sync_playwright() as p:
        try:
            browser = p.chromium.connect_over_cdp("http://127.0.0.1:9222")
        except Exception as e:
            print(f"ERROR: Cannot connect to 127.0.0.1:9222. Error: {e}")
            print("Please make sure you started Edge with --remote-debugging-port=9222!")
            sys.exit(1)

        contexts = browser.contexts
        if not contexts:
            print("No browser context found!")
            sys.exit(1)

        page = contexts[0].pages[0] if contexts[0].pages else contexts[0].new_page()
        print(f"Connected! Current page URL: {page.url}, Title: {page.title()}")

        # Ensure we are on Street_Fighter_6 page
        if 'Street_Fighter_6' not in page.url:
            print("Navigating to https://wiki.supercombo.gg/w/Street_Fighter_6 ...")
            page.goto("https://wiki.supercombo.gg/w/Street_Fighter_6", timeout=30000)
            page.wait_for_timeout(3000)

        # Extract character links from the roster grid
        print("Extracting character roster from Supercombo Wiki...")
        links = page.eval_on_selector_all(
            "a[href*='/w/Street_Fighter_6/']",
            """elements => {
                const results = [];
                for (const el of elements) {
                    const href = el.getAttribute('href');
                    const text = el.innerText.trim();
                    if (href && !href.includes('/Combos') && !href.includes('/Strategy') && !href.includes('/Resources') && !href.includes('#')) {
                        const match = href.match(/\\/w\\/Street_Fighter_6\\/([^/?#]+)/);
                        if (match && match[1] && !['FAQ', 'Mechanics', 'Controls', 'Systems', 'Gauges', 'Offense', 'Defense', 'Movement'].includes(match[1])) {
                            results.push({ name: match[1], url: 'https://wiki.supercombo.gg' + href, text: text });
                        }
                    }
                }
                return results;
            }"""
        )

        seen = set()
        roster = []
        for item in links:
            slug = item['name']
            if slug not in seen:
                seen.add(slug)
                roster.append(item)

        print(f"Found {len(roster)} characters on Supercombo Wiki:")
        for r in roster:
            print(f" - {r['name']} ({r['text']}) -> {r['url']}")

        os.makedirs(OUTPUT_DIR, exist_ok=True)
        all_char_data = {}

        for idx, char_info in enumerate(roster):
            slug = char_info['name']
            url = char_info['url']
            print(f"\n[{idx+1}/{len(roster)}] Scraping {slug} from {url} ...")

            try:
                page.goto(url, timeout=30000)
                page.wait_for_timeout(2500)

                # Extract all tables or move cards
                # On Supercombo, move data is in table.wikitable or .move-card or data tables
                char_data = page.evaluate("""() => {
                    const data = {
                        character: document.title,
                        tables: []
                    };
                    const tables = document.querySelectorAll('table.wikitable');
                    tables.forEach((t, tIndex) => {
                        const rows = [];
                        t.querySelectorAll('tr').forEach(tr => {
                            const cells = [];
                            tr.querySelectorAll('th, td').forEach(cell => {
                                cells.push(cell.innerText.trim());
                            });
                            if (cells.length > 0) rows.push(cells);
                        });
                        if (rows.length > 0) {
                            data.tables.push({ index: tIndex, rows: rows });
                        }
                    });
                    return data;
                }""")

                all_char_data[slug] = char_data
                print(f"  -> Extracted {len(char_data['tables'])} tables for {slug}")
            except Exception as ex:
                print(f"  -> Failed to scrape {slug}: {ex}")

        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            json.dump(all_char_data, f, ensure_ascii=False, indent=2)

        print(f"\nSUCCESS: Scraped {len(all_char_data)} characters into {OUTPUT_FILE}")

if __name__ == '__main__':
    main()
