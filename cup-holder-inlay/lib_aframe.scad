// lib_aframe.scad — ev6-fittings / cup-holder-inlay
// The A-frame divider: parameters + geometry, shared by the standalone
// preview (aframe.scad) and the inlay assembly (ev6_cup_inlay.scad, where
// it renders as a fitted test object).
//
// What it is (user 2026-09-10): a SOLID SAWBUCK — an extruded "A" with the
// counter (the space between the legs) filled in, so the section is a solid
// triangle. It stands at the tray-2/tray-3 boundary in the rear console:
// 79 wide in X (spans the tray), 45 deep in Y (the base), 61 tall in Z,
// apex up. A circular cutout on one side lets a bottle sit in tray 2.
// The factory part is injection molded; the shape prints fine in FDM.
//
// Requires lib_geometry.scad to be included first (TOL, WALL, and the
// tray-2/3 Y layout: Y_T2_REAR, Y_P2_REAR). No top-level instantiation here.
//
// ================= ASSUMED — verify in the car =================
//   AFRAME_Y0  — where it sits in Y. Set to the 75->51 step (Y_T2_REAR,
//                y~188), i.e. the back of tray 2 / the tray-2/3 boundary.
//                The 45 base then runs from there toward tray 3. Confirm the
//                exact position and which step it actually sits at.
//   CUTOUT_*   — the ~75 mm bottle circle: placed in front (toward tray 2),
//                centred on x=0, so only its back crescent bites a ~45 mm-wide,
//                9-10 mm-deep dent into the front slant. Confirm which side it
//                is actually on and the exact height/depth in the car.
// ================================================================

// ---- envelope (measured 2026-09-10) ----
AFRAME_BASE = 45.0;   // base depth (Y), the "45 at the base"
AFRAME_H    = 61.0;   // total height (Z), the "~6 cm tall"
// Side profile (IMG_5350): ASYMMETRIC. A long front slant, a short near-
// vertical back, apex offset toward the rear, rounded top. APEX_Y is the
// apex's offset from the front edge along the base (middle = BASE/2).
AFRAME_APEX_Y = 28.0;    // apex toward the back (~62% of the base)
AFRAME_TOP_R  = 6.0;     // rounded-top radius
// (width is aframe_w(fit) -> AFR_CLAMP_W = 74, the clamp spanning the ~79
//  tray; user 2026-09-10: "the walls are always at almost 8 cm".)
// The A-frame sits at the tray-2/3 boundary (y 188..225 in lib_geometry);
// its 45 base spans that region. Two floor tenons protrude here and the frame
// rests on them (see aframe_tenons). The base is raised AFR_STUD_H above the
// floor, leaving the passage open in the middle.
AFRAME_Y0   = 184.0;  // 45 base centred on passage 2 (188..225), bridging it

// ---- bottle cutout (user 2026-09-10) ----
// A ~75 mm circle (a bottle sitting in tray 2) that only CLIPS the front of
// the frame: its back crescent bites a ~45 mm-wide, 9-10 mm-deep dent into the
// front slant. It is NOT a through-hole -- the circle mostly sits in tray 2.
CUTOUT_D  = 75.0;         // the bottle circle diameter (user "~75 mm")
CUTOUT_CY = AFRAME_Y0 - 28.0;  // ASSUMED circle centre (x=0, in front of the
                               // base edge): 37.5-28 = 9.5 mm of crescent bites
                               // in (~45-50 mm wide). Confirm side + position.

// ---- fit ----
// "car":   the factory part — AFR_CLAMP_W (74) wide, on the rear-tray floor
//          (z=0), press-fitting the bare car tray.
// "inlay": the NEW divider — inset AFR_INSET each side so it fits inside the
//          inlay's rear void and cams the wall outward on insertion. The inlay
//          void is the car footprint (75->71) offset in by WALL+TOL, ~67-71.
// Both rest ON the two floor tenons (lego-brick style): the base sits at the
// tenon tops, AFR_STUD_H above the car floor, in EITHER fit (the tenons rise
// from the car floor to z=AFR_STUD_H whether or not the inlay is present —
// through the inlay floor for the inlay fit). The ~1 cm void beneath is open
// in the middle (the passage), tenons on the sides.
AFR_INSET = 4.0;   // inlay-fit inset each side (fits the inlay rear void,
                   // tightest at the tray-3 side ~66.5 mm)
function aframe_w(fit) = fit == "inlay" ? AFR_CLAMP_W - 2 * AFR_INSET : AFR_CLAMP_W;
function aframe_z0(fit) = AFR_STUD_H;

// Solid-sawbuck section as a 2D profile (local x = height/Z, local y = Y):
// an ASYMMETRIC triangle (IMG_5350) — front-base [0,0], back-base [0,BASE],
// apex toward the rear at [h-R, APEX_Y] — with a rounded top: the hull of the
// triangle and a TOP_R circle at the apex gives straight slants + a dome.
module aframe_section(h) {
    hull() {
        polygon(points = [
            [0, 0],
            [0, AFRAME_BASE],
            [h - AFRAME_TOP_R, AFRAME_APEX_Y],
        ]);
        translate([h - AFRAME_TOP_R, AFRAME_APEX_Y])
            circle(d = 2 * AFRAME_TOP_R);
    }
}

// The solid sawbuck, aframe_w(fit) across (X). Rotate -90 about Y maps local
// z -> global -x and local x -> global z, so the extrude runs -X: origin at
// +w/2, base at AFRAME_Y0, floor at aframe_z0(fit).
module aframe_solid(fit) {
    w = aframe_w(fit);
    translate([w / 2, AFRAME_Y0, aframe_z0(fit)])
        rotate([0, -90, 0])
            linear_extrude(w) aframe_section(AFRAME_H);
}

module aframe(fit = "car") {
    difference() {
        aframe_solid(fit);
        // the bottle dent: a 75 mm vertical cylinder centred in front of the
        // base edge (toward tray 2) -- only its back crescent removes material
        translate([0, CUTOUT_CY, aframe_z0(fit) - 1])
            cylinder(h = AFRAME_H + 2, d = CUTOUT_D);
    }
}

// ---- floor tenons (the CAR feature the frame drops onto) ----
// Two A-shaped tenons at the passage (lib_geometry AFR_STUD_*): X width
// constant, ~1 cm tall, Y-footprint AFR_STUD_L_BASE at the floor narrowing to
// AFR_STUD_L_TOP at the top. The FRONT face slants back parallel to the frame's
// front slant (the "slant that matches the inside of the a-frame", IMG_5349)
// and the back face is near-vertical — so each tenon is a small positive "A".
// No flange/latch — the clamp rests on the tops and the parallel front faces
// locate it. Rendered as reference car geometry (aframe.scad), NOT part of the
// printable frame.
module aframe_stud_section() {
    // 2D profile (local x = height/Z, local y = Y-depth, front = 0). Base
    // L_BASE (front y=0 .. back y=L_BASE), front face slants back to L_TOP at
    // the top, back face vertical.
    polygon(points = [
        [0, 0],                                       // front-bottom
        [0, AFR_STUD_L_BASE],                         // back-bottom
        [AFR_STUD_H, AFR_STUD_L_BASE],                // back-top (back vertical)
        [AFR_STUD_H, AFR_STUD_L_BASE - AFR_STUD_L_TOP], // front-top (front slant)
    ]);
}
module aframe_tenon(sx) {
    cx = sx * AFR_STUD_X;
    translate([cx + AFR_STUD_W / 2, AFR_STUD_Y - AFR_STUD_L_BASE / 2, 0])
        rotate([0, -90, 0])
            linear_extrude(AFR_STUD_W) aframe_stud_section();
}
module aframe_tenons() {
    aframe_tenon(-1);
    aframe_tenon(1);
}
