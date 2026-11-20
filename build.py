"""Makes index.html from page.html (the same page that runs on Claude), adding the bits a normal web page needs.
Run: python3 build.py   Run it after you change page.html."""
import pathlib
here = pathlib.Path(__file__).resolve().parent
src = (here / 'page.html').read_text()
head = ('<!doctype html>\n<html lang="en"><head><meta charset="utf-8">'
        '<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">'
        '<script src="config.js"></script></head><body>\n')
(here / 'index.html').write_text(head + src + '\n</body></html>\n')
print('wrote', here / 'index.html')
