// ==================================================
// Závěsná koncovka pro LED profil T-LED N14 — v2
// — profil visí svisle za jeden (horní) konec
// Vnější průřez N14 ~17.4 x 8 mm — PŘEMĚŘ ŠUPLEROU!
//
// ZMĚNY proti v1:
//  1) ZARÁŽKA (stopper) — profil nedojede až ke stropu.
//     Nad koncem profilu je teď kabelová KOMORA (mezera),
//     kde se kabel v klidu ohne. Hrana profilu už kabel
//     neskřípne.
//  2) VĚTŠÍ průchodka kabelu — stejná pozice jako ve v1
//     (skrz strop nahoře, otevřená do boku Y+), jen širší.
//
// Montáž: zasunout konec profilu do kapsy AŽ NA DORAZ,
// skrz boční díry vyvrtat 3 mm díru do hliníku a
// prostrčit šroub M3 s matkou (nese váhu napřímo).
// ==================================================

/* [Profil] */
profile_w = 17.4;    // šířka profilu (vnější)
profile_h = 8.0;     // výška/hloubka profilu (vnější)
clearance = 1;     // vůle na zasunutí

/* [Koncovka] */
insert_depth = 20;   // jak hluboko profil zajede (plná drážka) = po doraz
wall         = 2.8;  // tloušťka stěn kolem profilu
top_t        = 3.0;  // tloušťka stropu nad komorou

/* [Zarážka + kabelová komora] */
stop_ledge      = 1.4;  // přesah osazení dovnitř na každé straně (zastaví hliník)
cable_chamber_h = 6;    // mezera nad koncem profilu (odsadí hranu profilu od ohybu kabelu)

/* [Pojistný šroub M3 napříč] */
pin_d        = 3.4;  // díra na M3 (skrz obě stěny i profil)
pin_offset   = 10;   // vzdálenost osy šroubu od ústí kapsy

/* [Průchodka kabelu] */
cable_d      = 8.0;  // šířka/průměr drážky na kabel (v1 měla jen 5.0)

/* [Závěsné oko] */
eye_hole_d   = 10;    // díra v oku (hák / lanko / vrut do stropu)
eye_ring_w   = 5;    // šířka materiálu kolem díry
eye_t        = 6;    // tloušťka oka

$fn = 64;

// --- odvozené ---
slot_w   = profile_w + 2*clearance;
slot_h   = profile_h + 1/3 *clearance;
body_w   = slot_w + 2*wall;
body_h   = slot_h + 2*wall;
chamber_w = slot_w - 2*stop_ledge;   // světlost komory nad dorazem
chamber_h = slot_h - 2*stop_ledge;
body_len = insert_depth + cable_chamber_h + top_t;
eye_r_out = eye_hole_d/2 + eye_ring_w;

// ================= TĚLO =================
// Z = osa profilu (svislá), kapsa otevřená dolů (Z=0)
difference() {
    union() {
        // blok kolem kapsy, zaoblené rohy
        linear_extrude(body_len)
            offset(r=2) offset(delta=-2)
                square([body_w, body_h], center=true);

        // závěsné oko nahoře (deska s dírou, v rovině šířky profilu)
        translate([0, 0, body_len])
            rotate([90, 0, 0])
                linear_extrude(eye_t, center=true)
                    hull() {
                        translate([0, eye_r_out]) circle(r=eye_r_out);
                        translate([-eye_r_out, -0.5]) square([2*eye_r_out, 1]);
                    }
    }

    // ---- plná kapsa na profil (jen do hloubky zasunutí) ----
    translate([0, 0, -0.5])
        linear_extrude(insert_depth + 0.5)
            square([slot_w, slot_h], center=true);

    // ---- kabelová KOMORA nad dorazem (užší => vznikne osazení/zarážka) ----
    // profil dojede k osazení v Z = insert_depth a dál nemůže,
    // kabel pokračuje středem komory a ohne se v prostoru.
    translate([0, 0, insert_depth - 0.01])
        linear_extrude(cable_chamber_h + 0.02)
            square([chamber_w, chamber_h], center=true);

    // náběh u ústí kapsy (snazší zasunutí)
    translate([0, 0, -0.01])
        linear_extrude(1.5, scale=[slot_w/(slot_w+1.6), slot_h/(slot_h+1.6)])
            square([slot_w+1.6, slot_h+1.6], center=true);

    // díra na M3 napříč (skrz obě boční stěny, kolmo na šířku profilu)
    translate([0, 0, pin_offset])
        rotate([90, 0, 0])
            cylinder(d=pin_d, h=body_h + 2, center=true);

    // šestihranná kapsa na matku M3 z jedné strany (volitelné)
    translate([0, -(slot_h/2 + wall) + 1.4, pin_offset])
        rotate([90, 0, 0])
            rotate([0, 0, 30])
                cylinder(d=6.4, h=2.9, center=false, $fn=6);

    // díra v závěsném oku
    translate([0, 0, body_len + eye_r_out])
        rotate([90, 0, 0])
            cylinder(d=eye_hole_d, h=eye_t + 2, center=true);

    // ---- VĚTŠÍ průchodka kabelu (pozice jako v1) ----
    // drážka skrz strop, otevřená do boku (Y+): kabel se vloží
    // z boku, žádné provlékání konektoru. Jen širší než v1
    // (cable_d). Napojená shora na kabelovou komoru.
    translate([-cable_d/2, chamber_h/2 - 1, body_len - top_t - 0.5])
        cube([cable_d, body_h, top_t + 1]);

    // zaoblené dno drážky, ať se kabel neláme/neseká o hranu
    translate([0, chamber_h/2 - 1, body_len - top_t - 0.5])
        rotate([0, 90, 0])
            cylinder(d=3, h=cable_d, center=true);
}
