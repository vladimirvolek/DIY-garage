> Novější testy se šikmými háčky: **[H20 / H34](HELICAL.md)**. Níže je historie plochých A/B/C.

# Zkouška proti protáčení TO-82

## Zesílení po ulomení komínku (21. 9. 2026)

Aktuální zdroj má `reinforced = true`. Nový výstup je
`../sprouting-lid-C-reinforced.stl` a projekt s profilem
`../sprouting-lid-C-reinforced.3mf`. Staré soubory C jsou původní konstrukce.

- Deska 3,2 místo 2,4 mm, stěna komínku 2,4 místo 1,6 mm.
- Komínek má u paty kuželovou výztuhu vysokou a širokou 3 mm;
  dírky sítka jsou odsunuté mimo patu.
- Obvodová stěna zesílena ven na 3,2 mm. Vnitřní průměr a poloha
  háčků vůči dosedací ploše zůstávají C. Celková výška vzrostla o 0,8 mm.
- Testovací kroužky zachovávají původní rozměry. `reinforced = false`
  obnoví původní konstrukci plného víčka.

Profil vychází z uloženého C.3mf: MK3S/MK3S+, tryska 0,4 mm, Prusa PETG,
240 °C. Změny: vrstva 0,2 mm, 4 perimetry, plná výplň 35 místo 80 mm/s,
horní povrch 25 místo 40 mm/s, malé perimetry 20 mm/s, výplň 50 mm/s.
Generátor perimetrů Classic: Arachne při kontrole hlásil obrácení směru stěn.
Tisk sítkem na podložce, komínkem nahoru, bez podpor. Profil je i v INI
vedle modelu. Pokud skutečná tiskárna či materiál nesouhlasí, vyber správné
profily před tiskem. Teplotu ani průtok jsme bez diagnostiky neměnili.

Z fotky nelze určit příčinu hrubého povrchu ani sílu potřebnou k ulomení.
Zesílení řeší konstrukční slabinu; špatné spojení vrstev nevyřeší samo.
Nejdřív zkontroluj čistotu a usazení plátu, první vrstvu, volný odvíjení
cívky a rovnoměrné vytlačování. Pokud PETG prská, řeš jeho vysušení podle
výrobce. Při přetrvávajícím slabém spojení vrstev zkus teplotu po 5 °C
v mezích doporučení filamentu. Pevnost a lícování vyžadují fyzický test.

Generování nové varianty:

```sh
openscad -o sprouting-lid-C-reinforced.stl sprouting-lid.scad
```

## Původní zkoušky závitu

Pro celý výtisk byla vybraná **varianta C**. Plné víčko je v `../sprouting-lid-C.stl`
a `../sprouting-lid-C.3mf`. Kroužky mají písmeno na vnější pacičce.
Jde o porovnávací pokusy, nikoli potvrzenou geometrii závitu konkrétní sklenice.

| Kroužek | Háček od dosedací plochy | Průměr přes špičky | Co se mění |
| --- | ---: | ---: | --- |
| Původní | 9,2 mm | 77,8 mm | dosavadní protáčející se verze |
| A | 8,4 mm | 77,8 mm | háčky blíž k dosedací ploše |
| B | 9,2 mm | 77,4 mm | háčky zasahují o 0,2 mm víc dovnitř |
| C | 8,4 mm | 77,4 mm | obě změny |

Vnitřní průměr sukně zůstává 83,1 mm, šest háčků a výška sukně 11,1 mm.
Dosedací prstenec je stejný jako u původního testu. Pacička nemění lícování.

- Stejný materiál a profil jako u posledního testu, vrstva 0,2 mm.
- Rovnou stranou na podložku, měřítko 100 %, bez podpor.
- Vyzkoušej lehce rukou: lze nasadit, dotáhne se, nebo se pořád protáčí?
- A drží: problém nejspíš v axiální poloze háčků.
- A se protáčí: zkus B; pokud B také nestačí a jde nasadit, zkus C.
- Pokud některý kroužek nejde nasadit či se příčí, nepáčit přes sklo.

Stačí pak napsat například „A se protáčí, B drží, C nejde nasadit“.
Rozměry testu C jsou převedené do plného víčka. Celé víčko ještě čeká na fyzický test.
Starší STL/3MF bez přípony `-C` mimo tuto složku zůstaly zachované.

## Generování

Ve složce sprouting-lid, s OpenSCAD v PATH:

```sh
openscad -o tests/test-A.stl -D 'part="test"' -D 'thread_style="flat"' -D 'test_variant="A"' sprouting-lid.scad
openscad -o tests/test-B.stl -D 'part="test"' -D 'thread_style="flat"' -D 'test_variant="B"' sprouting-lid.scad
openscad -o tests/test-C.stl -D 'part="test"' -D 'thread_style="flat"' -D 'test_variant="C"' sprouting-lid.scad
```

Zdroj se nyní otevírá jako celé víčko C (`part="lid"`, `lid_variant="C"`).
`lid_variant="reference"` vrátí původní rozměry plného víčka;
`part="test"` a `test_variant="reference"` vytvoří původní kroužek s označením R.

```sh
openscad -o sprouting-lid-C.stl -D 'reinforced=false' sprouting-lid.scad
```

Celé víčko tiskni sítkem na podložce a komínkem nahoru, měřítko 100 %,
vrstva 0,2 mm, stejný materiál a profil jako u úspěšného testu C, bez podpor.
