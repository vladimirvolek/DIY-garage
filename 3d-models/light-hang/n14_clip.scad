// ============================================
// Nacvakávací úchyt pro LED profil T-LED N14
// (nástupce N8, vnější průřez ~17.4 x 8 mm)
// ============================================

/* [Profil] */
profile_w = 17.4;   // šířka profilu (vnější)
profile_h = 8.0;    // výška profilu (vnější)
clearance = 0.25;   // vůle na stranu (PETG ~0.25, PLA ~0.2)

/* [Spona] */
clip_len  = 12;     // délka spony podél profilu
wall      = 2.0;    // tloušťka bočních stěn
base_t    = 2.4;    // tloušťka dna (pod profilem)
lip       = 1.3;    // jak hluboko pacička přesahuje přes přední hranu
lip_t     = 1.6;    // tloušťka pacičky
chamfer   = 1.2;    // náběh na pacičce pro snadné zacvaknutí

/* [Šroub] */
screw_d   = 3.8;    // průměr díry (vrut 3.5)
head_d    = 7.5;    // průměr zahloubení hlavy
head_h    = 2.0;    // hloubka kuželového zahloubení

/* [Kvalita] */
$fn = 48;

// --- odvozené rozměry ---
slot_w = profile_w + 2*clearance;          // vnitřní šířka drážky
slot_h = profile_h + 0.15;                 // vnitřní výška drážky
total_w = slot_w + 2*wall;
total_h = base_t + slot_h + lip_t;

difference() {
    // tělo: 2D průřez vytažený do délky
    linear_extrude(clip_len)
        body_profile();

    // díra na vrut + kuželové zahloubení (zespodu skrz dno)
    translate([0, 0, clip_len/2]) rotate([-90, 0, 0]) {
        translate([0, 0, -1])
            cylinder(d = screw_d, h = base_t + 2);
        // záhlub uvnitř drážky (šroubuje se zevnitř, hlava pod páskem)
        translate([0, 0, base_t - head_h])
            cylinder(d1 = screw_d, d2 = head_d, h = head_h + 0.01);
    }
}

module body_profile() {
    // souřadnice: X = šířka, Y = výška; dno dole
    union() {
        // dno
        translate([-total_w/2, 0])
            square([total_w, base_t]);
        // boční stěny
        for (s = [-1, 1])
            translate([s > 0 ? slot_w/2 : -slot_w/2 - wall, 0])
                square([wall, base_t + slot_h + lip_t]);
        // pacičky s náběhem
        for (s = [-1, 1])
            mirror([s < 0 ? 1 : 0, 0])
                polygon([
                    [slot_w/2,            base_t + slot_h + lip_t],
                    [slot_w/2 - lip,      base_t + slot_h + lip_t],
                    [slot_w/2 - lip + chamfer*0.4, base_t + slot_h + lip_t - lip_t],
                    [slot_w/2,            base_t + slot_h]
                ]);
    }
}
