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
//   (add -D 'SHOW_ENVELOPE=true' to ghost the car cavity around the inlay)
//
// Dimensions are calipered by the owner 2026-09-09 unless marked TODO.
// "width" = X (transverse, +X passenger/LHD right), "length" = Y (fore-aft,
// +Y toward the rear), z=0 = lower (rear) tray floor, z=LIFT = front floor.

// ================= known dimensions =================
LIFT       = 8.0;     // front tray + passage 1 elevated this much
R_T1       = 37.0;    // front tray bottom radius (74 dia TPU inlay)
P1_W       = 24.0;    // passage 1 width
P1_L       = 32.0;    // passage 1 length
T2_W       = 75.0;    // tray 2 max width
T2_EXP_L   = 35.0;    // tray 2 expansion length (24 -> 75)
T2_RECT_L  = 25.0;    // tray 2 rectangular tail length
P2_W       = 51.0;    // passage 2 width
P2_L       = 37.5;    // passage 2 length
T3_W_FRONT = 71.0;    // tray 3 width at front
T3_W_REAR  = 69.5;    // tray 3 width after taper
T3_TAPER_L = 24.0;    // tray 3 taper length

// ================= TODO: measure these =================
H_DEPTH    = 45.0;   // TODO: console surface -> lower-tray floor
L_T2_CONN  = 15.0;   // TODO: length of tray 2's 24 mm connector section
L_T3_END_L = 10.0;   // TODO: tray 3 rear end length, driver side
L_T3_END_R = 25.0;   // TODO: tray 3 rear end length, passenger side
R_T3_CORNER= 8.0;    // TODO: tray 3 passenger corner radius
TAB1_ANG   = [64, 116];   // TODO: factory tab angles, front pocket (deg)
TAB2_POS   = [[-10, 108], [10, 108]]; // TODO: factory tab XY, tray 2 front
BOSS_W     = 14.0;   // TODO: trap boss width  (match tab width + play)
BOSS_LEN   = 6.0;    // TODO: trap boss depth into pocket
TAB_CH_W   = 10.0;   // TODO: channel width  (tab width + ~0.4)
TAB_CH_D   = 4.0;    // TODO: channel depth  (tab thickness + ~0.4)

// ================= inlay / print =================
WALL       = 2.0;    // inlay wall thickness
TOL        = 0.15;   // fit clearance per side vs the car (FDM)
X_CLIP     = 80.0;   // internal clip for the footprint slabs (keep > T2_W/2)

// ================= grip mechanism =================
// Arc-segment leaf-spring tabs (see lib_parts.scad): the arm is an annular
// sector following the pocket curvature, so every feature stays inside the
// pocket; deflection is an exact rotation about the pocket centre.
CUP_MIN_D  = 58.0;   // thermos
CUP_MAX_D  = 66.0;   // 0.5 l PET body (EU standard max)
GRIP_TAB_ANG = [0, 180, 270];  // rear quadrant left clear for factory tabs
GRIP_SPAN    = 36.0;   // arm arc span (deg); lever ~ r * span = 20 mm
GRIP_ARM_R0  = 31.0;   // arm inner radius (centreline 31.6)
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

// High-poly circles (kit convention, cf. motor-bench/cad/params.scad): the
// 74 mm pocket circle runs through offset() and CSG booleans.
$fn = 96;

include <lib_geometry.scad>
include <lib_parts.scad>

// ================= assembly =================
// defl: render the grip arms deflected outward from the printed (empty)
// state -- 0 for a bare inlay, cup_deflection(d) to show a cup engaged.
module inlay(defl = 0) {
    difference() {
        union() {
            inlay_shell();
            grip_tabs(defl);
            factory_tab_bosses();   // solid bosses (channels cut below)
        }
        factory_tab_channels();     // open the trap channels
    }
}

module assembly() {
    defl = TEST_CUP == "pet" ? cup_deflection(CUP_MAX_D)
           : TEST_CUP == "thermos" ? cup_deflection(CUP_MIN_D)
           : 0;
    if (SHOW_ENVELOPE) cavity_ghost();
    color("#b8b8b0") inlay(defl);
    if (TEST_CUP != "none") test_cups();
}

assembly();

// ================= clearance / fit report =================
echo("front pocket ID          = ", 2 * R_POCKET, " mm");
echo("thermos radial play      = ", R_POCKET - CUP_MIN_D / 2, " mm/side (grip closes it)");
echo("PET body radial play     = ", R_POCKET - CUP_MAX_D / 2, " mm/side (grip closes it)");
echo("pad face: printed/seated = ", PAD_PRINT_R, " / ", PAD_STOP_R, " mm");
echo("thermos arm deflection   = ", cup_deflection(CUP_MIN_D), " mm over L=", GRIP_LEVER);
echo("PET arm deflection       = ", cup_deflection(CUP_MAX_D), " mm over L=", GRIP_LEVER);
echo("max arm strain ~         = ", 3 * cup_deflection(CUP_MAX_D) * GRIP_ARM_T / (2 * GRIP_LEVER^2),
     " (yield ~0.02-0.05 for PLA/PETG)");
echo("total footprint length   = ", Y_T3_REAR, " mm (front edge to passenger corner)");
