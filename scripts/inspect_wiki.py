import sys
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    b = p.chromium.connect_over_cdp('http://127.0.0.1:9222')
    pages = b.contexts[0].pages
    for page in pages:
        if 'Jamie' in page.title():
            # Get move names and frame data
            data = page.evaluate("""() => {
                const results = [];
                // Look for move data blocks
                const moves = document.querySelectorAll('div[data-move-id], .move-card, table.wikitable');
                moves.forEach(m => {
                    if (m.tagName === 'TABLE') {
                        const caption = m.querySelector('caption')?.innerText || '';
                        const headers = Array.from(m.querySelectorAll('th')).map(th => th.innerText.trim());
                        results.push({ tag: 'table', caption, headers: headers.slice(0, 10) });
                    }
                });
                return results;
            }""")
            print("Extracted:", data[:10])
