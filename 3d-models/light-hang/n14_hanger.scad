// ==================================================
// Závěsná koncovka pro LED profil T-LED N14
// — profil visí svisle za jeden (horní) konec
// Vnější průřez N14 ~17.4 x 8 mm — PŘEMĚŘ ŠUPLEROU!
//
// Montáž: zasunout konec profilu do kapsy, skrz
// boční díry vyvrtat 3 mm díru do hliníku a
// prostrčit šroub M3 s matkou (nese váhu napřímo).
// ==================================================

/* [Profil] */
profile_w = 17.4;    // šířka profilu (vnější)
profile_h = 8.0;     // výška/hloubka profilu (vnější)
clearance = 0.3;     // vůle na zasunutí

/* [Koncovka] */
pocket_depth = 20;   // jak hluboko profil zajede do kapsy
wall         = 2.8;  // tloušťka stěn kolem profilu
top_t        = 3.0;  // tloušťka stropu kapsy

/* [Pojistný šroub M3 napříč] */
pin_d        = 3.4;  // díra na M3 (skrz obě stěny i profil)
pin_offset   = 10;   // vzdálenost osy šroubu od ústí kapsy

/* [Průchodka kabelu] */
cable_d      = 5.0;  // šířka drážky na kabel (2x0.5 ~ 4 mm, dej rezervu)

/* [Závěsné oko] */
eye_hole_d   = 6;    // díra v oku (hák / lanko / vrut do stropu)
eye_ring_w   = 5;    // šířka materiálu kolem díry
eye_t        = 6;    // tloušťka oka

$fn = 64;

// --- odvozené ---
slot_w  = profile_w + 2*clearance;
slot_h  = profile_h + 2*clearance;
body_w  = slot_w + 2*wall;
body_h  = slot_h + 2*wall;
body_len = pocket_depth + top_t;
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

    // kapsa na profil
    translate([0, 0, -0.5])
        linear_extrude(pocket_depth + 0.5)
            square([slot_w, slot_h], center=true);

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

    // ---- průchodka kabelu ----
    // drážka skrz strop kapsy, otevřená do boku (Y+):
    // kabel se vloží z boku, žádné provlékání konektoru
    translate([-cable_d/2, slot_h/2 - 1, pocket_depth - 0.5])
        cube([cable_d, wall + 2, top_t + 1]);

    // zaoblené dno drážky, ať se kabel neláme o hranu
    translate([0, slot_h/2 - 1, pocket_depth - 0.5])
        rotate([0, 90, 0])
            cylinder(d=2, h=cable_d, center=true);
}
