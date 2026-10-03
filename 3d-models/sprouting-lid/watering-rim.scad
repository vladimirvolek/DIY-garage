// Nasazovaci nalevaci rant pro sprouting-lid-H20-mesh-1.8.stl.
// Samostatny dil, tisk v teto orientaci bez podpor, bez otaceni.
// Pri montazi objimka smeruje ke sklenici, miska ven.
// Spoj nema tesneni: jde o nalevku, ne vodotesnou nadrz.
// Rozmery odpovidaji zesilenemu viku: skirt_id=83.1, wall=3.2,
// vroubky vycnivaji o 0.5 mm na polomeru. Na jine viko uprav lid_wall.
lid_skirt_id = 83.1;
lid_wall = 3.2;
grip_projection = 0.5;
fit_clearance_d = 0.4; // diametral clearance outside grip ridges
rim_h = 8;             // usable depth above outside face of sieve
opening_d = 86;        // shoulder stays outside sieve perforations
sleeve_h = 6;
wall = 2.4;
retention = 0.30;      // radial bump; 0.20 mm diametral interference
slot_w = 1.0;
slot_count = 6;
$fn = 180;

lid_od = lid_skirt_id + 2 * lid_wall;
grip_od = lid_od + 2 * grip_projection;
sleeve_r = (grip_od + fit_clearance_d) / 2;
outer_r = sleeve_r + wall;
opening_r = opening_d / 2;
height = rim_h + sleeve_h;
assert(lid_od > opening_d && opening_d > 80);
assert(rim_h > 0 && sleeve_h >= 4 && retention > 0);
assert(retention < wall && sleeve_r - retention > opening_r);

// Radial profile: reservoir first, then wider sleeve. The horizontal
// shoulder at z=rim_h rests on the flat outside face of the lid.
// The only inward overhang is the 0.3 mm retaining bead with 45deg ramp.
difference() {
    rotate_extrude()
        polygon([
            [opening_r, 0], [outer_r, 0], [outer_r, height],
            [sleeve_r + 0.6, height],
            [sleeve_r, height - 0.6],
            [sleeve_r, rim_h + 3.4],
            [sleeve_r - retention, rim_h + 3.1],
            [sleeve_r - retention, rim_h + 2.7],
            [sleeve_r, rim_h + 2.4],
            [sleeve_r, rim_h], [opening_r, rim_h]
        ]);
    // Six flexible sleeve sections; slots stop above the reservoir seat.
    for (i = [0 : slot_count - 1])
        rotate([0, 0, i * 360 / slot_count])
            translate([opening_r, -slot_w / 2, rim_h + 0.8])
                cube([outer_r - opening_r + 1, slot_w, sleeve_h]);
}
