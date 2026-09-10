// lib_aframe.scad — ev6-fittings / cup-holder-inlay
// The A-frame divider: parameters + geometry, shared by the standalone
// preview (aframe.scad) and the inlay assembly (ev6_cup_inlay.scad, where
// it renders as a fitted test object).
//
// Mechanism (README: "The A-frame divider"): it stands across the front
// pocket, 79 across (X), and its two inside supports clamp onto the two
// floor studs at 50.5 (factory 50 + the owner's 0.5 shims). Pressing it
// down cams the fit; the pocket wall bulges slightly outward and the
// three-layer passenger-side cover tensions until it stops rattling.
//
// The "A" is an ARCH in the Y-Z section: 45 base between the legs, 61
// tall, rounded top (photo "approximately 22" — modelled as the closing
// semicircle, r = 45/2 = 22.5). The factory part is injection molded; the
// shape prints fine in FDM.
//
// Requires lib_geometry.scad to be included first (r_pocket, front_cone,
// TOL, WALL, LIFT, R_T1_BOT). No top-level instantiation here.
//
// ================= ASSUMED — verify in the car =================
//   STUD_Y (lib_geometry) — floor-stud centreline, from the pocket front
//                edge (y=0). This is the FREE position parameter: the frame
//                is positioned BY the studs it clamps, so AFRAME_Y0 below
//                derives from it (front-leg rear face on the stud line).
//                At STUD_Y = 20 the rear leg lands at y 57..61, in FRONT of
//                the passage-1 entry (y ~72) — a circular cutout cannot
//                clear the full-height passage, so the real frame either
//                sits forward like this or its rear-leg opening is a slot,
//                not a circle.
//   CUTOUT_*   — "circular cutout for the middle tray": a hole through the
//                rear leg at the passage centreline. Diameter/height are
//                guesses sized to clear the 24 mm passage.
//   STUD_D (lib_geometry) — floor-stud diameter.
//   WALL_T     — leg/web thickness (~4 from the photos).
// ================================================================

// ---- envelope (measured 2026-09-10) ----
AFRAME_W     = 79.0;    // across the pocket (X), the press-fit band
AFRAME_BASE  = 45.0;    // legs' span, Y (the "45 at the base")
AFRAME_H     = 61.0;    // total height above its floor (Z)
AFRAME_TOP_R = AFRAME_BASE / 2;  // 22.5 — the rounded top (photo ~22)
WALL_T       = 4.0;     // ASSUMED leg/web thickness
// The frame is positioned BY the studs it clamps: the C-hooks sit at the
// back face of the front leg (STUD_Y, from lib_geometry), so the front
// leg's front face is STUD_Y - WALL_T.
AFRAME_Y0    = STUD_Y - WALL_T;
CUTOUT_D     = 29.0;    // ASSUMED diameter. If the frame sits back ON passage-1
                       // (STUD_Y further back) it must clear the 24 mm passage;
                       // if it sits forward (STUD_Y = 20) it doesn't reach it.
                       // At CUTOUT_ZC = 10 a 29 mm hole opens into the floor —
                       // the real size/position need a joint in-car check.
CUTOUT_ZC    = 10.0;    // user 2026-09-10: "the cutout is ~10 mm from the bottom"
// The stud span / line / diameter (STUD_X_SPAN, STUD_Y, STUD_D) are car
// facts defined in lib_geometry (the inlay floor holes use them too).

// ---- fit ----
// "car":   the factory-style part — the 79 band press-fits the BARE pocket
//          cone (outer surface at r_pocket - TOL), standing on the mat.
// "inlay": the NEW slightly-smaller clamp — it fits INSIDE the inlay's
//          void (outer surface at r_pocket - TOL - WALL - AFRAME_CLEAR),
//          stands on the inlay floor, and is the part that pushes the
//          inlay wall outward to strain the console shell.
// AFRAME_CLEAR is the radial gap to the inlay's inner wall: positive =
// slip fit (drops in, clean render); negative = press fit (wedges in and
// is what strains the console — print at a small negative value).
AFRAME_CLEAR = 0.2;

function aframe_off(fit) =
    fit == "inlay" ? TOL + WALL + AFRAME_CLEAR : TOL;
function aframe_z0(fit) =
    fit == "inlay" ? LIFT + WALL : LIFT;
function aframe_h(fit) =
    AFRAME_H - (fit == "inlay" ? WALL : 0);  // same absolute top either way

// Arch section as a 2D profile (local x = height, local y = Y): straight
// sides to the springline, semicircular top. h is the total height.
module aframe_section(h) {
    sl = h - AFRAME_TOP_R;
    union() {
        square([sl, AFRAME_BASE]);
        translate([sl, AFRAME_BASE / 2]) circle(d = AFRAME_BASE);
    }
}

// The solid arch, 79 across, before hollowing. Rotate -90 about Y maps
// local z -> global -x and local x -> global z, so the extrude runs -X:
// the origin sits at +AFRAME_W/2 and the section at local x=0 lands on
// global z = aframe_z0(fit).
module aframe_solid(fit) {
    translate([AFRAME_W / 2, AFRAME_Y0, aframe_z0(fit)])
        rotate([0, -90, 0])
            linear_extrude(AFRAME_W) aframe_section(aframe_h(fit));
}

// Cone-following band: |x| <= r_pocket(z) - aframe_off(fit). Intersecting
// with this makes the 79 band hug the target surface like the inlay — the
// factory part's 79 is the cone's ID at the frame's mid-height.
module aframe_band(fit) {
    off = aframe_off(fit);
    front_cone(R_T1_BOT - off, r_pocket(90) - off, LIFT, 90);
}

module aframe(fit = "inlay") {
    z0 = aframe_z0(fit);
    h  = aframe_h(fit);
    difference() {
        intersection() {
            aframe_solid(fit);
            aframe_band(fit);
        }
        // hollow: the same section offset in by WALL_T (the arch web).
        // Runs the full width (no band applied) so it clears the tapered
        // ends; same +AFRAME_W/2 origin as aframe_solid.
        translate([AFRAME_W / 2, AFRAME_Y0 + WALL_T, z0 + WALL_T])
            rotate([0, -90, 0])
                linear_extrude(AFRAME_W)
                    offset(-WALL_T) aframe_section(h);
        // circular cutout for the middle tray: a hole along X through the
        // rear leg, centred on the passage centreline (x = 0)
        translate([0, AFRAME_Y0 + AFRAME_BASE - WALL_T / 2, z0 + CUTOUT_ZC])
            rotate([0, 90, 0])
                translate([0, 0, -AFRAME_W / 2])
                    cylinder(h = AFRAME_W, d = CUTOUT_D);
        // stud supports: two C-hooks in the front leg at +/-STUD_X_SPAN/2
        // — a slot (STUD_D + 0.3 wide) open at the floor, cut into a small
        // block embedded in the leg. The stud drops into the slot as the
        // frame is set down; the 50.5 slot-centre span (factory 50 + the
        // owner's 0.5 shims) is what cams the fit when pressed down.
        // NOTE (inlay fit): the studs sit in the car floor below the inlay
        // floor — the inlay floor is opened for them (STUD_HOLES,
        // lib_geometry).
        for (sx = [-1, 1])
            difference() {
                translate([sx * STUD_X_SPAN / 2 - 4, STUD_Y - 2, z0])
                    cube([8, 4, 14]);
                translate([sx * STUD_X_SPAN / 2 - (STUD_D + 0.3) / 2,
                           STUD_Y - 2, z0])
                    cube([STUD_D + 0.3, 6, 10]);
            }
    }
}
