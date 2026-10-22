import subprocess, sys
CH='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
B='/Users/dellgod/idu-house/clients/octavia-the-great/merch/'
names=sys.argv[1:] or ['hoodie-black','hoodie-pink','tee-cream','tee-black','mug','sticker','details']
for n in names:
    out=f'{B}mockups/{n}.png'
    subprocess.run([CH,'--headless=new','--user-data-dir=/Users/dellgod/idu-house/clients/octavia-the-great/merch/build/.chrome-profile','--no-first-run','--disable-gpu','--hide-scrollbars','--allow-file-access-from-files',
        '--window-size=1600,1200','--virtual-time-budget=4000',f'--screenshot={out}',f'file://{B}build/mock.html#{n}'],
        stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,timeout=120)
    print(n)
