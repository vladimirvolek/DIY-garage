difference()
{
    union()
    {
        width = 40;
        height = 11;

        cube(size = [ 30, width, height ]);

        translate([ 0, width - 5, 0 ]) cube(size = [ 30, 5, 35 ]);

       
    }
    union()
    {
        width = 20;
        height = 1;

        translate([ 0, 0, 5 ]) cube(size = [ 40, width, height ]);
    }
    union () {
        translate([ 15, 20, 25 ])
        rotate([ 0, 90, 90 ])
        cylinder(h = 35, r = 3.6, center = false, $fn = 100);
    }
}
