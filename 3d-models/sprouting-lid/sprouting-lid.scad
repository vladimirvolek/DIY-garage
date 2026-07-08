// Naklicovaci viko na twist-off sklenici (TO-82, sklo pres zavit ~Φ86)
// Inspirace: Tescoma Sense naklicovaci nadoba.
//
// Jeden kus - normalni viko se zavitem:
//   1. Sito  - perforovana deska (1.6 mm otvory) na proplach a odtok vody
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
// kratky zkusebni krouzek se zavitem (~15 min). Kdyz nejde nasadit,
// zvets glass_clearance nebo zmensi lug_reach; kdyz je volny, obracene.

part = "lid";             // "lid" = viko | "test" = zkusebni krouzek zavitu

// --- Sklenice (twist-off TO-82, podle vykresu) ---
glass_thread_od = 86.0;   // prumer pres sklo/zavit (vykres: Φ86)
glass_clearance = 1.4;    // vule v prumeru mezi sklem a sukni

// --- Sukne a ozuby (lugs) ---
wall        = 2.4;
skirt_h     = 14;         // vyska sukne pres hrdlo
lug_count   = 6;          // TO-82 ma 6 zavitovych segmentu na skle
lug_reach   = 1.6;        // radialni zaber ozubu pod zavit skla
lug_z       = 7.5;        // od dosedaci plochy vika ke stredu ozubu (ladit!)
lug_arc_deg = 24;         // uhlova delka ozubu
lug_h       = 4.4;        // vyska ozubu u steny

// --- Sito / deska ---
plate_t       = 2.4;
mesh_hole_d   = 1.6;      // mungo/cocka/psenice ok; na alfalfu dej 1.2
mesh_pitch    = 3.4;
center_hole_d = 14;       // stredovy otvor na zalevani
chimney_l     = 105;      // delka trubky kominu dovnitr sklenice (bez cepicky);
                          // s cepickou konci ~112 mm pod vikem = ~80 % hloubky
                          // sklenice (vyska skla 140 mm)
chimney_wall  = 1.6;
cap_h         = 7;        // vyska perforovane kuzelove cepicky na konci kominu

$fn = 128;

// --- Odvozene ---
skirt_id  = glass_thread_od + glass_clearance;
skirt_od  = skirt_id + 2 * wall;
r_id      = skirt_id / 2;
r_od      = skirt_od / 2;
lug_tip_r = glass_thread_od / 2 - lug_reach;
seal_z    = plate_t;              // dosedaci plocha na okraj sklenice
mesh_r_in  = center_hole_d / 2 + chimney_wall + 2.5;
mesh_r_out = r_id - 3;

// Vsechny spojovane objemy se prekryvaji o `eps`, aby vysledek byl
// jedno vodotesne teleso (zadne koplanarni dotyky).
eps = 0.2;

// Jeden ozub: trojuhelnikovy prstencovy segment trcici ze sukne dovnitr
module lug() {
    rotate_extrude(angle = lug_arc_deg)
        polygon([
            [ r_id + 0.4, -lug_h / 2 ],
            [ r_id + 0.4,  lug_h / 2 ],
            [ lug_tip_r,   0 ]
        ]);
}

module lugs(z_center) {
    for (i = [0 : lug_count - 1])
        rotate([ 0, 0, i * 360 / lug_count ])
            translate([ 0, 0, z_center ])
                lug();
}

// Sukne se zavitem + nabehova hrana; zacina `eps` pod dosedaci rovinou
// `sz`, aby se prekryvala s deskou pod sebou
module skirt(sz) {
    translate([ 0, 0, sz - eps ])
    difference() {
        cylinder(h = skirt_h + eps, r = r_od);
        translate([ 0, 0, -0.5 ])
            cylinder(h = skirt_h + eps + 1, r = r_id);
        // 45° nabeh na ustich sukne (horni okraj v tisku)
        translate([ 0, 0, skirt_h + eps - 1.2 ])
            cylinder(h = 1.3, r1 = r_id, r2 = r_id + 1.4);
    }
    lugs(sz + lug_z);
    // vroubkovani na uchop
    for (i = [0 : 35])
        rotate([ 0, 0, i * 10 ])
            translate([ r_od - 0.4, 0, sz - eps ])
                cylinder(h = skirt_h + eps, d = 1.8, $fn = 16);
}

// VIKO - tiskne se deskou (sitem) na podlozce, vse roste vzhuru
module lid() {
    chimney_r = center_hole_d / 2 + chimney_wall;   // 8.6
    tube_top  = seal_z + chimney_l;
    cap_z0    = tube_top - eps;                     // zacatek cepicky (prekryv)

    difference() {
        union() {
            // plna deska sita (prvni vrstvy na podlozce)
            cylinder(h = plate_t, r = r_od);
            // komin jako plny valec (vyvrt prijde globalne)
            translate([ 0, 0, seal_z - eps ])
                cylinder(h = eps + chimney_l,
                         d = center_hole_d + 2 * chimney_wall, $fn = 64);
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
                    cylinder(h = cap_h + 2, d = mesh_hole_d, $fn = 12);
        for (n = [ 0 : 6 ])
            rotate([ 0, 0, n * 360 / 7 + 18 ])
                translate([ 4, 0, cap_z0 - 0.5 ])
                    cylinder(h = cap_h + 2, d = mesh_hole_d, $fn = 12);
        for (n = [ 0 : 3 ])
            rotate([ 0, 0, n * 90 ])
                translate([ 2, 0, cap_z0 - 0.5 ])
                    cylinder(h = cap_h + 2, d = mesh_hole_d, $fn = 12);
        translate([ 0, 0, cap_z0 - 0.5 ])
            cylinder(h = cap_h + 2, d = mesh_hole_d, $fn = 12);
        // sito v desce
        for (x = [ -mesh_r_out : mesh_pitch : mesh_r_out ],
             y = [ -mesh_r_out : mesh_pitch : mesh_r_out ]) {
            r = sqrt(x * x + y * y);
            if (r > mesh_r_in && r < mesh_r_out)
                translate([ x, y, -0.5 ])
                    cylinder(h = plate_t + 1, d = mesh_hole_d, $fn = 12);
        }
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
}

if (part == "test") test_ring();
else lid();
