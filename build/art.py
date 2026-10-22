import numpy as np
from PIL import Image, ImageFont, ImageDraw
O='/Users/dellgod/idu-house/clients/octavia-the-great/merch/assets/originals/'
P='/Users/dellgod/idu-house/clients/octavia-the-great/merch/assets/prepped/'
GOLD=(212,166,74); CREAM=(250,243,230); BLACK=(10,10,10); RED=(214,38,31)

def recolor(im,rgb):
    a=np.array(im.convert('RGBA')); a[...,:3]=rgb; return Image.fromarray(a)
def trim(im,pad=0):
    bb=im.getchannel('A').point(lambda v:255 if v>8 else 0).getbbox()
    im=im.crop(bb)
    if pad:
        c=Image.new('RGBA',(im.width+2*pad,im.height+2*pad),(0,0,0,0)); c.paste(im,(pad,pad)); im=c
    return im

# chant black/gold: key out near-black background by luminance
sheet=Image.open(O+'confidence_chant_back_final_no_underline.png').convert('RGB')
sheet_u=Image.open(O+'confidence_chant_back_final.png').convert('RGB')
def key_dark(panel):
    a=np.array(panel).astype(float); m=a.max(axis=2); alpha=np.clip((m-14)/(90),0,1)
    out=np.zeros(a.shape[:2]+(4,)); 
    with np.errstate(divide='ignore',invalid='ignore'):
        rgb=np.where(alpha[...,None]>0,a/np.maximum(alpha[...,None],1e-3),0)
    out[...,:3]=np.clip(rgb,0,255); out[...,3]=alpha*255
    return Image.fromarray(out.astype('uint8'),'RGBA')
def key_color(panel,bg):
    a=np.array(panel).astype(float); d=np.sqrt(((a-np.array(bg))**2).sum(axis=2)); alpha=np.clip(d/110,0,1)
    out=np.zeros(a.shape[:2]+(4,))
    rgb=(a-(1-alpha[...,None])*np.array(bg))/np.maximum(alpha[...,None],1e-3)
    out[...,:3]=np.clip(rgb,0,255); out[...,3]=alpha*255
    return Image.fromarray(out.astype('uint8'),'RGBA')
W,H=sheet.size; half=W//2; top=int(H*0.092)
for name,s in (('chant_nounderline',sheet),('chant_underline',sheet_u)):
    bg=s.crop((0,top,half,H)); pk=s.crop((half,top,W,H))
    trim(key_dark(bg),20).save(P+f'{name}_blackgold.png')
    pinkbg=tuple(int(v) for v in np.array(pk)[5,5])
    trim(key_color(pk,pinkbg),20).save(P+f'{name}_pinksilver.png')
    print(name,'pink bg',pinkbg)

# crown from nape alt
full=trim(Image.open(O+'hoodie_back_print_ready_minimal_nape_alt.png').convert('RGBA'))
rows=(np.array(full.getchannel('A'))>8).any(axis=1)
gap=next(i for i in range(5,len(rows)) if not rows[i])
crown=trim(full.crop((0,0,full.width,gap)))
wordmark=trim(full.crop((0,gap,full.width,full.height)))
full.save(P+'crown_with_wordmark_original.png'); wordmark.save(P+'wordmark_original.png'); crown.save(P+'crown_gold_original.png'); print('crown',crown.size,'wordmark',wordmark.size)
for n,c in (('gold',GOLD),('black',BLACK),('cream',CREAM),('red',RED)):
    recolor(crown,c).save(P+f'crown_{n}.png')

# mantra script recolors (vinyl cutfile is black on transparent)
for key in ('caveatbrush_alt','pacifico'):
    im=trim(Image.open(O+f'be_confident_vinyl_cutfile_{key}.png').convert('RGBA'),10)
    for n,c in (('cream',CREAM),('gold',GOLD),('black',BLACK)):
        recolor(im,c).save(P+f'mantra_{key}_{n}.png')

# dear person behind me, trim
dp=trim(Image.open(O+'hoodie_back_print_ready_letter_quote1.png').convert('RGBA'),10); dp.save(P+'dear_person_behind_me.png'); print('dp',dp.size)

# kanji lockups
def kanji(ch,fontpath,size,color):
    f=ImageFont.truetype(fontpath,size,index=0)
    im=Image.new('RGBA',(size*2,size*2),(0,0,0,0)); d=ImageDraw.Draw(im); d.text((size//2,size//2),ch,font=f,fill=color+(255,))
    return trim(im)
FONTS={'gothic':'/System/Library/Fonts/ヒラギノ角ゴシック W7.ttc','mincho':'/System/Library/Fonts/ヒラギノ明朝 ProN.ttc'}
for fn,fp in FONTS.items():
    for n,c in (('gold',GOLD),('black',BLACK),('cream',CREAM),('red',RED)):
        k=kanji('大',fp,1800,c); k.save(P+f'dai_{fn}_{n}.png')
        cr=recolor(crown,c); cw=int(k.width*0.46); cr=cr.resize((cw,int(cw*crown.height/crown.width)),Image.LANCZOS)
        gap=int(k.height*0.07); L=Image.new('RGBA',(k.width+80,cr.height+gap+k.height+40),(0,0,0,0))
        L.paste(cr,((L.width-cw)//2,20),cr); L.paste(k,(40,20+cr.height+gap),k); trim(L,30).save(P+f'lockup_{fn}_{n}.png')
print('done')
