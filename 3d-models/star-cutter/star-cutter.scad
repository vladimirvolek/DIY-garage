// Vykrajovátko na těsto – hvězdice s čočkovitými cípy (jako na vánočce / mazanci)
// Render: openscad -D 'part="big"' -o star-big.stl star-cutter.scad
//         openscad -D 'part="small"' -o star-small.stl star-cutter.scad

part = "big";          // "big" (12 cípů) | "small" (6 cípů)

// --- rozměry hvězdy ---
D        = (part == "big") ? 100 : 45;   // celkový průměr hvězdy [mm]
petals   = (part == "big") ? 10  : 6;    // počet cípů
petal_w  = D * 0.11;                     // šířka cípu v nejširším místě
r_inner  = D * 0.03;                     // odkud cípy startují (překryv u středu)
hub_r    = D * 0.10;                     // střední kolečko, aby bylo vše spojené

// --- vykrajovátko ---
blade_h  = 14;    // výška břitu
blade_t  = 0.8;   // tloušťka břitu (2 perimetry 0.4)
flange_h = 4;     // výška horní příruby (na zatlačení)
flange_t = 3.5;   // šířka příruby

$fn = 96;

// čočka (pointed lens): délka L, šířka W, ležící na ose X od 0 do L
module lens(L, W) {
    a = L / 2; b = W / 2;
    R = (a*a + b*b) / (2*b);       // poloměr oblouků
    translate([a, 0])
    intersection() {
        translate([0,  R - b]) circle(r = R, $fn = 256);
        translate([0, -(R - b)]) circle(r = R, $fn = 256);
    }
}

module star2d() {
    // closing (offset +/-) zahladí mikro-zářezy tam, kde cípy protínají střední kolečko
    offset(r = -1) offset(r = 1) union() {
        circle(r = hub_r);
        for (i = [0 : petals - 1])
            rotate(i * 360 / petals)
                translate([r_inner, 0]) lens(D/2 - r_inner, petal_w);
    }
}

module cutter() {
    // břit
    linear_extrude(blade_h)
        difference() { offset(r = blade_t) star2d(); star2d(); }
    // příruba nahoře
    translate([0, 0, blade_h - flange_h])
    linear_extrude(flange_h)
        difference() { offset(r = flange_t) star2d(); star2d(); }
}

cutter();
