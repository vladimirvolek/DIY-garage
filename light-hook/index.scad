
    union() {
        width=15;
        cube(size=[11,width,2.9]);

        translate([0, 0, 2])
        cube(size=[3,width,4]);
        
        translate([0, 0, 6])
        cube(size=[28,width, 3]);
    }
    union () {
        translate([22, 7.5, 0])
        cylinder(h=9, r=2.5, center=false, $fn=100);
    }
    