// --- Parameters ---
pipe_width      = 110;   // outer width of the pipe (cap slips over)
pipe_depth      = 55;    // outer depth of the pipe
clearance       = 1.0;   // slip-fit clearance between collar and pipe
wall_thickness  = 2;
drain_diameter  = 8;     // drain hole sized for an 8 mm hose
hose_sleeve_h   = 3;     // short inner sleeve to keep the hose vertical
rim_height      = 20;    // visibility cavity height (also the +Y opening size, the "drip window")
stop_h          = 2;     // pipe-stop shelf thickness
stop_protrusion = 2;     // inward protrusion of the stop shelf
collar_height   = 8;     // compact slip-fit overlap with the pipe

$fn = 64;

// --- Derived: outer cap dimensions (collar fits over pipe outside) ---
inner_w = pipe_width + clearance;
inner_d = pipe_depth + clearance;
outer_w = inner_w + 2 * wall_thickness;
outer_d = inner_d + 2 * wall_thickness;

// Print orientation: model is upside-down so it prints support-free.
//   z = 0 (print bed)  -> outer top of the cap (real-use top, where the roof sits)
//   +z direction       -> "downward" in real use
//
// Layer cake from the bed up:
//   [0,                                       wall_thickness]                         roof (with drain hole)
//   [wall_thickness,                          wall_thickness + rim_height]            rim wall (drip cavity, +Y open)
//   [wall_thickness + rim_height,             ... + stop_h]                           stop shelf (catches pipe top)
//   [wall_thickness + rim_height + stop_h,    ... + collar_height]                    outer collar (pipe slip-fit)
// Total cap height = wall_thickness + rim_height + stop_h + collar_height = 32 mm.
// Drip view: +Y opening is rim_height + stop_h = 22 mm tall -> >= 20 mm visibility window.

union()
{
    // 1. Roof plate -- full flat lid with a single 8 mm drain hole offset to one half so the
    //    hose hangs at the back of the cavity (clear sightline through the +Y window).
    difference()
    {
        translate([ 0, 0, wall_thickness / 2 ])
            cube([ outer_w, outer_d, wall_thickness ], center = true);

        translate([ 0, -outer_d / 4, wall_thickness / 2 ])
            cylinder(h = wall_thickness + 1, d = drain_diameter, center = true);
    }

    // 2. Rim wall -- the drip-viewing cavity. Open on the +Y long side so the falling drops
    //    are visible from the side.
    translate([ 0, 0, wall_thickness ])
    difference()
    {
        translate([ 0, 0, rim_height / 2 ])
            cube([ outer_w, outer_d, rim_height ], center = true);

        translate([ 0, 0, rim_height / 2 ])
            cube([ outer_w - 2 * wall_thickness,
                   outer_d - 2 * wall_thickness,
                   rim_height + 1 ], center = true);

        // +Y opening (the visibility window)
        translate([ 0, outer_d / 2, rim_height / 2 ])
            cube([ outer_w + 2,
                   2 * wall_thickness + 1,
                   rim_height + 1 ], center = true);
    }

    // 3. Stop shelf -- inward ledge between rim and collar; cavity smaller than the pipe outer,
    //    so the pipe top abuts here and the cap can't slide deeper. +Y stays open for visibility.
    translate([ 0, 0, wall_thickness + rim_height ])
    difference()
    {
        translate([ 0, 0, stop_h / 2 ])
            cube([ outer_w, outer_d, stop_h ], center = true);

        translate([ 0, 0, stop_h / 2 ])
            cube([ pipe_width - 2 * stop_protrusion,
                   pipe_depth - 2 * stop_protrusion,
                   stop_h + 1 ], center = true);

        translate([ 0, outer_d / 2, stop_h / 2 ])
            cube([ outer_w + 2,
                   (outer_d - pipe_depth) + 2 * stop_protrusion + 1,
                   stop_h + 1 ], center = true);
    }

    // 4. Outer collar (slip-fits over the pipe outside)
    translate([ 0, 0, wall_thickness + rim_height + stop_h ])
    difference()
    {
        translate([ 0, 0, collar_height / 2 ])
            cube([ outer_w, outer_d, collar_height ], center = true);

        translate([ 0, 0, collar_height / 2 ])
            cube([ inner_w, inner_d, collar_height + 1 ], center = true);
    }

    // 5. Hose sleeve -- short tube around the drain hole, hanging into the cavity in real use
    //    so the 8 mm hose has something to seat into and stay vertical.
    translate([ 0, -outer_d / 4, wall_thickness ])
    difference()
    {
        cylinder(h = hose_sleeve_h, d = drain_diameter + 2 * wall_thickness);
        translate([ 0, 0, -0.5 ])
            cylinder(h = hose_sleeve_h + 1, d = drain_diameter);
    }
}
