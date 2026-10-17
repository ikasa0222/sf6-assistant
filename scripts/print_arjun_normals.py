from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    b = p.chromium.connect_over_cdp('http://127.0.0.1:9222')
    page = b.contexts[0].pages[0]
    tables = page.eval_on_selector_all(
        "table.wikitable",
        """tables => {
            return tables.slice(0, 16).map(t => {
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
    for idx, t in enumerate(tables):
        header = t[1][0].split('\n')[0] if len(t) > 1 and len(t[1]) > 0 else 'Unknown'
        print(f"=== Move {idx+1}: {header} ===")
        for r in t[3:8]:
            print("  ", r)
