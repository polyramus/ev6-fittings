// aframe.scad — ev6-fittings / cup-holder-inlay
// Printable replacement for the factory A-frame divider (README: "The
// A-frame divider"). It stands across the front pocket — 79 across (X),
// press-fit in the cone — and its two inside supports clamp onto the two
// floor studs at 50.5 mm (factory 50 + the owner's 0.5 mm shims). Pressing
// it down cams the cone fit; the console walls bulge slightly outward and
// the three-layer passenger-side cover tensions until it stops rattling.
//
// The "A" is an ARCH in the Y-Z section: 45 base between the legs, 61
// tall, rounded top (photo "approximately 22" — modelled as the closing
// semicircle, r = 45/2 = 22.5). The factory part is injection molded;
// the shape prints fine in FDM.
//
// Render:
//   openscad -o aframe.png aframe.scad
//   openscad -o aframe_pocket.png -D 'SHOW_POCKET=true' aframe.scad
//
// ================= ASSUMED — verify in the car =================
// Everything above is measured (2026-09-10). These are not:
//   AFRAME_Y0  — where the frame sits: front face of the front leg, from
//                the pocket's front edge (y=0). Assumed so the REAR leg
//                lands on the passage-1 entry (y ~ 71). If the frame
//                actually sits in FRONT of the passage (y < 21), the
//                cutout below is not needed.
//   CUTOUT_*   — "circular cutout for the middle tray": modelled as a
//                hole through the rear leg at the passage centreline.
//                Diameter/height are guesses sized to clear the 24 mm
//                passage; measure against the real passage.
//   STUD_Y / STUD_D — floor-stud centreline (Y) and diameter.
//   WALL_T     — leg/web thickness (~4 from the photos).
// ================================================================

$fn = 96;
include <lib_geometry.scad>   // r_pocket, front_cone, cavity, C1, LIFT, TOL

AFRAME_W     = 79.0;    // across the pocket (X), the press-fit band
AFRAME_BASE  = 45.0;    // legs' span, Y (the "45 at the base")
AFRAME_H     = 61.0;    // total height above the pocket floor (Z)
AFRAME_TOP_R = AFRAME_BASE / 2;  // 22.5 — the rounded top (photo ~22)
WALL_T       = 4.0;     // ASSUMED leg/web thickness
AFRAME_Y0    = 20.0;    // ASSUMED position, see header. The frame sits in
                        // FRONT of the passage-1 entry (rear leg y 60..64,
                        // slot starts y ~66): with the rear leg ON the
                        // slot, a circular cutout cannot clear the
                        // full-height passage — the real frame either
                        // sits forward like this, or its rear-leg opening
                        // is a slot, not a circle. Measure in the car.
AFRAME_Z0    = LIFT;    // stands on the mat (pocket floor level)
SUPPORT_GAP  = 50.5;    // inner span of the two stud supports (shimmed 50)
STUD_Y       = AFRAME_Y0 + WALL_T;  // ASSUMED: under the front leg (the
                                    // photo's clamps sit at a leg corner);
                                    // if the studs are further back the
                                    // hooks must be re-anchored
STUD_D       = 5.0;     // ASSUMED stud diameter
CUTOUT_D     = 29.0;    // ASSUMED: 24 mm passage + 2.5/side
CUTOUT_ZC    = 22.0;    // ASSUMED: cutout centre above the pocket floor

SHOW_POCKET  = false;   // ghost the pocket cavity around the frame

// Arch section as a 2D profile: local x = height (Z), local y = Y.
// Straight sides to the springline, semicircular top.
module aframe_section() {
    sl = AFRAME_H - AFRAME_TOP_R;   // 39 springline
    union() {
        square([sl, AFRAME_BASE]);
        translate([sl, AFRAME_BASE / 2]) circle(d = AFRAME_BASE);
    }
}

// The solid arch, 79 across, before hollowing. Rotate -90 about Y maps
// local z -> global -x and local x -> global z, so the extrude runs -X:
// the origin sits at +AFRAME_W/2 and the section at local x=0 lands on
// global z = AFRAME_Z0.
module aframe_solid() {
    translate([AFRAME_W / 2, AFRAME_Y0, AFRAME_Z0])
        rotate([0, -90, 0])
            linear_extrude(AFRAME_W) aframe_section();
}

// Cone-following band: |x| <= r_pocket(z) - TOL over the pocket's height.
// Intersecting with this makes the 79 band hug the cone like the inlay —
// the factory part's 79 is the cone's ID at the frame's mid-height.
module cone_band() {
    front_cone(R_T1_BOT - TOL, r_pocket(90) - TOL, LIFT, 90);
}

module aframe() {
    difference() {
        intersection() {
            aframe_solid();
            cone_band();
        }
        // hollow: the same section offset in by WALL_T (the arch web).
        // Runs the full width (no cone_band applied) so it clears the
        // tapered ends; same +AFRAME_W/2 origin as aframe_solid.
        translate([AFRAME_W / 2, AFRAME_Y0 + WALL_T, AFRAME_Z0 + WALL_T])
            rotate([0, -90, 0])
                linear_extrude(AFRAME_W)
                    offset(-WALL_T) aframe_section();
        // circular cutout for the middle tray: a hole along X through the
        // rear leg, centred on the passage centreline (x = 0)
        translate([0, AFRAME_Y0 + AFRAME_BASE - WALL_T / 2,
                   AFRAME_Z0 + CUTOUT_ZC])
            rotate([0, 90, 0])
                translate([0, 0, -AFRAME_W / 2])
                    cylinder(h = AFRAME_W, d = CUTOUT_D);
        // stud supports: two C-hooks in the front leg at +/-50.5/2 — a
        // slot (STUD_D + 0.3 wide) open at the floor, cut into a small
        // block embedded in the leg. The stud drops into the slot as the
        // frame is set down; the 50.5 slot-centre span (factory 50 + the
        // owner's 0.5 shims) is what cams the cone fit when pressed down.
        for (sx = [-1, 1])
            difference() {
                translate([sx * SUPPORT_GAP / 2 - 4, STUD_Y - 2, AFRAME_Z0])
                    cube([8, 4, 14]);
                translate([sx * SUPPORT_GAP / 2 - (STUD_D + 0.3) / 2,
                           STUD_Y - 2, AFRAME_Z0])
                    cube([STUD_D + 0.3, 6, 10]);
            }
    }
}

if (SHOW_POCKET)
    color("gray", 0.25) cavity();
color("#b0b0a8") aframe();

echo("aframe: 79 x 61 x 45, top r", AFRAME_TOP_R,
     ", supports ", SUPPORT_GAP, ", y0 ", AFRAME_Y0,
     ", cutout D", CUTOUT_D, " @ z", AFRAME_Z0 + CUTOUT_ZC);
