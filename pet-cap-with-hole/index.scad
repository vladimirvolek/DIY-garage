include <BOSL2/std.scad>
include <BOSL2/bottlecaps.scad>

difference() {
    
union () {
    pco1810_cap(texture="ribbed");

}
union () {
    translate([0, 0, -20])
    cylinder(h=100, r1=3.5, r2=3.5, $fn=100);
}}