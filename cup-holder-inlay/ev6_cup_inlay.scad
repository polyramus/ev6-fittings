// ev6_cup_inlay.scad — ev6-fittings
// Parametric inlay for the Kia EV6 centre-console cup area (3 interconnected
// trays). Goals:
//   1. immobilise the four factory spring tabs (rattle source)
//   2. rattle-free grip for 58 mm thermos ... 66 mm 0.5 l PET in the front
//      pocket (leaf-spring tabs, both travel ends hard-stopped)
//   3. fill/flatten the remaining two trays
//
// OpenSCAD >= 2021.  Render the three fits:
//   openscad -o inlay.png      -D 'TEST_CUP="none"'    ev6_cup_inlay.scad
//   openscad -o thermos.png    -D 'TEST_CUP="thermos"' ev6_cup_inlay.scad
//   openscad -o pet.png        -D 'TEST_CUP="pet"'     ev6_cup_inlay.scad
//   openscad -o aframe_fit.png -D 'TEST_CUP="none"' -D 'SHOW_AFRAME=true' \
//                              ev6_cup_inlay.scad      // A-frame clamp in the inlay
//   (add -D 'SHOW_ENVELOPE=true' to ghost the car cavity around the inlay)
//
// Dimension provenance lives with the dimensions, in lib_geometry.scad
// (STL + top-view photo, 2026-09-09). This file keeps the grip mechanism
// parameters, the render switches, the assembly and the fit report.
//
// Coordinate system: X transverse, +X = driver side (LHD), -X = passenger;
// Y fore-aft, +Y toward the rear trays; z=0 = lower (rear) tray floor,
// z=LIFT = front pocket floor, z=H_top(y) = slanted console top.

// ================= grip mechanism =================
// Arc-segment leaf-spring tabs (see lib_parts.scad): the arm is an annular
// sector following the pocket curvature, so every feature stays inside the
// pocket; deflection is an exact rotation about the pocket centre.
CUP_MIN_D  = 58.0;   // thermos
CUP_MAX_D  = 66.0;   // 0.5 l PET body (EU standard max)
GRIP_TAB_ANG = [0, 180, 270];  // rear quadrant left clear for factory tabs
GRIP_SPAN    = 36.0;   // arm arc span (deg); lever ~ r * span = 20 mm
GRIP_ARM_R0  = 32.0;   // arm inner radius (centreline 32.6)
GRIP_ARM_T   = 1.2;    // arm radial thickness = bending direction
PRELOAD      = 0.3;    // print the pad 0.3 mm PAST the stop face: in the car
                       // the stop blocks it, so the arm is pre-stressed and
                       // the pad is always pressed home -> zero free play
GRIP_Z0      = 4.0;    // TODO: grip band bottom above pocket floor; keep the
GRIP_Z_H     = 10.0;   // pad's bottom bridge short (FDM), land on the PET
                       // 66 mm body band

// ================= render switches =================
TEST_CUP      = "thermos";  // "none" | "thermos" | "pet"
SHOW_ENVELOPE = false;
// A-frame divider fitted inside the inlay's rear (tray-2/3) void (the "inlay"
// fit from lib_aframe — the slightly-smaller clamp that cams the wall out).
// Render it alone (TEST_CUP="none"): the inlay goes translucent so the frame
// inside the rear void reads.
SHOW_AFRAME   = false;

// High-poly circles (kit convention, cf. motor-bench/cad/params.scad): the
// 74 mm pocket circle runs through offset() and CSG booleans.
$fn = 96;

include <lib_geometry.scad>
include <lib_parts.scad>
include <lib_aframe.scad>   // the A-frame divider, rendered as a fitted test object

// ================= assembly =================
// defl: render the grip arms deflected outward from the printed (empty)
// state -- 0 for a bare inlay, cup_deflection(d) to show a cup engaged.
module inlay(defl = 0) {
    union() {
        inlay_shell();
        grip_tabs(defl);
        factory_tab_bosses();   // flush-press bosses; no channels — the
                                // flaps fold behind the inlay wall (lib_parts)
    }
}

module assembly() {
    defl = TEST_CUP == "pet" ? cup_deflection(CUP_MAX_D)
           : TEST_CUP == "thermos" ? cup_deflection(CUP_MIN_D)
           : 0;
    if (SHOW_ENVELOPE) cavity_ghost();
    // Translucent inlay while the A-frame test object is inside, so the
    // band-vs-wall fit reads; the cup renders stay opaque.
    color("#b8b8b0", SHOW_AFRAME ? 0.3 : 1.0) inlay(defl);
    if (TEST_CUP != "none") test_cups();
    if (SHOW_AFRAME) color("#8a8a80") aframe("inlay");
}

assembly();

// ================= clearance / fit report =================
echo("console top: front = ", H_TOP_FRONT, " mm, rear = ", H_top(Y_T3_REAR),
     " mm, slant = ", SLANT_ANG, " deg");
echo("front pocket ID @ seat = ", 2 * (R_T1_BOT - TOL - WALL),
     " mm (STL cavity 75.07)");
echo("front pocket ID @ top  = ", 2 * (r_pocket(H_TOP_FRONT) - TOL - WALL),
     " mm (lean continued past the STL cone, see H_FRONT_MAT)");
echo("front pocket ID @ grip = ", 2 * R_PKT_GRIP, " mm (z = ", GRIP_ZC, ")");
echo("thermos radial play    = ", R_PKT_GRIP - CUP_MIN_D / 2,
     " mm/side at the grip band (closed by the pads)");
echo("PET body radial play   = ", R_PKT_GRIP - CUP_MAX_D / 2,
     " mm/side at the grip band (closed by the pads)");
echo("pad face: printed/seated = ", PAD_PRINT_R, " / ", PAD_STOP_R, " mm");
echo("thermos arm deflection = ", cup_deflection(CUP_MIN_D), " mm over L=", GRIP_LEVER);
echo("PET arm deflection     = ", cup_deflection(CUP_MAX_D), " mm over L=", GRIP_LEVER);
echo("max arm strain ~       = ", 3 * cup_deflection(CUP_MAX_D) * GRIP_ARM_T / (2 * GRIP_LEVER^2),
     " (yield ~0.02-0.05 for PLA/PETG)");
echo("total footprint length = ", Y_T3_REAR,
     " mm (front edge to passenger tip; photo read 298.9)");
