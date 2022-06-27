$fn = 360;
yc = 250;
x0 = 200;
wall = 30;
or = 150;
ir = or - wall;

function sqr(x) = x * x;
xc = (sqr(yc) + sqr(x0)) / (2 * x0);

rotate_extrude()
    translate([ir, 0])
        intersection() {
            difference() {
                square([x0 + wall, yc]);
                translate([xc + wall, yc]) circle(xc);
            }
            translate([xc + wall, yc]) circle(xc + wall);
    }