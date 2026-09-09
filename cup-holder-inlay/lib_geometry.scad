// lib_geometry.scad — ev6-fittings / cup-holder-inlay
// Envelope (cavity) and inlay shell geometry for the Kia EV6 console inlay.
//
// Coordinate system (all parts share it):
//   X  transverse, +X = passenger side (LHD right)
//   Y  fore-aft,    +Y = toward the rear trays (frontmost tray at low Y)
//   Z  vertical,    z=0 = floor of the LOWER (rear two) trays
//                   z=LIFT = floor of the frontmost tray (elevated ~8 mm)
//                   z=H_DEPTH = console top surface (inlay is flush)
//
// Dimension provenance: calipered by the owner (2026-09-09), except where
// marked TODO. 74 mm = diameter of the factory TPU bottom inlay, frontmost
// tray. "width" is always X, "length" is always Y.

// ---------- derived Y layout ----------
// front circle: d=74, front edge at y=0
Y_C1_FRONT   = 0;
Y_C1_CENTER  = R_T1;              // 37
Y_C1_REAR    = 2 * R_T1;          // 74
// passage 1 (24 wide x 32 visible): the measured 32 mm run starts where the
// passage sides leave the circle (y=72, a 12-35-37 Pythagorean hit) and ends
// at the step. The rectangle is extended 6 mm INTO the circle so its corner
// lands well inside the arc -- a corner exactly on the circle is a
// knife-edge contact that makes offset()/CSG emit slivers on the floor.
Y_T1_TAN     = Y_C1_CENTER + sqrt(R_T1^2 - (P1_W / 2)^2);  // 72
Y_P1_REAR    = Y_T1_TAN + P1_L;      // 104  <- the 8 mm step is here
Y_P1_FRONT   = Y_T1_TAN - 6;         // 66   (hidden inside the circle)
// tray 2: connector(24) -> expand 24->75 over 35 -> rect 25
Y_T2_FRONT   = Y_P1_REAR;
Y_T2_EXP0    = Y_T2_FRONT + L_T2_CONN;
Y_T2_EXP1    = Y_T2_EXP0 + T2_EXP_L;
Y_T2_REAR    = Y_T2_EXP1 + T2_RECT_L;
// passage 2 (51 x 37.5), abrupt step in from tray 2's 75
Y_P2_FRONT   = Y_T2_REAR;
Y_P2_REAR    = Y_P2_FRONT + P2_L;
// tray 3: taper 71 -> 69.5 over 24, then the rounded-corner end
Y_T3_FRONT   = Y_P2_REAR;
Y_T3_TAPER1  = Y_T3_FRONT + T3_TAPER_L;
Y_T3_REAR    = Y_T3_TAPER1 + L_T3_END_R;   // passenger-side (longest) rear extent

// ---------- 2D footprint of the whole carved space ----------
module full_footprint() {
    union() {
        // -- tray 1: the 74 mm circle
        translate([0, Y_C1_CENTER]) circle(d = 2 * R_T1);

        // -- passage 1: 24 wide x 32 long
        translate([-P1_W / 2, Y_P1_FRONT]) square([P1_W, P1_L]);

        // -- tray 2: 24-wide connector
        // TODO: length guessed (L_T2_CONN). Unclear whether this is a distinct
        // section behind the elevated passage 1, or the same 24 mm corridor.
        translate([-P1_W / 2, Y_T2_FRONT]) square([P1_W, L_T2_CONN]);

        // -- tray 2: expansion trapezoid 24 -> 75
        polygon(points = [
            [-P1_W / 2,  Y_T2_EXP0],
            [ P1_W / 2,  Y_T2_EXP0],
            [ T2_W / 2,  Y_T2_EXP1],
            [-T2_W / 2,  Y_T2_EXP1],
        ]);

        // -- tray 2: rectangular tail, 75 wide x 25 long
        translate([-T2_W / 2, Y_T2_EXP1]) square([T2_W, T2_RECT_L]);

        // -- passage 2: 51 wide x 37.5 long (abrupt step per description)
        translate([-P2_W / 2, Y_P2_FRONT]) square([P2_W, P2_L]);

        // -- tray 3: taper 71 -> 69.5 over 24
        polygon(points = [
            [-T3_W_FRONT / 2, Y_T3_FRONT],
            [ T3_W_FRONT / 2, Y_T3_FRONT],
            [ T3_W_REAR / 2,  Y_T3_TAPER1],
            [-T3_W_REAR / 2,  Y_T3_TAPER1],
        ]);

        // -- tray 3: roughly triangular end, rounded (chamfered) corner on
        //    the passenger (+X) side.
        // TODO: L_T3_END_L / L_T3_END_R / R_T3_CORNER are placeholders -- the
        // description only says "roughly triangular, rounded corner on the
        // passenger side". The rear edge is a diagonal between the two rear
        // corners as drawn here.
        polygon(points = [
            [-T3_W_REAR / 2,              Y_T3_TAPER1],                    // rear-left of taper
            [ T3_W_REAR / 2,              Y_T3_TAPER1],                    // rear-right of taper
            [ T3_W_REAR / 2,              Y_T3_TAPER1 + L_T3_END_R - R_T3_CORNER],
            [ T3_W_REAR / 2 - R_T3_CORNER, Y_T3_TAPER1 + L_T3_END_R],      // chamfer (TODO: true arc)
            [-T3_W_REAR / 2,              Y_T3_TAPER1 + L_T3_END_L],       // rear-left corner
        ]);
    }
}

// Clip the footprint to a Y band. The 8 mm step is modelled as two slabs of
// the same footprint at different floor heights, split at Y_P1_REAR.
module footprint_slab(y0, y1) {
    intersection() {
        full_footprint();
        translate([-X_CLIP, y0]) square([2 * X_CLIP, y1 - y0]);
    }
}

// The carved cavity itself (what the inlay fits into). Front slab floor is
// LIFT higher than the rear slabs.
module cavity() {
    union() {
        // front: circle + passage 1, floor at z=LIFT
        translate([0, 0, LIFT])
            linear_extrude(H_DEPTH - LIFT)
                footprint_slab(-20, Y_P1_REAR);
        // rear: tray 2 + passage 2 + tray 3, floor at z=0
        linear_extrude(H_DEPTH)
            footprint_slab(Y_P1_REAR, 400);
    }
}

// The inlay wall + floor, before the grip mechanism and tab bores are added.
// Outer surface is the cavity offset inward by TOL (fit clearance); the inner
// void is offset a further WALL in, and the floors are WALL thick.
//
// NOTE (draft): offset() on the full union can misbehave at concave pinches
// (passage 2 between 75 mm and 71 mm trays). If the shell looks wrong there,
// replace with per-section rings.
module inlay_shell() {
    difference() {
        // outer surfaces: cavity offset in by TOL (fit clearance to the car)
        union() {
            translate([0, 0, LIFT])
                linear_extrude(H_DEPTH - LIFT)
                    offset(-TOL) footprint_slab(-20 - TOL, Y_P1_REAR);
            linear_extrude(H_DEPTH)
                offset(-TOL) footprint_slab(Y_P1_REAR, 400 + TOL);
        }
        // inner void: offset in by WALL + TOL, floors WALL thick, OPEN at the
        // top (z = H_DEPTH) -- the tray mouth must not be capped
        union() {
            // front void: floor at z = LIFT + WALL
            translate([0, 0, LIFT + WALL])
                linear_extrude(H_DEPTH - LIFT - WALL)
                    offset(-(WALL + TOL)) footprint_slab(-20 - WALL - TOL, Y_P1_REAR);
            // rear void: floor at z = WALL
            translate([0, 0, WALL])
                linear_extrude(H_DEPTH - WALL)
                    offset(-(WALL + TOL)) footprint_slab(Y_P1_REAR, 400 + WALL + TOL);
        }
    }
}

// Fit-check helper: render the cavity as a ghost alongside the inlay.
module cavity_ghost() {
    color("gray", 0.25) cavity();
}
