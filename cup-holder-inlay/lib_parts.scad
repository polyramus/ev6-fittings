// lib_parts.scad — ev6-fittings / cup-holder-inlay
// Moving features: the rattle-free grip mechanism, factory spring-tab traps,
// and the test cups.
//
// All modules assume the coordinate system and parameters from the main file
// (see ev6_cup_inlay.scad). +X = driver side (LHD), +Y = rearward. z=0 is the
// lower-tray floor; the front pocket floor is at z = LIFT + WALL and its
// centre is C1. The front pocket wall is CONICAL (see lib_geometry.r_pocket).

// ---------- grip mechanism (frontmost pocket) ----------
//
// Three arc-segment leaf-spring tabs at 0 deg (+X, driver), 180 deg (-X,
// passenger) and 270 deg (-Y, front of the car). The rear quadrant
// (~90 deg, +Y, where the passage meets the circle) is deliberately left
// clear for the two trapped factory tabs.
//
// Each tab, in a local frame with the pocket centre at the origin and the
// tab axis along +X (all geometry follows the pocket's curvature, so
// nothing can poke through the circular wall):
//   base   annular sector fused into the pocket wall
//   arm    annular sector (the leaf spring), ~21 mm lever along the arc,
//          1.2 mm thick radially (the bending direction)
//   pad    small sector at the arm's free end; inner face grips the cup
//   stop   radial sector on the wall; the pad's inner face is printed
//          PRELOAD past its face, so in the car the arm is pre-stressed
//          and the pad is always pressed home -> zero free play, no rattle
//
// A cup rotates the arm+pad outward about the pocket centre (exact arc):
//   58 mm thermos -> 0.6 mm from the printed shape
//   66 mm PET     -> 4.6 mm, ~2 % strain in a 1.2 mm PLA/PETG arm
// Both ends of travel are hard stops (stop sector / cup), so no rattle.

C1         = [0, Y_C1_CENTER];

// Inner (void) radius of the pocket wall at height z — the wall is conical.
function wall_in(z) = r_pocket(z) - WALL - TOL;

GRIP_ZC      = LIFT + WALL + GRIP_Z0 + GRIP_Z_H / 2;  // grip band mid-height
R_PKT_GRIP   = wall_in(GRIP_ZC);                      // ~36.0 at z=19
GRIP_ARM_R1  = GRIP_ARM_R0 + GRIP_ARM_T;              // arm outer radius (33.2)
PAD_STOP_R   = CUP_MIN_D / 2 - PRELOAD;               // pad + stop face, seated empty
PAD_PRINT_R  = PAD_STOP_R - PRELOAD;                  // pad face in the PRINTED shape
PAD_R1       = GRIP_ARM_R0 + 0.3;                     // pad outer radius (overlaps arm)
GRIP_PAD_A0  = GRIP_SPAN - 6.0;                       // pad sector, deg
GRIP_PAD_A1  = GRIP_SPAN + 2.0;
GRIP_STOP_A0 = GRIP_SPAN - 4.5;                       // stop sector, deg
GRIP_STOP_A1 = GRIP_SPAN + 0.5;
GRIP_BASE_A0 = -3.0;                                  // base sector, deg
GRIP_BASE_A1 = 7.0;
PAD_CENTRE_R = (PAD_PRINT_R + PAD_R1) / 2;            // ~30 mm, for deflection->angle

// Annular sector between radii r0..r1 and angles a0..a1 (deg), h tall from
// z=0. Built with rotate_extrude (exact arc, no chord error).
module arc_block(r0, r1, a0, a1, h) {
    rotate(a0)
        rotate_extrude(a1 - a0)
            translate([r0, 0, 0]) square([r1 - r0, h], center = false);
}

// Outward angle (deg) for a given outward deflection (mm) at the pad.
function defl_ang(defl) = defl / PAD_CENTRE_R * 180 / PI;

// One grip tab. `ang`: tab position angle (deg, 0 = +X, 90 = +Y/rear).
// `defl`: outward deflection of the pad from the PRINTED shape (0 = as
// printed; PRELOAD = seated empty against the stop; cup = gripping).
module grip_tab(ang, defl = 0) {
    translate(C1) rotate(ang) {
        // base, fused into the wall (embedded 0.5)
        arc_block(GRIP_ARM_R1, R_PKT_GRIP + 0.5, GRIP_BASE_A0, GRIP_BASE_A1, GRIP_Z_H);
        // stop: inner face at PAD_STOP_R, hard stop under the pad
        arc_block(PAD_STOP_R, R_PKT_GRIP + 0.5, GRIP_STOP_A0, GRIP_STOP_A1, GRIP_Z_H);
        // arm + pad: printed with the pad face at PAD_PRINT_R (PRELOAD past
        // the stop); rotate outward by the deflection angle
        rotate(defl_ang(defl))
            union() {
                arc_block(GRIP_ARM_R0, GRIP_ARM_R1, 0, GRIP_SPAN, GRIP_Z_H);
                arc_block(PAD_PRINT_R, PAD_R1, GRIP_PAD_A0, GRIP_PAD_A1, GRIP_Z_H);
            }
    }
}

module grip_tabs(defl = 0) {
    translate([0, 0, LIFT + WALL + GRIP_Z0])
        for (a = GRIP_TAB_ANG) grip_tab(a, defl);
}

// ---------- factory spring-tab traps ----------
//
// The four factory spring tabs (2 in the rear of the front pocket at ~45
// deg each side of the passage, 2 in tray 2) are spring flaps 7.5 wide x
// 30 tall in wall openings: pivot near the top, 14 mm of free-end travel,
// folding fully into the wall when pressed — which is exactly what the
// inlay's flush-press bosses force them to do, so they cannot rattle.
// (The white lines in photo IMG_5345 are duct-tape residue from the
// owner's earlier makeshift fastening, not damage.)
//
// Front pocket (curved wall): a flush-press boss covers the opening — a
// tapered plate following the cone, its face TAB_SEAT (0.2 mm) in front of
// the console wall face. The flap is trapped behind the inlay wall, so the
// boss face is all it needs: the folded flap can only bulge 0.2 mm instead
// of its 14 mm travel. No channel is cut in the inlay for these.
//
// Tray 2 (the 75->51 step faces at y=Y_T2_REAR, facing -Y): no feature
// needed. The inlay's rear wall is an offset band that runs full height
// over those faces, so the band's own face (TOL = 0.15 mm in front of the
// car face) is the flush-press limiter: a folded flap (flush with the car
// face) can only bulge 0.15 mm. The tabs sit 38 mm above the tray-2 floor
// (= the same absolute height as the front-pocket tabs, user 2026-09-10),
// centred on the 12 mm step ledge (x = +/-31.5, the mat notch pair),
// flaps tilted 45 deg toward each other — an X seen from above.

// Tapered annular-sector ring between z0..z1, following the conical pocket
// wall: outer face at wall_in(z) + r_off1, inner at wall_in(z) + r_off0.
// hull of two thin sectors -> the faces stay parallel to the wall at every
// height (a fixed-radius boss would poke through the lean at one end).
module trap_tapered(a0, a1, z0, z1, r_off0, r_off1) {
    hull() {
        translate([0, 0, z0])
            arc_block(wall_in(z0) + r_off0, wall_in(z0) + r_off1, a0, a1, 0.8);
        translate([0, 0, z1 - 0.8])
            arc_block(wall_in(z1) + r_off0, wall_in(z1) + r_off1, a0, a1, 0.8);
    }
}

// p: a point on the inner wall face (XY) of the front-pocket cone. The
// boss is added to the inlay union; no channel is cut — the flap folds
// behind the inlay wall, out of the cavity.
module factory_tab_boss(p, z0, h) {
    // flush-press boss over the TAB_W x TAB_H wall opening, following
    // the cone: face at r_pocket - TAB_SEAT (0.2 mm in front of the
    // console wall face, i.e. WALL + TOL - TAB_SEAT out from the
    // inlay's inner face — just short of the inlay outer surface),
    // embedded 2 mm in the inlay wall
    a = atan2(p[1] - C1[1], p[0] - C1[0]);
    aw = (TAB_W / 2 + BOSS_MARGIN) / wall_in(TAB1_ZMID) * 180 / PI;
    z0t = max(LIFT + TAB1_Z0 - BOSS_MARGIN, LIFT + 0.2);
    z1t = LIFT + TAB1_Z0 + TAB_H + BOSS_MARGIN;
    translate(C1) rotate(a)
        trap_tapered(-aw, aw, z0t, z1t, -2.0, WALL + TOL - TAB_SEAT);
}

// Mid-height of the front-pocket tab boss (for the representative wall
// radius — the boss itself tapers with the cone, see trap_tapered).
TAB1_ZMID = LIFT + TAB1_Z0 + TAB_H / 2;   // 53

// Points on the front pocket wall (cone) for the two rear factory tabs.
function c1_wall_point(ang) =
    C1 + wall_in(TAB1_ZMID) * [cos(ang), sin(ang)];

// [point, z0, h] for the two front-pocket tabs. The tray-2 tabs need no
// feature — the inlay wall band over the step faces covers them (see the
// tray-2 note at the top of this section).
function trap_positions() =
    [for (a = TAB1_ANG) [c1_wall_point(a), LIFT, H_TOP_FRONT - LIFT]];

module factory_tab_bosses() {
    for (t = trap_positions())
        factory_tab_boss(t[0], t[1], t[2]);
}

// ---------- test cups ----------
//
// Stand-ins for the two cups the front pocket must grip, sitting on the
// front pocket floor. Rendered translucent so the mechanism shows through.
// CUP_MIN_D (58) thermos: plain cylinder.
// CUP_MAX_D (66) 0.5 l PET: EU PET bottles share ~66 mm max body diameter;
// real bottles have a smaller bottom (~58-60) that flares into the body --
// modelled here as a short flare so the grip band lands on the 66 mm body.

module test_thermos() {
    color("steelblue", 0.35)
        translate(C1) cylinder(h = 90, d = CUP_MIN_D);
}

module test_pet() {
    color("darkgreen", 0.35)
        translate(C1)
            union() {
                // bottom + flare (placeholder profile, TODO: measure the
                // actual bottle)
                hull() {
                    cylinder(h = 1, d = CUP_MIN_D);
                    translate([0, 0, 18]) cylinder(h = 1, d = CUP_MAX_D);
                }
                // 66 mm body
                translate([0, 0, 18]) cylinder(h = 70, d = CUP_MAX_D);
            }
}

// Cups sit on the front pocket floor. The mechanism itself is rendered by
// the assembly at the matching deflection (see ev6_cup_inlay.scad).
module test_cups() {
    translate([0, 0, LIFT + WALL]) {
        if (TEST_CUP == "thermos") test_thermos();
        if (TEST_CUP == "pet") test_pet();
    }
}

// Outward deflection of the grip arms (from the PRINTED shape) for a cup of
// diameter d at the grip band.
function cup_deflection(d) = d / 2 - PAD_PRINT_R;

// Arc lever length of the arm (for the strain estimate).
GRIP_LEVER = (GRIP_ARM_R0 + GRIP_ARM_T / 2) * GRIP_SPAN * PI / 180;  // ~21
