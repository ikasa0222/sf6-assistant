from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    b = p.chromium.connect_over_cdp('http://127.0.0.1:9222')
    page = b.contexts[0].pages[0]
    print("Navigating with wait_until='domcontentloaded' ...")
    try:
        page.goto("https://wiki.supercombo.gg/w/Street_Fighter_6/Arjun/Data", wait_until="domcontentloaded", timeout=60000)
    except Exception as e:
        print("Goto notice:", e)

    page.wait_for_timeout(3000)
    print("Current Page Title:", page.title())
    print("Current Page URL:", page.url)

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
    print(f"Extracted {len(tables)} tables!")
    for idx, t in enumerate(tables):
        print(f"\n--- Table {idx+1} ({len(t)} rows) ---")
        for r in t[:8]:
            print("  ", r)
