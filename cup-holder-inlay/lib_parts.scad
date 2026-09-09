// lib_parts.scad — ev6-fittings / cup-holder-inlay
// Moving features: the rattle-free grip mechanism, factory spring-tab traps,
// and the test cups.
//
// All modules assume the coordinate system and parameters from the main file
// (see ev6_cup_inlay.scad). z=0 is the lower-tray floor; the front pocket
// floor is at z = LIFT + WALL and its centre is C1.

// ---------- grip mechanism (frontmost pocket) ----------
//
// Three arc-segment leaf-spring tabs at 0 deg (+X, passenger), 180 deg
// (-X, driver) and 270 deg (-Y, front of the car). The rear quadrant
// (~90 deg, +Y, where the passage meets the circle) is deliberately left
// clear for the two trapped factory tabs.
//
// Each tab, in a local frame with the pocket centre at the origin and the
// tab axis along +X (all geometry follows the pocket's curvature, so
// nothing can poke through the circular wall):
//   base   annular sector fused into the pocket wall
//   arm    annular sector (the leaf spring), ~20 mm lever along the arc,
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

C1         = [0, Y_C1_CENTER];                 // pocket centre (XY)
R_POCKET   = R_T1 - WALL - TOL;                // pocket inner radius (34.85)
GRIP_ARM_R1  = GRIP_ARM_R0 + GRIP_ARM_T;       // arm outer radius (32.2)
PAD_STOP_R   = CUP_MIN_D / 2 - PRELOAD;        // pad + stop face, seated empty
PAD_PRINT_R  = PAD_STOP_R - PRELOAD;           // pad face in the PRINTED shape
PAD_R1       = GRIP_ARM_R0 + 0.3;              // pad outer radius (overlaps arm)
GRIP_PAD_A0  = GRIP_SPAN - 6.0;                // pad sector, deg
GRIP_PAD_A1  = GRIP_SPAN + 2.0;
GRIP_STOP_A0 = GRIP_SPAN - 4.5;                // stop sector, deg
GRIP_STOP_A1 = GRIP_SPAN + 0.5;
GRIP_BASE_A0 = -3.0;                           // base sector, deg
GRIP_BASE_A1 = 7.0;
PAD_CENTRE_R = (PAD_PRINT_R + PAD_R1) / 2;     // ~30 mm, for deflection->angle

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
        arc_block(GRIP_ARM_R1, R_POCKET + 0.5, GRIP_BASE_A0, GRIP_BASE_A1, GRIP_Z_H);
        // stop: inner face at PAD_STOP_R, hard stop under the pad
        arc_block(PAD_STOP_R, R_POCKET + 0.5, GRIP_STOP_A0, GRIP_STOP_A1, GRIP_Z_H);
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
// The four factory spring tabs (2 at the rear of the front pocket, 2 at the
// front of tray 2) are immobilised by local bosses with closed channels.
// The tab sits in the channel; inlay material on all sides removes its free
// play -> no rattle.
//
// TODO: boss/channel sizes and tab positions are PLACEHOLDERS -- measure the
// real tabs (thickness, width, travel, pivot height) and a photo would help.

// p: a point on the inner wall face (XY); inward: unit vector from wall into
// the pocket; z0,h: vertical band; curved: the wall is the pocket circle, so
// the boss follows the arc (a straight box pokes through the curve).
// Bosses are added to the inlay union, channels subtracted (the tab sits in
// the channel, trapped on all sides).

module factory_tab_boss(p, inward, z0, h, curved) {
    if (curved) {
        // arc boss on the pocket circle, tab axis along +X in the local frame
        aw = BOSS_W / 2 / R_POCKET * 180 / PI;  // half angular width
        translate(C1) rotate(atan2(p[1] - C1[1], p[0] - C1[0]))
            translate([0, 0, z0])
                arc_block(R_POCKET - BOSS_LEN + 2, R_POCKET + 0.5,
                          -aw, aw, h);
    } else {
        a = atan2(inward[1], inward[0]);
        translate([p[0], p[1], z0]) rotate([0, 0, a])
            // embedded 2 mm in the wall, BOSS_LEN into the pocket
            translate([-2, -BOSS_W / 2, 0])
                cube([BOSS_LEN + 2, BOSS_W, h], center = false);
    }
}

module factory_tab_channel(p, inward, z0, h, curved) {
    if (curved) {
        ac = TAB_CH_W / 2 / R_POCKET * 180 / PI;
        translate(C1) rotate(atan2(p[1] - C1[1], p[0] - C1[0]))
            translate([0, 0, z0])
            // open at the pocket-facing (inner) end of the boss
                arc_block(R_POCKET - BOSS_LEN, R_POCKET + 1, -ac, ac, h);
    } else {
        a = atan2(inward[1], inward[0]);
        translate([p[0], p[1], z0]) rotate([0, 0, a])
            // open at the pocket-facing (inner) end of the boss
            translate([0, -TAB_CH_W / 2, 0])
                cube([TAB_CH_D, TAB_CH_W, h], center = false);
    }
}

// Points on the front pocket wall (circle) for the two rear factory tabs.
function c1_wall_point(ang) =
    C1 + R_POCKET * [cos(ang), sin(ang)];
function c1_inward(ang) =
    -[cos(ang), sin(ang)];

// [point, inward, z0, h, curved] for each factory tab: the two front-pocket
// tabs run from the elevated floor on the circle (curved), the two tray-2
// tabs from the lower floor on the flat connector wall.
function trap_positions() = concat(
    [for (a = TAB1_ANG)
         [c1_wall_point(a), c1_inward(a), LIFT, H_DEPTH - LIFT, true]],
    [for (i = [0:1])
         [TAB2_POS[i], [TAB2_POS[i][0] > 0 ? -1 : 1, 0], 0, H_DEPTH, false]]
);

module factory_tab_bosses() {
    for (t = trap_positions())
        factory_tab_boss(t[0], t[1], t[2], t[3], t[4]);
}

module factory_tab_channels() {
    for (t = trap_positions())
        factory_tab_channel(t[0], t[1], t[2], t[3], t[4]);
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
GRIP_LEVER = (GRIP_ARM_R0 + GRIP_ARM_T / 2) * GRIP_SPAN * PI / 180;  // ~20
