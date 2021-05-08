difference() {
    union() {
        width=15;
        cube(size=[11,width,3]);

        translate([0, 0, 3])
        cube(size=[3,width,2.9]);
        
        translate([0, 0, 5.9])
        cube(size=[23,width, 3]);
    }
    union () {
        translate([17, 7.5, 0])
        cylinder(h=35, r=3.5, center=false, $fn=100);
    }
}