$fa = 10;
$fs = 0.5;

base_width = 160;
base_height = 60;
base_thickness = 20;

side_width = 30;
side_height = base_height;
side_thickness = 40;

module base()
{
    // base cube
    cube([ base_width, base_height, base_thickness ]);

    // left side
    translate([ 0, 0, base_thickness ]) cube([ side_width, side_height, side_thickness ]);

    // right side
    translate([ base_width - side_width, 0, base_thickness ]) cube([ side_width, side_height, side_thickness ]);
}

module hole_at_position(x, y)
{
    translate([ x, y, 0 ])
    {
        cylinder(h = 20, r = 4.2);
    }
}

module hole_through_sides(x, z)
{
    translate([ 0, base_height / 2, 40 ]) rotate([ 0, 90, 0 ])
    {
        cylinder(h = base_width, r = 6); // Extended height to pass through both sides
    }
}

module holes()
{
    spacing = 17.5;
    center_x = base_width / 2;
    center_y = base_height / 2;

    hole_at_position(center_x - spacing, center_y - spacing);
    hole_at_position(center_x + spacing, center_y - spacing);
    hole_at_position(center_x - spacing, center_y + spacing);
    hole_at_position(center_x + spacing, center_y + spacing);
}

difference()
{
    base();
    holes();
    hole_through_sides();
}