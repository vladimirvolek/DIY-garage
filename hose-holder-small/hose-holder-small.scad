difference() {
    union() {
        width=20;
        cube(size=[11,width,3]);
        
        translate([0, 0, 3])
        cube(size=[3,width,3.1]);

        translate([0, 0, 6.1])
        cube(size=[28,width, 3]);
    }
    union () {
        translate([21, 10, 0])
        cylinder(h=35, r=3.5, center=false, $fn=100);
    }
}