$fa = 1;
$fs = 0.05;

module base() {
    cube([5, 5, 2]);
}

module holes() {
  translate([1, 3, 0]) {
    cylinder(h = 2, r1 = 0.5, r2 = 0.5);
  }

  translate([2, 3, 0]) {
    cylinder(h = 2, r1 = 0.5, r2 = 0.5);
  }

  translate([3, 3, 0]) {
    cylinder(h = 2, r1 = 0.5, r2 = 0.5);
  }

  translate([4, 3, 0]) {
    cylinder(h = 2, r1 = 0.5, r2 = 0.5);
  }
}

difference() {
    base();
    holes();    
}