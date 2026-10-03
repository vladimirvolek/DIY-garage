# Nasazovací rant a větší spodní sítko

Tiskové soubory pro tuto dvojici:

- `sprouting-lid-H20-mesh-1.8.stl`: zesílené víčko se závitem H20,
  spodní dírky 1,8 mm místo 1,6 mm; čepička komínu má stále 1,6 mm.
- `watering-rim.stl`: samostatný 8mm rant s pružnou nasazovací objímkou.

Oba soubory tiskni v exportované orientaci, měřítko 100 %, vrstva 0,2 mm,
bez podpor. U rantu je širší otvor s rozříznutou objímkou nahoře.
Celková výška dílu je 14 mm (8 mm nálevka + 6 mm objímka).

Rant nasuň z vnější strany víčka přes jeho obvod, až vnitřní osazení
lehce dosedne na plochu kolem sítka. Rozříznutá objímka má malé přítlačné
výstupky; jejich držení závisí na materiálu a přesnosti tisku. Nepáčit silou.
Rant je odnímatelný kvůli mytí, nemá těsnění a není vodotěsná nádržka.
Voda odtéká sítem a může prosakovat spojem.

Objímka je navržená pro zesílené víčko o průměru 90,5 mm přes vroubky.
Vnitřek objímky má 90,9 mm, v místě výstupků 90,3 mm.
Na původním tenčím víčku o průměru 88,9 mm bude volná.
Otvor nálevky 86 mm nechává dírky volné a osazení se opírá o vnější plný okraj.

V `watering-rim.scad` lze ladit `fit_clearance_d` (větší = volnější),
`retention` (větší = silnější sevření), případně `lid_wall` pro jiné víčko.
Jde o první neodzkoušenou tiskovou vůli. Geometrie obou STL je ověřená jako
jeden uzavřený objem, ale nasazení na skutečný výtisk je potřeba vyzkoušet.
Uživatel potvrdil, že testovací kroužek H20 na sklenici sedí. Finální víčko
používá stejnou kontaktní geometrii závitu, se zesílením směrem ven.

Zdroj víčka se nyní otevírá v režimu celého víčka H20. Celé víčko exportuj:

```sh
openscad -o sprouting-lid-H20-mesh-1.8.stl -D 'part="lid"' -D 'thread_style="helical"' -D 'thread_lead=20.30' sprouting-lid.scad
openscad -o watering-rim.stl watering-rim.scad
```

Starší STL/3MF větší dírky ani tento rant neobsahují.
