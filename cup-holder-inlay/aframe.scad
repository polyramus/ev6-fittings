// aframe.scad — ev6-fittings / cup-holder-inlay
// Standalone preview of the A-frame divider. The geometry lives in
// lib_aframe.scad (shared with ev6_cup_inlay.scad, where the same frame also
// renders as a fitted test object inside the inlay); this file only picks a
// fit and renders it.
//
// The A-frame is a SOLID SAWBUCK (an extruded "A" with the counter filled):
// 79 wide in X (spans the tray), 45 deep in Y (the base), 61 tall in Z, apex
// up. It stands at the tray-2/tray-3 boundary; a circular cutout on one side
// lets a bottle sit in tray 2. See lib_aframe for the dimensions and the
// ASSUMED list (verify in the car).
//
// Fit (AFRAME_FIT):
//   "car"   — the factory-style part: 79 wide, standing on the rear-tray
//             floor (z=0), press-fitting the bare car tray.
//   "inlay" — the NEW slightly-smaller divider: fits inside the printed
//             inlay's tray-2/3 void and pushes the inlay wall outward to
//             strain the console.
//
// Render:
//   openscad -o aframe.png        aframe.scad                 // inlay fit, inlay shown
//   openscad -o aframe_car.png    -D 'AFRAME_FIT="car"' -D 'SHOW_INLAY=false' aframe.scad
//   (add -D 'SHOW_POCKET=true' to ghost the car cavity)

$fn = 96;
include <lib_geometry.scad>   // TOL, WALL, inlay_shell, cavity, tray-2/3 Y layout
include <lib_aframe.scad>     // aframe(fit), aframe_solid, aframe_z0

AFRAME_FIT   = "inlay";   // "car" | "inlay"
SHOW_POCKET  = false;     // ghost the car cavity
SHOW_INLAY   = true;      // the printed inlay the "inlay" fit lives inside

if (SHOW_POCKET)
    color("gray", 0.25) cavity();
if (SHOW_INLAY)
    color("#d8d8d0", 0.35) inlay_shell();
color("#b0b0a8") aframe(AFRAME_FIT);

echo("aframe (", AFRAME_FIT, "): 79 x 61 x 45 sawbuck, y0 ", AFRAME_Y0,
     ", z0 ", aframe_z0(AFRAME_FIT));
