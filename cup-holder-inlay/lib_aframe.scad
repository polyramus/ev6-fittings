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
AFRAME_W    = AFR_CLAMP_W;  // clamp width across the tray (X) = 74 (lib_geometry)
AFRAME_BASE = 45.0;   // base depth (Y), the "45 at the base"
AFRAME_H    = 61.0;   // total height (Z), the "~6 cm tall"
// The A-frame BRIDGES the tray-2/3 passage (passage 2, y 188..225 in
// lib_geometry): its 45 base spans the passage gap, centred on it. The
// console walls stay ~79 apart through here (user 2026-09-10: "the walls are
// always at almost 8cm"), so the 79 width spans wall-to-wall. Two floor studs
// protrude here and the frame latches onto them lego-style (see aframe()).
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
// "car":   the factory part — 79 wide, standing on the rear-tray floor
//          (z=0), press-fitting the bare car tray.
// "inlay": the NEW slightly-smaller divider — fits inside the inlay's
//          tray-2/3 void and pushes the inlay wall out to strain the console.
// (The inlay-fit sizing is worked out once the car-fit shape and position
//  are confirmed; for now both render the same sawbuck.)
// The base rests ON the two floor tenons (lego-brick style), so it is raised
// AFR_STUD_H above the floor it sits on; the ~1 cm void beneath is open in
// the middle (the passage), tenons on the sides.
function aframe_z0(fit) = (fit == "inlay" ? WALL : 0) + AFR_STUD_H;

// Solid-sawbuck section as a 2D profile (local x = height/Z, local y = Y):
// a triangle, 45 base (along local y) splaying up to the apex at local x = h.
module aframe_section(h) {
    polygon(points = [
        [0, 0],
        [0, AFRAME_BASE],
        [h, AFRAME_BASE / 2],
    ]);
}

// The solid sawbuck, 79 across (X). Rotate -90 about Y maps local z ->
// global -x and local x -> global z, so the extrude runs -X: origin at
// +AFRAME_W/2, base at AFRAME_Y0, floor at aframe_z0(fit).
module aframe_solid(fit) {
    translate([AFRAME_W / 2, AFRAME_Y0, aframe_z0(fit)])
        rotate([0, -90, 0])
            linear_extrude(AFRAME_W) aframe_section(AFRAME_H);
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
// Two rectangular tenons at the passage (lib_geometry AFR_STUD_*): X width
// constant, Y length narrowing going UP (front-to-back faces slant in), ~1 cm
// tall. No flange/latch — the taper is the press fit. Rendered as reference
// car geometry (aframe.scad), NOT part of the printable frame.
module aframe_tenon(sx) {
    cx = sx * AFR_STUD_X;
    th = 0.4;   // slab thickness for the hull endpoints
    hull() {
        translate([cx, AFR_STUD_Y, th / 2])
            cube([AFR_STUD_W, AFR_STUD_L_BASE, th], center = [0, 0, 0]);
        translate([cx, AFR_STUD_Y, AFR_STUD_H - th / 2])
            cube([AFR_STUD_W, AFR_STUD_L_TOP, th], center = [0, 0, 0]);
    }
}
module aframe_tenons() {
    aframe_tenon(-1);
    aframe_tenon(1);
}
