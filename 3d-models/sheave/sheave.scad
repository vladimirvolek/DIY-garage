difference() {
    union() {
        difference () {
            union() {
            cylinder(h=14, r1=12.5, r2=12.5, $fn=300);
            }
            union () {
                translate([0, 0, -10])
                cylinder(h=100, r1=3, r2=3  , $fn=300);
            }
        }
      
    }
     union () {
            rotate_extrude(convexity = 20, $fn = 150)
            translate([12.5, 7, 0])
            circle(r = 4, $fn = 100);
        }
    
}