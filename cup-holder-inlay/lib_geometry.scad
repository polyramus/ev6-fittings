// lib_geometry.scad — ev6-fittings / cup-holder-inlay
// Envelope (cavity) and inlay shell geometry for the Kia EV6 console inlay.
//
// Coordinate system (all parts share it):
//   X  transverse,    +X = driver side (LHD), -X = passenger
//   Y  fore-aft,      +Y = toward the rear trays (frontmost tray at low Y)
//   Z  vertical,      z=0 = floor of the LOWER (rear two) trays
//                     z=LIFT = floor of the frontmost tray + passage 1
//                     z=H_DEPTH = console top surface (inlay is flush)
//
// Dimension provenance (2026-09-09):
//   - Front pocket: data/EV6 Utility Cup.stl (Thingiverse "EV6 Utility Cup
//     (Precision Fit)") — the part is a negative of the front cavity:
//     conical, Ø75.07 at the seating level, Ø82.46 at the console surface,
//     62.5 tall. The part seats on the TPU mat, so z=LIFT is mat-top level.
//   - Full footprint length (~299), tray-3 end shape, tab notch pairs,
//     passage-1 bridge: data/IMG_5344.jpg (TPU mat on a 14" MBP, 221.3 mm
//     short side as scale). Soft mat, so ±3 mm and ~2 mm/side overhang on
//     widths.
//   - Everything else: calipered by the owner. "width" is always X,
//     "length" always Y.

// ---------- known dimensions ----------
LIFT       = 8.0;      // front tray + passage 1 elevated this much
R_T1_BOT   = 37.535;   // front pocket radius at seating level (STL, Ø75.07;
                       // owner's TPU-mat caliper read 74 — the mat is soft)
R_T1_TOP   = 41.23;    // front pocket radius at the console surface (STL)
H_FRONT    = 62.5;     // front section height: seating level -> console (STL)
H_DEPTH    = LIFT + H_FRONT;  // 70.5, rear floor -> console
P1_W       = 24.0;     // passage 1 width (owner; mat waist confirms 24.0)
P1_L       = 32.0;     // passage 1 visible length, tangent -> step
T2_W       = 75.0;     // tray 2 max width
T2_EXP_L   = 35.0;     // tray 2 expansion length (24 -> 75)
T2_RECT_L  = 25.0;     // tray 2 rectangular tail length
P2_W       = 51.0;     // passage 2 width
P2_L       = 37.5;     // passage 2 length
T3_W_FRONT = 71.0;     // tray 3 width at front
T3_W_REAR  = 69.5;     // tray 3 width after taper
T3_TAPER_L = 24.0;     // tray 3 taper length

// ---------- TODO: verify these ----------
L_T2_CONN  = 24.0;     // photo estimate (mat waist ends ~128 from front edge);
                       // is this a distinct section or the same 24 corridor?
L_T3_END_L = 50.0;     // photo estimate: passenger (-X) end, the long one
L_T3_END_R = 20.0;     // photo estimate: driver (+X) end, the short one
TIP_W      = 12.0;     // photo estimate: flat at the passenger tip
R_T3_CORNER= 6.0;      // tip chamfer/round (photo: "rounded corner", LHD = -X)
TAB1_ANG   = [64, 116];   // TODO: factory tab angles, front pocket — the mat
                          // wraps the circle without visible notches; caliper
TAB2_POS   = [[-31.5, 188], [31.5, 188]]; // photo: notch pair at the 75->51
                          // step, ~6 in from each wall; y = Y_T2_REAR; caliper
BOSS_W     = 14.0;     // TODO: trap boss width  (match tab width + play)
BOSS_LEN   = 6.0;      // TODO: trap boss depth into pocket
TAB_CH_W   = 10.0;     // TODO: channel width  (tab width + ~0.4)
TAB_CH_D   = 4.0;      // TODO: channel depth  (tab thickness + ~0.4)
BRIDGE_LEN = 20.0;     // photo: passage-1 bridge, passenger side, spans 20 of
BRIDGE_W   = 9.0;      // the 24 (mat slitted around it, flush with floor)
BRIDGE_Y0  = 74.0;     // photo: ~76-88 from front edge
BRIDGE_RELIEF = 1.0;   // relief depth in the inlay passage floor under it

// ---------- inlay / print ----------
WALL       = 2.0;      // inlay wall thickness
TOL        = 0.15;     // fit clearance per side vs the car (FDM)
X_CLIP     = 80.0;     // internal clip for the footprint slabs (keep > T2_W/2)

// ---------- derived Y layout ----------
// front circle: d=75.07, front edge at y=0
Y_C1_FRONT   = 0;
Y_C1_CENTER  = R_T1_BOT;            // 37.535
Y_C1_REAR    = 2 * R_T1_BOT;        // 75.07
// passage 1 (24 wide x 32 visible): the measured 32 mm run starts where the
// passage sides leave the circle (y≈72.05, a 12-35.8-37.5 Pythagorean hit)
// and ends at the step. The box is extended ~6 mm INTO the circle so its
// corner lands well inside the arc — a corner exactly on the circle is a
// knife-edge contact that makes CSG emit slivers on the floor.
Y_T1_TAN     = Y_C1_CENTER + sqrt(R_T1_BOT^2 - (P1_W / 2)^2);  // 72.05
Y_P1_REAR    = Y_T1_TAN + P1_L;      // 104.05 <- the 8 mm step is here
Y_P1_FRONT   = Y_T1_TAN - 6;         // hidden inside the cone
// tray 2: connector(24) -> expand 24->75 over 35 -> rect 25
Y_T2_FRONT   = Y_P1_REAR;
Y_T2_EXP0    = Y_T2_FRONT + L_T2_CONN;
Y_T2_EXP1    = Y_T2_EXP0 + T2_EXP_L;
Y_T2_REAR    = Y_T2_EXP1 + T2_RECT_L;   // <- 75->51 step, tab notch pair
// passage 2 (51 x 37.5)
Y_P2_FRONT   = Y_T2_REAR;
Y_P2_REAR    = Y_P2_FRONT + P2_L;       // <- 51->71 step, second notch pair
// tray 3: taper 71 -> 69.5 over 24, then the long asymmetric end
Y_T3_FRONT   = Y_P2_REAR;
Y_T3_TAPER1  = Y_T3_FRONT + T3_TAPER_L;
Y_T3_REAR    = Y_T3_TAPER1 + L_T3_END_L; // passenger-side (longest) extent

// ---------- 2D footprint of the rear (prismatic) part ----------
// The front section is a CONE (see front_cavity), not a footprint slab.
module rear_footprint() {
    union() {
        // -- tray 2: connector(24) -> expansion trapezoid 24 -> 75
        translate([-P1_W / 2, Y_T2_FRONT]) square([P1_W, L_T2_CONN]);
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

        // -- tray 3: the end. LHD: the long, rounded/chamfered tip is on the
        //    PASSENGER side (-X); the driver side (+X) ends short. Photo: a
        //    long asymmetric taper to a ~12 mm tip. (The first draft had the
        //    chamfer on +X — that is the RHD variant.)
        // TODO: L_T3_END_L / L_T3_END_R / TIP_W / R_T3_CORNER are photo
        // estimates — caliper the rear end.
        polygon(points = [
            [ T3_W_REAR / 2,              Y_T3_TAPER1],                    // front, driver
            [ T3_W_REAR / 2,              Y_T3_TAPER1 + L_T3_END_R],       // rear, driver (short)
            [-T3_W_REAR / 2 + TIP_W,      Y_T3_TAPER1 + L_T3_END_L],       // tip flat, passenger
            [-T3_W_REAR / 2,              Y_T3_TAPER1 + L_T3_END_L - R_T3_CORNER], // tip chamfer
            [-T3_W_REAR / 2,              Y_T3_TAPER1],                    // front, passenger
        ]);
    }
}

// Clip the rear footprint to a Y band.
module footprint_slab(y0, y1) {
    intersection() {
        rear_footprint();
        translate([-X_CLIP, y0]) square([2 * X_CLIP, y1 - y0]);
    }
}

// Exact cone between two radii, z0..z1 (hull of two thin discs).
module cone2(r0, r1, z0, z1) {
    hull() {
        translate([0, 0, z0]) linear_extrude(0.8) circle(d = 2 * r0, $fn = 96);
        translate([0, 0, z1 - 0.8]) linear_extrude(0.8) circle(d = 2 * r1, $fn = 96);
    }
}

// Passage 1: a vertical slot through the front section (the car's passage
// wall is a plane, so it does not lean — only the circular part is conical).
module passage1_box(x_half, z0, z1) {
    translate([-x_half, Y_P1_FRONT, z0])
        cube([2 * x_half, Y_P1_REAR - Y_P1_FRONT, z1 - z0]);
}

// The front pocket cone, centred on C1 (front edge of the circle at y=0).
module front_cone(r0, r1, z0, z1) {
    translate([0, Y_C1_CENTER]) cone2(r0, r1, z0, z1);
}

// The carved cavity itself (what the inlay fits into).
module cavity() {
    union() {
        // front: cone + passage slot, floor at z=LIFT
        front_cone(R_T1_BOT, R_T1_TOP, LIFT, H_DEPTH);
        passage1_box(P1_W / 2, LIFT, H_DEPTH);
        // rear: prismatic, floor at z=0
        linear_extrude(H_DEPTH)
            footprint_slab(Y_P1_REAR, 400);
    }
}

// Pocket inner radius at height z (front section only).
function r_pocket(z) =
    R_T1_BOT + (R_T1_TOP - R_T1_BOT) * (z - LIFT) / H_FRONT;

// The inlay wall + floor, before the grip mechanism and tab bores are added.
// Front section: the outer surface is the cone offset in by TOL, the void a
// further WALL in, floor WALL thick, open at the top. Rear section: the old
// 2D-offset prism.
module inlay_shell() {
    union() {
        // ---- front (conical) section ----
        difference() {
            union() {
                front_cone(R_T1_BOT - TOL, R_T1_TOP - TOL, LIFT, H_DEPTH);
                passage1_box(P1_W / 2 - TOL, LIFT, H_DEPTH);
            }
            union() {
                // void floor at z = LIFT + WALL, OPEN at z = H_DEPTH
                front_cone(R_T1_BOT - TOL - WALL, R_T1_TOP - TOL - WALL,
                           LIFT + WALL, H_DEPTH);
                passage1_box(P1_W / 2 - TOL - WALL, LIFT + WALL, H_DEPTH);
            }
            // passage-1 bridge relief: the car's bridge (passenger side,
            // spans 20 of the 24) is flush with the TPU mat, so the inlay
            // floor gets a shallow pocket under it and the inlay seats at
            // mat level, top flush. Set BRIDGE_RELIEF=0 if the bridge turns
            // out to sit below the mat.
            if (BRIDGE_RELIEF > 0)
                translate([-P1_W / 2, BRIDGE_Y0, LIFT + WALL - BRIDGE_RELIEF])
                    cube([BRIDGE_LEN, BRIDGE_W, BRIDGE_RELIEF]);
        }

        // ---- rear (prismatic) section ----
        difference() {
            linear_extrude(H_DEPTH)
                offset(-TOL) footprint_slab(Y_P1_REAR - 0.5, 400 + TOL);
            // inner void: offset in by WALL + TOL, floor WALL thick, open at
            // the top (z = H_DEPTH) -- the tray mouth must not be capped
            translate([0, 0, WALL])
                linear_extrude(H_DEPTH - WALL)
                    offset(-(WALL + TOL))
                        footprint_slab(Y_P1_REAR - 0.5, 400 + WALL + TOL);
        }
    }
}

// Fit-check helper: render the cavity as a ghost alongside the inlay.
module cavity_ghost() {
    color("gray", 0.25) cavity();
}
