from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    b = p.chromium.connect_over_cdp('http://127.0.0.1:9222')
    page = b.contexts[0].pages[0]
    print("Page title:", page.title())
    links = page.eval_on_selector_all(
        "a[href*='/w/Street_Fighter_6/']",
        """elements => {
            return elements.map(e => ({
                text: e.innerText.trim(),
                href: e.getAttribute('href')
            })).filter(e => e.text && !e.href.includes('#') && !e.href.includes('?') && !e.href.includes('/Combos'));
        }"""
    )
    seen = set()
    for l in links:
        h = l['href']
        if h not in seen:
            seen.add(h)
            print(f"{l['text']:15} -> {h}")
