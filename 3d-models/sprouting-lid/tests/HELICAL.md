# Nový test TO-82 se šroubovicovými háčky

Nejdřív tiskni **test-H20.stl**. Pokud nezabírá, porovnej **test-H34.stl**.
Na vnější pacičce je označení H20 / H34. Oba testy mají šest krátkých
pravotočivých segmentů, nikoli souvislý metrický závit.

## Podklady a omezení

[EN ISO 9100-11:2005, veřejný náhled SIST](https://cdn.standards.iteh.ai/samples/13328/21a5f746aaa348abbed66c058dbc075a/SIST-EN-ISO-9100-11-2005.pdf),
obrázky 2/3 a tabulka 1: krček E 77,60 ±0,45 mm, vrcholy T 80,75 ±0,45 mm,
šest začátků. Tabulka uvádí β 4°40′ / 20,30 mm a β1 7°45′ / 33,85 mm.
Model používá přímo axiální posuv za 360°, nedělí jej šesti.
Konkrétní provedení sklenice není ověřené měřením; oba soubory jsou testy.
Norma popisuje sklo, nikoli hotovou geometrii vytištěného víčka.

## Konstrukce pro tisk (vlastní volby, nikoli normové kóty)

- Sukně uvnitř 83,1 mm, stěna 2,4 mm, výška 11,1 mm nad dosedací plochou.
- Průměr přes špičky 78,65 mm: maximum E 78,05 mm + 0,60 mm vůle v průměru.
  Původní C mělo 77,4 mm a mohlo kolidovat s krčkem.
- Háček zabírá radiálně 0,825 mm pod nominální vrchol T (0,60 mm pod minimum T).
- Střed spodní kontaktní hrany leží 8,4 mm od dosedací plochy. To je výchozí
  kalibrační hodnota převzatá z C, nikoli záruka dotažení konkrétní sklenice.
- Segment má 21°, na každém konci 3,5° radiální náběh; plný záběr tedy 14°.
- Celkový výškový rozdíl po 21°: H20 1,184 mm, H34 1,975 mm.
- Špička je vysoká 0,6 mm. Kontaktní plocha stoupá souvisle; horní kořen
  je omezen výškou sukně. Každý ze šesti segmentů začíná ve stejné výšce.

Změna sklonu není sama o sobě důkaz opravy: krátké ploché háčky mohou se
šikmým skleněným závitem také fungovat. Tento návrh prodlužuje kontakt po
šroubovici a současně opravuje kolizní průměr špiček.

## Tisk a zkouška

Stejný materiál jako minule, 0,2mm vrstva, měřítko 100 %, rovnou stranou dolů,
bez podpor. Zkosené spodky háčků vyžadují zvládnuté převisy tiskárny.
Kroužek musí jít nasadit lehce a při otočení doprava (pohled zvenku na víčko)
se přitáhnout k hrdlu. Násilím přes sklo netlačit.

Zaznamenej: nasazení, dotažení, protáčení, případně vůli po dotažení.
Pokud oba prokluzují, je potřeba změřit axiální polohu záběru a skutečný
průměr krčku; přidávání sklonu naslepo už nepomůže.

## Obnovení STL

Ve složce sprouting-lid, s OpenSCAD v PATH:

```sh
openscad -o tests/test-H20.stl -D 'part="test"' -D 'thread_style="helical"' -D 'thread_lead=20.30' sprouting-lid.scad
openscad -o tests/test-H34.stl -D 'part="test"' -D 'thread_style="helical"' -D 'thread_lead=33.85' sprouting-lid.scad
```

Zdroj se nyní otevírá jako test H20. `thread_style="flat"` vrací původní
A/B/C geometrii (včetně zesíleného víčka při `part="lid"`). Exporty celých
víček ani starší testy nejsou tímto krokem přegenerované.
