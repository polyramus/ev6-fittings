// aframe.scad — ev6-fittings / cup-holder-inlay
// Standalone preview of the A-frame divider. The geometry lives in
// lib_aframe.scad (shared with ev6_cup_inlay.scad, where the same frame also
// renders as a fitted test object inside the inlay); this file only picks a
// fit and renders it.
//
// The frame stands across the front pocket: 79 across (X), the arch in the
// Y-Z section (45 base, 61 tall, rounded ~22 top). Two inside C-hook
// supports clamp the two floor studs at 50.5 (factory 50 + the owner's
// 0.5 shims); pressing it down cams the fit and tensions the three-layer
// passenger-side cover. See lib_aframe for the dimensions and the ASSUMED
// list (verify in the car).
//
// Fit (AFRAME_FIT):
//   "car"   — the factory-style part: press-fit in the BARE pocket, standing
//             on the mat (z = LIFT).
//   "inlay" — the NEW slightly-smaller clamp: fits INSIDE the printed inlay's
//             void and pushes the inlay wall outward to strain the console.
//             AFRAME_CLEAR is the radial gap to the inlay wall — positive =
//             slip fit (drops in, clean render), negative = press fit (wedges
//             in and strains the console; print a small negative value).
//
// Render:
//   openscad -o aframe.png        aframe.scad                 // inlay fit, inlay shown
//   openscad -o aframe_car.png    -D 'AFRAME_FIT="car"' -D 'SHOW_INLAY=false' aframe.scad
//   (add -D 'SHOW_POCKET=true' to ghost the car cavity)

$fn = 96;
include <lib_geometry.scad>   // r_pocket, front_cone, cavity, LIFT, TOL, WALL, STUD_*
include <lib_aframe.scad>     // aframe(fit), aframe_*() helpers

AFRAME_FIT   = "inlay";   // "car" | "inlay"
SHOW_POCKET  = false;     // ghost the car cavity
SHOW_INLAY   = true;      // the printed inlay the "inlay" fit lives inside

if (SHOW_POCKET)
    color("gray", 0.25) cavity();
if (SHOW_INLAY)
    color("#d8d8d0", 0.35) inlay_shell();
color("#b0b0a8") aframe(AFRAME_FIT);

echo("aframe (", AFRAME_FIT, "): 79 x ", aframe_h(AFRAME_FIT),
     " x 45, y0 ", AFRAME_Y0, ", z0 ", aframe_z0(AFRAME_FIT),
     ", band off ", aframe_off(AFRAME_FIT), " from the pocket wall");
