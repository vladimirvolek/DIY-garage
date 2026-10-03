// Vykrajovátko na těsto – labuť
// Render: openscad -o swan-cutter.stl swan-cutter.scad

L        = 90;    // délka labutě (od ocasu ke zobáku) [mm]
blade_h  = 14;    // výška břitu
blade_t  = 0.8;   // tloušťka břitu
flange_h = 4;     // výška horní příruby
flange_t = 3.5;   // šířka příruby

$fn = 96;
s = L / 100;      // vnitřní jednotky: labuť je nakreslená na ~100 mm

// řetěz kruhů podél křivky -> hladká "trubice" (krk)
module tube(pts, r) {
    for (i = [0 : len(pts) - 2])
        hull() {
            translate(pts[i])   circle(r = r[i]);
            translate(pts[i+1]) circle(r = r[i+1]);
        }
}

// kvadratická Bézierova křivka
function bez(p0, p1, p2, t) = (1-t)*(1-t)*p0 + 2*(1-t)*t*p1 + t*t*p2;

module swan2d() {
    scale(s)
    offset(r = -0.8) offset(r = 0.8)      // closing – zahladí mikro-zářezy
    union() {
        // tělo
        translate([42, 22]) scale([1, 0.55]) circle(r = 40);
        // ocas – nahoru zahnutá špička
        hull() {
            translate([10, 30]) circle(r = 6);
            translate([-2, 48]) circle(r = 1.5);
        }
        // hrudník / přechod do krku
        translate([70, 30]) circle(r = 12);
        // krk – esíčko: nahoru dopředu, pak lehce dozadu k hlavě
        n = 12;
        pts = [ for (i = [0 : n]) bez([72, 34], [96, 58], [80, 88], i / n) ];
        rad = [ for (i = [0 : n]) 7.5 - 4 * i / n ];
        tube(pts, rad);
        // hlava
        translate([79, 89]) circle(r = 5.5);
        // zobák
        hull() {
            translate([83, 88.5]) circle(r = 2.6);
            translate([96, 84]) circle(r = 0.9);
        }
    }
}

module cutter() {
    linear_extrude(blade_h)
        difference() { offset(r = blade_t) swan2d(); swan2d(); }
    translate([0, 0, blade_h - flange_h])
    linear_extrude(flange_h)
        difference() { offset(r = flange_t) swan2d(); swan2d(); }
}

cutter();
