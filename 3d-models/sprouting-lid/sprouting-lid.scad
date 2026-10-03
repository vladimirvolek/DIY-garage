// Naklicovaci viko na twist-off sklenici TO-82 (Twist-Off 82 mm Regular)
// Inspirace: Tescoma Sense naklicovaci nadoba.
//
// Jeden kus - normalni viko se zavitem:
//   1. Sito  - perforovana deska (1.8 mm otvory) na proplach a odtok vody
//   2. Komin - stredovy otvor na zalevani/vetrani; trubka miri dovnitr
//              sklenice a konci vysoko nad vrstvou seminek perforovanou
//              kuzelovou cepickou (45°) - voda i vzduch projdou, klicky
//              nepropadnou
//   3. Sukne s ozuby twist-off zavitu kolem desky
//
// Tiskne se rovnou deskou (sitem) primo na podlozce; sukne, komin i
// cepicka rostou z desky vzhuru - zadny previs, zadne podpory ani mosty.
//
// Material: PETG (potravinam blizsi a vlhku odolny), 0.2 mm vrstva.
//
// Kalibrace: nez tisknes cele viko, nastav part = "test" a vytiskni jen
// kratky zkusebni krouzek se zavitem (~15 min).

part = "lid";              // "lid" = viko | "test" = zkusebni krouzek zavitu
lid_variant = "C";         // plne viko pouziva rozmery vybraneho testu
reinforced = true;         // zesilene plne viko; false obnovi puvodni konstrukci
strengthened = reinforced && part == "lid";

// Testy proti aktualnimu protacejicimu se krouzku:
// A: hak bliz k usti o 0.8 mm; B: vetsi radialni zaber o 0.2 mm;
// C: obe zmeny. reference = puvodni rozmery. Pro plne viko zvol lid_variant.
test_variant = "C";       // "A", "B", "C", "reference"
test_hook_shift = 0.8;   // kladna hodnota posouva hak BLIZ k dosedaci plose
test_tip_reduction = 0.4; // zmenseni PRUMERU pres spicky, radialne polovina
assert(test_variant == "A" || test_variant == "B" ||
       test_variant == "C" || test_variant == "reference");
assert(part == "test" || part == "lid");
assert(lid_variant == "A" || lid_variant == "B" ||
       lid_variant == "C" || lid_variant == "reference");
fit_variant = part == "test" ? test_variant : lid_variant;

// --- TO-82 regular: EN ISO 9100-11:2005, fig. 2/3, table 1 ---
// Source and calibration assumptions: tests/HELICAL.md.
// Glass E = 77.60 +/-0.45; T = 80.75 +/-0.45; six starts.
// Table gives beta: 20.30 mm/revolution, beta1: 33.85 mm/revolution.
// These are glass dimensions, NOT ready-made FDM cap dimensions.
thread_style = "helical";  // "flat" reproduces previous A/B/C geometry
// H20: uzivatel potvrdil uspesne nasazeni testovaciho krouzku.
thread_lead = 20.30;       // axial travel for ONE FULL revolution, not /6
neck_clearance_d = 0.60;   // diametral clearance above maximum glass E
helical_hook_z = 8.4;      // print calibration: middle of contact arc, not ISO
helical_tip_h = 0.6;       // print design, not ISO
assert(thread_style == "flat" || thread_style == "helical");
assert(thread_lead > 0 && neck_clearance_d > 0);
is_helical = thread_style == "helical";

skirt_id = 83.1;          // existing skirt; 1.9 mm above maximum glass T
skirt_h = 11.1;
wall = strengthened ? 3.2 : 2.4;
lug_count = 6;
lug_tip_d = is_helical ? 77.60 + 0.45 + neck_clearance_d
    : 77.8 - ((fit_variant == "B" || fit_variant == "C") ? test_tip_reduction : 0);
lug_hook_z = is_helical ? helical_hook_z
    : 9.2 - ((fit_variant == "A" || fit_variant == "C") ? test_hook_shift : 0);
lug_tip_h = is_helical ? helical_tip_h : 0.25;
lug_arc_deg = 21;         // cap segment design, not glass thread arc
lug_ramp_deg = is_helical ? 3.5 : 7; // longer full-depth contact in new cap
hook_slope = 0.9;
rim_slope = 1.0;
lug_top_gap = 0.45;

// --- Sito / deska ---
plate_t       = strengthened ? 3.2 : 2.4;
mesh_hole_d   = 1.8;      // otvory spodniho sita (drive 1.6 mm)
cap_hole_d    = 1.6;      // otvory cepicky kominu, nezavisle na spodnim site
mesh_pitch    = 3.4;
center_hole_d = 14;       // stredovy otvor na zalevani
chimney_l     = 118;      // delka trubky kominu dovnitr sklenice (bez
                          // cepicky); sklo 152.8 vysoke, vnitrni hloubka
                          // ~148 - s cepickou (7) konci komin ~125 pod
                          // vikem, tj. ~85 % hloubky, ~23 mm nade dnem
chimney_wall  = strengthened ? 2.4 : 1.6;
chimney_root = strengthened ? 3 : 0; // 45° vyztuha paty kominu
cap_h         = 7;        // vyska perforovane kuzelove cepicky na konci kominu

$fn = 128;

// --- Odvozene ---
skirt_od  = skirt_id + 2 * wall;
r_id      = skirt_id / 2;
r_od      = skirt_od / 2;
lug_tip_r = lug_tip_d / 2;
seal_z    = plate_t;              // dosedaci plocha na okraj sklenice
mesh_r_in  = center_hole_d / 2 + chimney_wall + chimney_root + 2.5;
mesh_r_out = r_id - 3;

// Vsechny spojovane objemy se prekryvaji o `eps`, aby vysledek byl
// jedno vodotesne teleso (zadne koplanarni dotyky).
eps = 0.2;

// Each lug follows a right-handed helix: z increases with angle (CCW
// viewed from +Z). Printing the cap upside down is a rotation, not a mirror.
// All six starts reset to the same height. At the segment midpoint, the
// contact height is lug_hook_z. End ramps retract radially into the skirt.
// The top envelope stays below the skirt opening; the CONTACT face remains
// helical. The flat setting retains the earlier A/B/C generator.
module lug() {
    steps = ceil(lug_arc_deg / 1.5);
    Rw    = r_id + 0.4;                        // kotva ve stene sukne
    top_z = skirt_h - lug_top_gap;
    // spicka v danem kroku: nabeh - drzeni - nabeh
    function tip_r_at(a) =
        a < lug_ramp_deg ?
            Rw - 0.05 - (Rw - 0.05 - lug_tip_r) * a / lug_ramp_deg :
        a > lug_arc_deg - lug_ramp_deg ?
            Rw - 0.05 - (Rw - 0.05 - lug_tip_r)
                      * (lug_arc_deg - a) / lug_ramp_deg :
            lug_tip_r;
    function rise(a) = is_helical ? thread_lead * (a - lug_arc_deg / 2) / 360 : 0;
    function hook_z(r, a) = lug_hook_z + rise(a) - (r - lug_tip_r) * hook_slope;
    function rim_z(r, a) = min(lug_hook_z + rise(a) + lug_tip_h
                             + (r - lug_tip_r) * rim_slope, top_z);
    // 4 body profilu: stena-dole, stena-nahore, spicka-nahore, spicka-dole
    // (stejne poradi jako v drivejsim generatoru)
    assert(lug_hook_z - abs(rise(0)) - (Rw - lug_tip_r) * hook_slope > 0);
    assert(lug_hook_z + abs(rise(0)) + lug_tip_h < top_z);
    assert(lug_tip_r < r_id && lug_ramp_deg * 2 < lug_arc_deg);
    function prof(rt, a) = [ [ Rw, hook_z(Rw, a) ],
                            [ Rw, rim_z(Rw, a) ],
                            [ rt, rim_z(rt, a) ],
                            [ rt, hook_z(rt, a) ] ];
    pts = [ for (s = [ 0 : steps ], p = prof(tip_r_at(s * lug_arc_deg / steps), s * lug_arc_deg / steps))
                let (a = s * lug_arc_deg / steps)
                    [ p[0] * cos(a), p[0] * sin(a), p[1] ] ];
    faces = concat(
        [ [ 3, 2, 1, 0 ] ],                    // celo na zacatku
        [ for (s = [ 0 : steps - 1 ], i = [ 0 : 3 ], t = [ 0 : 1 ])
              t == 0
                  ? [ s * 4 + i, s * 4 + (i + 1) % 4,
                      (s + 1) * 4 + (i + 1) % 4 ]
                  : [ s * 4 + i, (s + 1) * 4 + (i + 1) % 4,
                      (s + 1) * 4 + i ] ],
        [ [ steps * 4, steps * 4 + 1,          // celo na konci
            steps * 4 + 2, steps * 4 + 3 ] ]);
    polyhedron(points = pts, faces = faces, convexity = 4);
}

module lugs() {
    for (i = [0 : lug_count - 1])
        rotate([ 0, 0, i * 360 / lug_count ])
            lug();
}

// Sukne s ozuby + nabehova hrana; zacina `eps` pod dosedaci rovinou
// `sz`, aby se prekryvala s deskou pod sebou.
// Mezikruzi i vroubkovani na uchop je jeden 2D obrys -> jedno
// linear_extrude.
module skirt(sz) {
    translate([ 0, 0, sz - eps ]) {
        difference() {
            linear_extrude(skirt_h + eps)
                difference() {
                    union() {
                        circle(r = r_od);
                        // vroubkovani na uchop
                        for (i = [0 : 35])
                            rotate(i * 10)
                                translate([ r_od - 0.4, 0 ])
                                    circle(d = 1.8, $fn = 16);
                    }
                    circle(r = r_id);
                }
            // 45° nabeh na ustich sukne (horni okraj v tisku)
            translate([ 0, 0, skirt_h + eps - 1.2 ])
                cylinder(h = 1.3, r1 = r_id, r2 = r_id + 1.4);
        }
        translate([ 0, 0, eps ]) lugs();
    }
}

// VIKO - tiskne se deskou (sitem) na podlozce, vse roste vzhuru
module lid() {
    chimney_r = center_hole_d / 2 + chimney_wall;   // 8.6
    tube_top  = seal_z + chimney_l;
    cap_z0    = tube_top - eps;                     // zacatek cepicky (prekryv)

    difference() {
        union() {
            // deska sita vcetne der: jeden 2D obrys -> jedno linear_extrude
            linear_extrude(plate_t)
                difference() {
                    circle(r = r_od);
                    for (x = [ -mesh_r_out : mesh_pitch : mesh_r_out ],
                         y = [ -mesh_r_out : mesh_pitch : mesh_r_out ]) {
                        r = sqrt(x * x + y * y);
                        if (r > mesh_r_in && r < mesh_r_out)
                            translate([ x, y ])
                                circle(d = mesh_hole_d, $fn = 12);
                    }
                }
            // komin jako plny valec (vyvrt prijde globalne)
            translate([ 0, 0, seal_z - eps ])
                cylinder(h = eps + chimney_l,
                         d = center_hole_d + 2 * chimney_wall, $fn = 64);
            // Souvisla kuzelova pata rozklada ohyb do desky. Zadna dira
            // sita nezasahuje pod vyztuhu; stredovy vyvrt se odecte nize.
            if (chimney_root > 0)
                translate([ 0, 0, seal_z - eps ])
                    cylinder(h = chimney_root + eps,
                             r1 = chimney_r + chimney_root,
                             r2 = chimney_r, $fn = 64);
            // kuzelova cepicka na konci kominu (45° - tiskne se bez mostu)
            translate([ 0, 0, cap_z0 ])
                cylinder(h = cap_h, r1 = chimney_r, r2 = chimney_r - cap_h,
                         $fn = 64);
            skirt(seal_z);
        }
        // stredovy otvor skrz desku a trubku kominu (konci pod cepickou)
        translate([ 0, 0, -1 ])
            cylinder(h = 1 + chimney_l + seal_z - eps,
                     d = center_hole_d, $fn = 64);
        // dutina cepicky (45° kuzel, radialni stena ~2 mm)
        translate([ 0, 0, cap_z0 - 1 ])
            cylinder(h = cap_h + 0.4,
                     r1 = center_hole_d / 2 + 0.6, r2 = 0.2, $fn = 64);
        // sitko v cepicce: svisle otvory skrz kuzelovou stenu + spicku
        for (n = [ 0 : 9 ])
            rotate([ 0, 0, n * 36 ])
                translate([ 6, 0, cap_z0 - 0.5 ])
                    cylinder(h = cap_h + 2, d = cap_hole_d, $fn = 12);
        for (n = [ 0 : 6 ])
            rotate([ 0, 0, n * 360 / 7 + 18 ])
                translate([ 4, 0, cap_z0 - 0.5 ])
                    cylinder(h = cap_h + 2, d = cap_hole_d, $fn = 12);
        for (n = [ 0 : 3 ])
            rotate([ 0, 0, n * 90 ])
                translate([ 2, 0, cap_z0 - 0.5 ])
                    cylinder(h = cap_h + 2, d = cap_hole_d, $fn = 12);
        translate([ 0, 0, cap_z0 - 0.5 ])
            cylinder(h = cap_h + 2, d = cap_hole_d, $fn = 12);
    }
}

// Zkusebni krouzek: jen dosedaci prstenec + sukne se zavitem
module test_ring() {
    difference() {
        cylinder(h = plate_t, r = r_od);
        translate([ 0, 0, -0.5 ])
            cylinder(h = plate_t + 1, r = r_id - 4);
    }
    skirt(plate_t);
    // Znacka na VNĚJSÍ strane; nezasahuje do dosedaci plochy ani ozubu.
    // Svisle steny pismene vyrustaji z podlozky, bez podpor.
    translate([r_od + (is_helical ? 3 : 1.6), 0, 0])
        linear_extrude(0.6)
            text(is_helical ? (thread_lead < 27 ? "H20" : "H34") :
                 (test_variant == "reference" ? "R" : test_variant),
                 size = is_helical ? 2.5 : 4, halign = "center", valign = "center");
    translate([r_od - 0.3, -3, 0]) cube([is_helical ? 7 : 4.5, 6, 0.4]);
}

if (part == "test") test_ring();
else lid();
