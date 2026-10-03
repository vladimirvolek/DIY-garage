// Medaile / privesek "LIPKA 2026" - tabornicky ohen v soustrednych kruzich
//
// Prumer terce 50 mm, ocko na paracord je prstenec primo v plose terce
// (obrys se u nej jen mirne vydouva), takze privesek nema tenky krcek.
//
// Tiskne se plocho lici nahoru - spodek je rovna plocha na podlozce,
// vsechny detaily rostou vzhuru. Zadne previsy, zadne podpory.
//
// DVOUBAREVNY TISK JEDNOU DUZOU (vymena filamentu / M600):
//   Cele telo medaile konci presne na z = 3.6 mm (= plateau_top) - vc.
//   obvodoveho ramecku. NIC jineho nad tuto uroven nevystupuje.
//   Vsechno nad 3.6 mm je jen relief: ohen, pismo, prstenec ocka a zavorky.
//   => jedina vymena barvy v z = 3.6 mm a mas dvoubarevnou medaili.
//
//   Relief je 1.6 mm = 8 vrstev po 0.2 mm, takze druha barva plne kryje.
//   Vsechny vysky jsou nasobky 0.2 mm, aby vymena padla presne na vrstvu:
//     zaklad 2.4 (12 vrstev) + stupinek 1.2 (6) = 3.6 (18) -> zmena barvy
//     relief 1.6 (8)                            = 5.2 celkova vyska
//
// Soustredne drazky pokryvaji celou plochu terce, ale pod reliefem se
// nerezou - pismo i kresba stoji na plne plose, zadne premostovani
// a hrana barvy je cista.
//
// Doporuceni: 0.4 mm duza, 0.2 mm vrstva, PLA, 3 perimetry, 15 % vyplne.

$fn = 128;

// "all"    = cela medaile jako jeden kus (vymena filamentu v z = 3.6 mm)
// "body"   = jen telo            -> STL pro barvu 1 pri tisku na MMU / AMS
// "relief" = jen kresba a pismo  -> STL pro barvu 2, sedne na telo na 0,0
part = "all";

// --- Terc ---
medal_d     = 50;    // celkovy prumer terce
base_h      = 2.4;   // zakladni deska (12 vrstev)
edge_cham   = 0.6;   // srazeni spodni hrany (proti "elephant foot")

plateau_d   = 45;    // zvysena plocha uvnitr obvodoveho ramecku
plateau_h   = 1.2;   // vyska stupinku nad zakladni deskou (6 vrstev)

// --- Soustredne drazky ---
// Vyplnuji celou plochu terce; kresba a pismo je preseknou, takze mezi
// nimi prosvitaji jako letokruhy na spalku.
groove_r0    = 2.0;   // nejvnitrnejsi drazka
groove_r1    = 21.4;  // nejvnejsi drazka
groove_pitch = 1.45;  // rozestup drazek (zbyla plocha mezi nimi = 2 stopy duzy)
groove_w     = 0.65;  // sirka drazky
groove_d     = 0.6;   // hloubka drazky (3 vrstvy)
groove_gap   = 0.55;  // volna obruba kolem reliefu
groove_close = 0.9;   // uzavre uzke mezery v kresbe (mezi pismeny, uvnitr
                      // obrysu polen), aby v nich nezbyly ohryzky drazek

// --- Relief (druha barva) ---
relief_h    = 1.6;   // vyska reliefu nad plateau (8 vrstev)

// --- Text ---
// Arial Black uz sam nese hodne tucne tahy, takze txt_bold je jen jemne
// doladeni - vic uz pismo slepuje protilezici tahy ("A", "0", "6").
txt         = "LIPKA 2026";
txt_size    = 4.6;   // = vyska verzalek (u Arial Black plati cap_h ~ size)
txt_r       = 20.8;  // radius uctarove linky (text roste dovnitr)
txt_gap     = 0.13;  // mezera mezi znaky vc. postranku (nasobek txt_size)
txt_bold    = 0.08;  // jemne ztlusteni glyfu
txt_font    = "Arial Black";

// --- Ocko na sneru ---
// Dira lezi cela uvnitr terce, obrys se nad ni jen vydouva - proti verzi
// s vyckem na krcku tu neni zadne uzke misto, kde by privesek praskl.
loop_y      = 22.0;  // stred diry od stredu terce
loop_id     = 5.0;   // dira - projde paracord 4 mm i s uzlem
loop_od     = 11.0;  // prumer vydute casti obrysu terce
loop_ring   = 9.0;   // vnejsi prumer reliefniho prstence kolem diry
loop_clear  = 12.0;  // oblast kolem ocka drzena v plne vysce (kvuli prstenci)
loop_fillet = 2.0;   // zaobleni prechodu vydut <-> terc

// --- Derived ---
R           = medal_d / 2;
plateau_top = base_h + plateau_h;   // 3.6 mm = uroven vymeny barvy

if (part == "all")    { medal_body(); medal_relief(); }
if (part == "body")     medal_body();
if (part == "relief")   medal_relief();

// Barva 1 - telo. Konci presne na plateau_top, nic nevystupuje vys.
module medal_body()
{
    difference()
    {
        body();
        rim_step();
        grooves();
    }
}

// Barva 2 - vse od plateau_top vzhuru.
module medal_relief()
{
    translate([ 0, 0, plateau_top ])
        linear_extrude(height = relief_h)
            relief_2d();
}

// ---------------------------------------------------------------- terc + ocko

// Obrys terce s vydutim nad ockem; konkavni prechod je vyplnen filetem,
// aby vydut nesedelo na ostre hrane.
module outline_2d()
{
    difference()
    {
        offset(r = -loop_fillet) offset(r = loop_fillet)
        union()
        {
            circle(r = R);
            translate([ 0, loop_y ]) circle(d = loop_od);
        }

        translate([ 0, loop_y ]) circle(d = loop_id);
    }
}

// Telo v plne vysce. Spodni hrana je srazena po vrstvach 0.2 mm, tedy
// presne to, co by slicer z opravdoveho 45 deg srazeni vyrobil.
module body()
{
    steps = 3;
    for (i = [0 : steps - 1])
    {
        translate([ 0, 0, i * edge_cham / steps ])
            linear_extrude(height = (i == steps - 1)
                                    ? plateau_top - i * edge_cham / steps
                                    : edge_cham / steps + 0.01)
                offset(r = -edge_cham * (steps - 1 - i) / steps)
                    outline_2d();
    }
}

// Snizi obvodovy ramecek terce na base_h. Kolem ocka se plna vyska
// ponechava - prstenec ocka tam musi stat na plose, ne nad stupinkem.
module rim_step()
{
    translate([ 0, 0, base_h ])
        linear_extrude(height = plateau_h + 1)
            difference()
            {
                circle(r = R + 1);
                circle(r = plateau_d / 2);
                translate([ 0, loop_y ]) circle(d = loop_clear);
            }
}

module grooves()
{
    translate([ 0, 0, plateau_top - groove_d ])
        linear_extrude(height = groove_d + 1)
            difference()
            {
                for (r = [ groove_r0 : groove_pitch : groove_r1 ])
                    difference()
                    {
                        circle(r = r + groove_w / 2);
                        circle(r = r - groove_w / 2);
                    }

                // Pod reliefem se nerez - kresba pak stoji na plne plose
                // a hrana barvy je cista. Maska pouziva plne siluety
                // (viz relief_mask_2d), takze uvnitr obrysu polen ani
                // v letokruzich nezbydou ohryzky drazek.
                offset(r = groove_gap)
                    offset(r = -groove_close) offset(r = groove_close)
                        relief_mask_2d();
            }
}

// ------------------------------------------------------------------- relief

module relief_2d()
{
    campfire();
    fire_flames();
    loop_eye();
    arc_text(txt, txt_r, txt_size);
    brackets();
}

// Maska pro drazky: linkove casti nahrazene plnou siluetou. Za textem se
// maskuje souvisly obloukovy pas - jinak by v mezere mezi slovy zbyly
// kousky drazek a cetly se jako pomlcka ("LIPKA-2026").
module relief_mask_2d()
{
    campfire_mask();
    fire_flames_mask();
    loop_eye_mask();
    text_band();
    brackets();
}

// --- Ohen: vejir polen pod plamenem ---------------------------------------
//
// Pet polen vybihajicich z jednoho hnizda: dve do stran, dve sikmo dolu
// a jedno primo k divakovi (to je nejsirsi a je uplne vpredu). Kresba je
// linkova - obrys trupu plus kruh cela, uvnitr ktereho prosviti podklad
// jako letokruh.
// Hnizdo lezi pod patou plamene, ne v ni - jinak plamen polena presekne
// tak vysoko, ze z nich zbydou jen spendliky u okraje.
fire_c   = [ 0, -3.0 ];   // hnizdo, ze ktereho polena vybihaji
log_line = 0.8;           // sirka linky kresby (= 2 stopy 0.4 duzy)
log_hub  = 2.0;           // vnitrni konec polena (radius od hnizda)
log_gap  = 0.65;          // obrysova mezera kolem polena, ktere je vepredu

// [ uhel, delka, sirka, prumer cela vuci sirce ] - poradi je zezadu dopredu.
// Polena jsou stihla, celo jen o neco sirsi nez trup - tluste poleno
// s velkym kruhem na konci vypada jako klika, ne jako kulatina.
// Poleno mirici na divaka je nejsirsi a ma celo skoro jako trup.
logs = [
    [ 165, 11.5, 2.7, 1.45 ],   // sikmo nahoru doleva
    [  15, 11.5, 2.7, 1.45 ],   // sikmo nahoru doprava
    [ 205, 10.5, 2.8, 1.45 ],   // sikmo dolu doleva
    [ 335, 10.5, 2.8, 1.45 ],   // sikmo dolu doprava
    [ 270,  9.0, 3.6, 1.25 ],   // k divakovi - vepredu, nejsirsi
];

function log_p0(i) = [ fire_c[0] + log_hub * cos(logs[i][0]),
                       fire_c[1] + log_hub * sin(logs[i][0]) ];
function log_p1(i) = [ fire_c[0] + logs[i][1] * cos(logs[i][0]),
                       fire_c[1] + logs[i][1] * sin(logs[i][0]) ];

// Polena se kresli az k hnizdu, ale plamen je vsechna presekne - vnitrni
// konce tak mizi za nim misto aby se s jeho obrysem slily v chumel car.
module campfire()
{
    difference()
    {
        // kazde poleno je preseknute vsemi, ktera jsou pred nim.
        // Podminka misto rozsahu [i+1 : n-1] - ten se pro posledni poleno
        // v OpenSCADu otoci a sahnul by mimo pole.
        for (i = [0 : len(logs) - 1])
            difference()
            {
                log_draw(i);
                for (j = [0 : len(logs) - 1])
                    if (j > i) offset(r = log_gap) log_solid(j);
            }

        offset(r = log_gap) translate([ 0, flame_y ]) flame(flame_h);
    }
}

// Plna silueta hranice polen - maska, kolem ktere se zastavuji drazky.
module campfire_mask()
{
    for (i = [0 : len(logs) - 1]) log_solid(i);
}

function log_end_d(i) = logs[i][2] * logs[i][3];

// Plna silueta polena: trup + kulate celo.
module log_solid(i)
{
    hull()
    {
        translate(log_p0(i)) circle(d = logs[i][2]);
        translate(log_p1(i)) circle(d = logs[i][2]);
    }
    translate(log_p1(i)) circle(d = log_end_d(i));
}

// Linkova kresba polena. Kruh cela se kresli i pres trup, takze je celo
// od trupu oddelene linkou - jinak by z toho byla jen lizatkova silueta.
module log_draw(i)
{
    stroke_2d(log_line) log_solid(i);
    translate(log_p1(i)) stroke_2d(log_line) circle(d = log_end_d(i));
}

// --- Plamen ---------------------------------------------------------------
// Hlavni plamen, dva vnorene plaminky a dva samostatne jazyky po stranach.
flame_line  = 0.95;
flame_h     = 13.5;
flame_y     = -1.5;

// Bocni jazyky jsou plne a stihle. Obrysove by v teto velikosti nevysly -
// dutina se u spicky uzavre a zbyde z toho hrot sipky.
lick_h      = 5.0;
lick_slim   = 0.75;
lick_pos    = [ 7.2, 6.6 ];
lick_tilt   = 28;

module fire_flames()
{
    translate([ 0, flame_y       ]) stroke_2d(flame_line) flame(flame_h);
    translate([ 0, flame_y + 1.4 ]) stroke_2d(flame_line) flame_inner(7.4);
    translate([ 0, flame_y + 2.6 ])                       flame_inner(3.4);

    licks();
}

module fire_flames_mask()
{
    translate([ 0, flame_y ]) flame(flame_h);
    licks();
}

module licks()
{
    for (s = [ -1, 1 ])
        translate([ s * lick_pos[0], lick_pos[1] ])
            rotate([ 0, 0, -s * lick_tilt ])
                scale([ lick_slim, 1 ])
                    flame_inner(lick_h);
}

// Silueta plamene, normovana na vysku 1: dva laloky u paty, nejsirsi
// v dolni tretine, ve dvou tretinach vysky vybezek do strany a pak
// odtah do spicky.
flame_pts = [
    [ 0.00, 0.14 ],   // vykrojek mezi laloky
    [ 0.16, 0.02 ],
    [ 0.33, 0.02 ],
    [ 0.44, 0.14 ],
    [ 0.47, 0.30 ],   // nejsirsi misto
    [ 0.42, 0.42 ],
    [ 0.33, 0.49 ],   // zatazeni dovnitr...
    [ 0.38, 0.57 ],   // ...a vybezek ven
    [ 0.26, 0.69 ],
    [ 0.19, 0.79 ],
    [ 0.10, 0.90 ],
    [ 0.00, 1.00 ],   // spicka
];

// Vnitrni plaminek a bocni jazyky: hladka kapka bez vlnek - v male
// velikosti by se ze zubate silueta stala sipka.
drop_pts = [
    [ 0.00, 0.18 ],
    [ 0.18, 0.02 ],
    [ 0.32, 0.00 ],
    [ 0.42, 0.12 ],
    [ 0.44, 0.30 ],
    [ 0.36, 0.52 ],
    [ 0.22, 0.72 ],
    [ 0.09, 0.89 ],
    [ 0.00, 1.00 ],
];

module flame(h)       flame_poly(flame_pts, h, 0.055);
module flame_inner(h) flame_poly(drop_pts,  h, 0.06);

// Zrcadlove doplni pulku siluety a zaobli rohy polygonu
// (offset(+r) offset(-r) -> plynula krivka).
module flame_poly(pts, h, r)
{
    offset(r = r * h) offset(r = -r * h)
        polygon(concat(
            [ for (p = pts)                     [  p[0] * h, p[1] * h ] ],
            [ for (i = [len(pts) - 2 : -1 : 1]) [ -pts[i][0] * h,
                                                   pts[i][1] * h ] ]
        ));
}

// --- Ocko: prstenec kolem diry a kapka pod nim -----------------------------

drip_y = 14.2;
drip_h = 2.2;

module loop_eye()
{
    difference()
    {
        translate([ 0, loop_y ]) circle(d = loop_ring);
        translate([ 0, loop_y ]) circle(d = loop_id);
    }

    translate([ 0, drip_y ]) flame_inner(drip_h);
}

module loop_eye_mask()
{
    translate([ 0, loop_y ]) circle(d = loop_ring);
    translate([ 0, drip_y ]) flame_inner(drip_h);
}

// --- Hranate zavorky po stranach ------------------------------------------

module brackets()
{
    translate([ -20.0, 3.0 ])                  bracket(11.0, 3.4, 1.0);
    translate([  20.0, 3.0 ]) mirror([ 1, 0 ]) bracket(11.0, 3.4, 1.0);
}

// Hranata zavorka "[" - svisla cara s patkami dovnitr, vystredena na origin.
module bracket(h, arm, w)
{
    translate([ 0, -h / 2 ])
    {
        square([ w, h ]);
        square([ arm, w ]);
        translate([ 0, h - w ]) square([ arm, w ]);
    }
}

// --- Pomocne --------------------------------------------------------------

// Prevede plnou 2D plochu na obrys dane sirky (linkovy styl).
module stroke_2d(w)
{
    difference()
    {
        children();
        offset(r = -w) children();
    }
}

// Obloukovy pas pokryvajici cely radek textu vcetne mezer.
module text_band()
{
    half_ang = 62;    // pulka uhloveho rozsahu textu + rezerva
    far      = txt_r + 5;

    intersection()
    {
        difference()
        {
            circle(r = txt_r + 1);
            circle(r = txt_r - txt_size - 1);
        }

        polygon([ [ 0, 0 ],
                  [  far * sin(half_ang), -far * cos(half_ang) ],
                  [ 0, -far ],
                  [ -far * sin(half_ang), -far * cos(half_ang) ] ]);
    }
}

// --- Text po spodnim obvodu -------------------------------------------------
// Znaky se sazi jednotlive po kruznici; horni strana pisma miri do stredu.
// Ciste sirky kresby glyfu Arial Black (nasobek size), zmerene z bounding
// boxu vyexportovaneho STL. Bez nich by "I" zabralo stejne misto jako "K".
function char_ink(c) =
      c == "L" ? 0.787
    : c == "I" ? 0.308
    : c == "P" ? 0.844
    : c == "K" ? 1.054
    : c == "A" ? 1.082
    : c == "2" ? 0.829
    : c == "0" ? 0.812
    : c == "6" ? 0.819
    : c == " " ? 0.300
    :            0.850;   // rozumny odhad pro nezmereny znak

// Rozestup stredu znaku po oblouku, v mm. Ztlusteni glyfu rozsiri kresbu
// na obe strany, tak se pripocitava.
function char_adv(c) = char_ink(c) * txt_size + 2 * txt_bold
                       + txt_gap * txt_size;

function adv_sum(s, i) = i <= 0 ? 0 : adv_sum(s, i - 1) + char_adv(s[i - 1]);

module arc_text(s, r, size)
{
    n     = len(s);
    total = adv_sum(s, n);

    for (i = [0 : n - 1])
    {
        // delka obloukove drahy od stredu textu do stredu znaku
        arc = adv_sum(s, i) + char_adv(s[i]) / 2 - total / 2;
        ang = arc / r * 180 / PI;

        rotate([ 0, 0, ang ])
            translate([ 0, -r ])
                offset(r = txt_bold)
                    text(s[i], size = size, font = txt_font,
                         halign = "center", valign = "baseline");
    }
}
