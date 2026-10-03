// Krabička řídicí jednotky VZT klapky (Belimo LM24A-SR), 1 kus na sektor.
// Uvnitř zleva: [zdroj ELKO za přepážkou] | DAC DFR0971 | plošák 5×7 cm (ESP32-S3-DevKitC-1
// v dutinkách + R-78E + dělič, na pravé hraně úhlové svorkovnice MSTBA 3p + 4p) | volno na zástrčky
// a dráty | průchodky M12. Bez zdroje (psu=false) přijde 24 V DC kabelem zvenku.
// Uchycení: dva tunely na stahovací pásky / spony přes VZT potrubí.
//
// Render: openscad -D 'part="box"' -o vzt-klapka-box.stl vzt-klapka-box.scad          (tisknout 2×)
//         openscad -D 'part="lid"' -D 'label="A"' -o vzt-klapka-lid-A.stl vzt-klapka-box.scad
//         openscad -D 'part="lid"' -D 'label="B"' -o vzt-klapka-lid-B.stl vzt-klapka-box.scad

part  = "box";    // "box" | "lid" | "open" (spodek s deskami) | "assembly" (i s víkem)
label = "A";      // vyrytý nápis na víku ("" = bez nápisu)
psu   = true;     // true = uvnitř i zdroj ELKO PSB-10-24 (230 V AC → 24 V DC) v odděleném oddílu

// --- stěny ---
wall    = 2.4;    // 6 perimetrů 0.4
floor_t = 2.4;
lid_t   = 2.4;
inner_h = 30;     // ESP v dutinkách: sloupek 5 + plošák 1.6 + dutinky 8.5 + ESP ~5 = ~20, zbytek na dráty
corner_r = 3;     // zaoblení vnějších rohů

// --- plošák 5×7 (Rasel 049-030) – PŘEMĚŘIT díry ---
pcb_l        = 70;
pcb_w        = 50;
pcb_hole_in  = 2.5;   // střed díry od hrany
pcb_standoff = 5;     // výška sloupku nad dnem (jako M3×5 z kusovníku)

// --- DAC DFR0971 – PŘEMĚŘIT, rozměry tady jsou odhad ---
dac_l        = 32;    // podél X
dac_w        = 42;    // podél Y
dac_hole_in  = 3;     // střed díry od hrany
dac_standoff = 5;
dac_gap_x    = 2;     // odstup od levé stěny (DAC je užší než rozteč rohových sloupků)
dac_gap      = 8;     // mezera DAC – plošák; nad ní přečnívá anténa ESP (dobře, pod anténou nemá být měď)

// --- průchodky na pravé stěně: LAPP SKINTOP ST-M 12x1.5 + matice 53119000 (SW17) ---
gland_d       = 12.2; // M12×1.5 (PG7 → 12.5)
gland_spacing = 24;   // osová vzdálenost dvou průchodek (24 V vstup + Belimo)
term_gap      = 30;   // volno mezi plošákem a pravou stěnou: zástrčka MSTB + ohyb drátů + matice

// --- šrouby víka (M3 samořezně do PETG) ---
screw_hole  = 2.6;    // pilotní díra v sloupku
screw_clear = 3.4;    // díra ve víku
boss_d      = 7;

// --- šrouby desek ---
pcb_screw_hole = 2.6; // M3 samořezně; plošák s dírami Ø2 → M2 a 1.7

// --- tunely na pásky pod dnem ---
strap_w   = 14;       // šířka pásky / spony + vůle
strap_h   = 3.5;      // výška tunelu
strap_bot = 1.6;      // spodní stěna tunelu (ta tlačí na potrubí)

// --- víko ---
lip_h   = 3;          // límec zapadající dovnitř
lip_t   = 1.6;
lip_gap = 0.3;        // vůle límce

// --- přítlačná příčka na víku: drží ESP v dutinkách, tlačí na plechový kryt modulu WROOM ---
esp_hold     = true;
esp_overhang = 6;     // o kolik ESP (konec s anténou) přečnívá levou hranu plošáku
esp_top      = pcb_standoff + 1.6 + 8.5 + 2.5 + 1.6 + 3.2;  // sloupek+plošák+dutinky+plast kolíků+DPS ESP+modul
hold_gap     = 0.8;   // vůle nad modulem – ESP povyskočí max o tohle, z dutinek potřebuje ~5 mm
hold_w       = 10;    // šířka příčky v X
hold_from    = 10;    // střed příčky od konce ESP s anténou (anténa ~7 mm, pak kryt ~18 mm)

// --- zdroj ELKO PSB-10-24 (jen když psu = true) ---
psu_l         = 48;   // 48 × 48 × 21 mm, nemá montážní díry → kolébka + oboustranná páska
psu_w         = 48;
psu_h         = 21;
psu_clear     = 0.6;  // vůle v kolébce
psu_cable_gap = 14;   // mezi levou stěnou a zdrojem: matice 230V průchodky + ohyb šňůry
cradle_h      = 8;
cradle_t      = 1.6;
part_t        = 2;    // přepážka 230 V | nízké napětí, až pod víko
part_hole_d   = 6;    // průchod 24 V drátů přepážkou

$fn = 48;

// ------------------------------------------------------------------
psu_comp = psu ? psu_cable_gap + psu_l + 2 * (psu_clear + cradle_t) + 2 : 0;  // délka 230V oddílu
lv_x0    = psu ? psu_comp + part_t : 0;                                       // začátek nízkonapěťové části
inner_l = lv_x0 + dac_gap_x + dac_l + dac_gap + pcb_l + term_gap;
inner_w = max(pcb_w + 10, gland_spacing + 36);
outer_l = inner_l + 2 * wall;
outer_w = inner_w + 2 * wall;
base_h  = strap_bot + strap_h;          // výška patky s tunely
box_h   = base_h + floor_t + inner_h;   // celková výška spodku

dac_x = wall + lv_x0 + dac_gap_x;
psu_x = wall + psu_cable_gap + cradle_t + psu_clear;   // zdroj samotný
psu_y = wall + (inner_w - psu_w) / 2;
part_x = wall + psu_comp;
pcb_x = dac_x + dac_l + dac_gap;
pcb_y = wall + (inner_w - pcb_w) / 2;
dac_y = wall + (inner_w - dac_w) / 2;
floor_z = base_h + floor_t;

boss_xy = [for (x = [wall + boss_d/2, outer_l - wall - boss_d/2],
                y = [wall + boss_d/2, outer_w - wall - boss_d/2]) [x, y]];

echo(str("vnějšek ", outer_l, " × ", outer_w, " × ", box_h + lid_t, " mm"));

module rrect(l, w, h, r) {
    hull() for (x = [r, l - r], y = [r, w - r])
        translate([x, y, 0]) cylinder(r = r, h = h);
}

module standoffs(x0, y0, l, w, inset, h, hole) {
    for (x = [x0 + inset, x0 + l - inset], y = [y0 + inset, y0 + w - inset])
        translate([x, y, floor_z - 0.01])
            difference() {
                cylinder(d = hole + 3.4, h = h + 0.01);
                translate([0, 0, 1]) cylinder(d = hole, h = h);
            }
}

module box() {
    difference() {
        rrect(outer_l, outer_w, box_h, corner_r);
        // vnitřek
        translate([wall, wall, floor_z]) cube([inner_l, inner_w, inner_h + 1]);
        // tunely na pásky (podél Y, přes šířku)
        for (fx = [0.25, 0.75])
            translate([outer_l * fx - strap_w / 2, -1, strap_bot])
                cube([strap_w, outer_w + 2, strap_h]);
        // průchodky vpravo: Belimo (+ 24 V vstup, když zdroj není uvnitř)
        for (s = psu ? [0] : [-1, 1])
            translate([outer_l - wall - 1, outer_w / 2 + s * gland_spacing / 2, floor_z + inner_h / 2])
                rotate([0, 90, 0]) cylinder(d = gland_d, h = wall + 2);
        // 230V přívod na levé stěně
        if (psu)
            translate([-1, outer_w / 2, floor_z + inner_h / 2])
                rotate([0, 90, 0]) cylinder(d = gland_d, h = wall + 2);
    }
    if (psu) {
        // přepážka s dírou na 24 V dráty (nahoře, nad zdrojem)
        difference() {
            translate([part_x, wall - 0.01, floor_z - 0.01]) cube([part_t, inner_w + 0.02, inner_h + 0.01]);
            translate([part_x - 1, wall + inner_w - 10, floor_z + psu_h + 3])
                rotate([0, 90, 0]) cylinder(d = part_hole_d, h = part_t + 2);
        }
        // kolébka pro zdroj
        translate([psu_x - psu_clear - cradle_t, psu_y - psu_clear - cradle_t, floor_z - 0.01])
            difference() {
                cube([psu_l + 2 * (psu_clear + cradle_t), psu_w + 2 * (psu_clear + cradle_t), cradle_h]);
                translate([cradle_t, cradle_t, -1]) cube([psu_l + 2 * psu_clear, psu_w + 2 * psu_clear, cradle_h + 2]);
            }
    }
    // sloupky víka v rozích
    for (p = boss_xy)
        translate([p.x, p.y, floor_z - 0.01])
            difference() {
                union() {
                    cylinder(d = boss_d, h = inner_h + 0.01);
                    // přilepit sloupek ke stěnám, ať netrčí jako tužka
                    translate([p.x < outer_l / 2 ? -boss_d / 2 : 0,
                               p.y < outer_w / 2 ? -boss_d / 2 : 0, 0])
                        cube([boss_d / 2, boss_d / 2, inner_h + 0.01]);
                }
                translate([0, 0, inner_h - 12]) cylinder(d = screw_hole, h = 13);
            }
    standoffs(pcb_x, pcb_y, pcb_l, pcb_w, pcb_hole_in, pcb_standoff, pcb_screw_hole);
    standoffs(dac_x, dac_y, dac_l, dac_w, dac_hole_in, dac_standoff, pcb_screw_hole);
}

module lid() {
    difference() {
        union() {
            rrect(outer_l, outer_w, lid_t, corner_r);
            // přítlačná příčka přes celou šířku – nezáleží, ve které řadě děr ESP na plošáku sedí
            if (esp_hold)
                translate([pcb_x - esp_overhang + hold_from - hold_w / 2, wall + lip_gap, lid_t - 0.01])
                    cube([hold_w, inner_w - 2 * lip_gap, inner_h - esp_top - hold_gap]);
            // límec, vykrojený kolem rohových sloupků
            difference() {
                translate([wall + lip_gap, wall + lip_gap, lid_t - 0.01])
                    cube([inner_l - 2 * lip_gap, inner_w - 2 * lip_gap, lip_h]);
                translate([wall + lip_gap + lip_t, wall + lip_gap + lip_t, lid_t - 1])
                    cube([inner_l - 2 * (lip_gap + lip_t), inner_w - 2 * (lip_gap + lip_t), lip_h + 2]);
                for (p = boss_xy)
                    translate([p.x, p.y, 0]) cylinder(d = boss_d + 2 * lip_gap + 1, h = lid_t + lip_h + 1);
                // zářez pro přepážku
                if (psu) translate([part_x - 0.5, 0, lid_t]) cube([part_t + 1, outer_w, lip_h + 1]);
            }
        }
        for (p = boss_xy)
            translate([p.x, p.y, -1]) {
                cylinder(d = screw_clear, h = lid_t + 2);
                cylinder(d1 = 6.4, d2 = screw_clear, h = 1 + 1.5);   // zápustná hlava
            }
        // nápis – víko se tiskne vnější stranou dolů, proto zrcadlit
        if (label != "")
            translate([wall + lv_x0 + (inner_l - lv_x0) / 2, outer_w / 2, -0.01])
                mirror([1, 0, 0]) linear_extrude(0.6)
                    text(str("VZT ", label), size = 12, halign = "center", valign = "center",
                         font = "Liberation Sans:style=Bold");
        // varování nad 230V oddílem (zároveň ukazuje, jak víko otočit)
        if (psu)
            translate([wall + psu_comp / 2, outer_w / 2, -0.01])
                mirror([1, 0, 0]) linear_extrude(0.6)
                    text("230 V", size = 8, halign = "center", valign = "center",
                         font = "Liberation Sans:style=Bold");
    }
}

module boards_ghost() {
    %translate([pcb_x, pcb_y, floor_z + pcb_standoff]) cube([pcb_l, pcb_w, 1.6]);
    // ESP přečnívá levou hranu plošáku nad DAC, pravá hrana zůstane svorkovnicím
    %translate([pcb_x - esp_overhang, pcb_y + pcb_hole_in + 2, floor_z + pcb_standoff + 1.6 + 11])
        cube([62.7, 25.4, 5]);
    // svorkovnice MSTBA 3p + 4p na pravé hraně, zástrčky trčí ven
    for (t = [[3, 4], [4, 22]])
        %translate([pcb_x + pcb_l - 12, pcb_y + t[1], floor_z + pcb_standoff + 1.6])
            cube([12 + 15, t[0] * 5.08, 12]);
    %translate([dac_x, dac_y, floor_z + dac_standoff]) cube([dac_l, dac_w, 1.6]);
    if (psu) %translate([psu_x, psu_y, floor_z]) cube([psu_l, psu_w, psu_h]);
}

if (part == "box") box();
else if (part == "lid") lid();
else if (part == "open") { box(); boards_ghost(); }
else if (part == "assembly") {
    box();
    boards_ghost();
    translate([0, outer_w, box_h + lid_t]) rotate([180, 0, 0]) lid();
}
