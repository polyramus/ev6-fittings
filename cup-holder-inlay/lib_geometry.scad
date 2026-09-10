// lib_geometry.scad — ev6-fittings / cup-holder-inlay
// Envelope (cavity) and inlay shell geometry for the Kia EV6 console inlay.
//
// Coordinate system (all parts share it):
//   X  transverse,    +X = driver side (LHD), -X = passenger
//   Y  fore-aft,      +Y = toward the rear trays (frontmost tray at low Y)
//   Z  vertical,      z=0 = floor of the LOWER (rear two) trays
//                     z=LIFT = floor of the frontmost tray + passage 1
//                     z=H_top(y) = slanted console top (inlay is flush)
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
H_FRONT    = 62.5;     // height of the front pocket's CONE (STL); the pocket
                       // itself is taller (~79 from the mat to the console
                       // top) — the measured lean is assumed to continue
                       // above the cone, see r_pocket
SLANT_CLIP_Z = 90.0;   // build everything this tall, then trim with the
                       // slant plane; just needs to exceed H_TOP_FRONT
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
TAB1_ANG   = [45, 135];   // front-pocket tab angles: ~45 deg from the rear
                          // (passage) centerline each side (photo IMG_5345,
                          // 2026-09-10; the white lines in the photo are
                          // duct-tape residue from earlier makeshift tab
                          // fastening — the tabs themselves are intact)
TAB_W      = 7.5;    // factory tab width (user)
TAB_H      = 30.0;   // wall opening height (user)
TAB_TRAVEL = 14.0;   // free-end travel at rest; folds fully into the wall
TAB_SEAT   = 0.2;    // boss face sits this far in front of the console wall
                     // face, so a folded flap can only bulge 0.2 mm
TAB1_Z0    = 30.0;   // opening bottom above the pocket floor (user gauge,
                     // 2026-09-10: "fairly high, ~30 mm"; pivot then ~60 up,
                     // i.e. near the top of the ~79 mm pocket)
BOSS_MARGIN= 1.5;    // boss margin around the opening
// Tray-2 tabs: same flap family (TAB_W x TAB_H), on the 75->51 step faces
// (y = Y_T2_REAR, facing -Y), centred on the 12 mm ledge — the mat notch
// pair is ~6 mm in from each passage-2 wall (photo). 38 mm above the
// tray-2 floor = level with the front-pocket tabs (user 2026-09-10). No
// inlay feature needed: the offset wall band over those faces is the
// flush-press limiter (TOL of play). Documented for the A-frame work and
// the README; not referenced by any geometry.
TAB2_POS   = [[-31.5, 188], [31.5, 188]];  // y = Y_T2_REAR (188); literal
                                            // because top-level assignments
                                            // are order-dependent in OpenSCAD
BRIDGE_LEN = 20.0;     // photo: passage-1 bridge, passenger side, spans 20 of
BRIDGE_W   = 9.0;      // the 24 (mat slitted around it, flush with floor)
BRIDGE_Y0  = 74.0;     // photo: ~76-88 from front edge
BRIDGE_RELIEF = 1.0;   // relief depth in the inlay passage floor under it

// ---------- A-frame floor studs (interface with aframe / lib_parts) ----------
// The two molded-floor studs the A-frame's inside supports clamp onto.
// The span is the shimmed 50.5 (factory 50 + the owner's 0.5); that
// interference is what cams the pocket wall outward when the frame is
// pressed down. The studs sit BELOW the inlay floor, so STUD_HOLES opens
// it where the studs poke through — needed for the inlay-fit frame.
STUD_X_SPAN = 50.5;    // shimmed support span (factory 50 + 0.5)
STUD_Y      = 20.0;    // ASSUMED: stud centreline from the pocket front
                       // (y=0). Primary car fact — the A-frame's
                       // AFRAME_Y0 derives from it (lib_aframe).
STUD_D      = 5.0;     // ASSUMED stud diameter
STUD_HOLES  = true;    // cut the floor holes in the inlay
STUD_HOLE_D = STUD_D + 1.5;  // clearance over the stud for the C-hook slot

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

// ---------- slanted console top ----------
// The console top is not flat: the owner's caliper reads 82 mm console-to-
// floor at the front, ~75 at the back (to the molded floor; the TPU mat
// under the front pocket is ~3 mm). With level floors (assumed, the exact
// slant is hard to measure) the top is one plane through two anchors:
//   front  (y=0, the pocket):  LIFT + H_FRONT_MAT above z=0
//   rear   (y=Y_T3_REAR):      H_REAR above z=0
H_FRONT_MAT  = 79.0;   // console top -> front pocket floor (mat top):
                       // 82 to the molded floor minus the ~3 mat. If the
                       // caliper actually rested on the mat, it is 82.
                       // NOTE: the STL cone is only 62.5 tall, so this puts
                       // ~17 mm of wall above the measured cone — the lean
                       // is assumed to continue (see r_pocket).
H_REAR       = 75.0;   // console top -> rear (lower) tray floor (user)
H_TOP_FRONT  = LIFT + H_FRONT_MAT;   // 87, at y=0
SLANT_Y      = Y_T3_REAR;            // the rear anchor, at the full extent
function H_top(y) =                  // console top height at a given y
    H_TOP_FRONT + (H_REAR - H_TOP_FRONT) * y / SLANT_Y;
SLANT_ANG    = atan((H_TOP_FRONT - H_REAR) / SLANT_Y);  // ~2.3 deg, falls
                                                        // to the rear
// Removes everything above the slant top plane z = H_top(y). The inlay and
// the cavity are both trimmed with it, so the inlay top is flush with the
// console top along the whole slant.
module slant_cutter() {
    // Box extends far BEHIND the axis too (local y -500..+500): a box that
    // only starts at the axis keeps its front face tilted with the rotation
    // and leaves an untrimmed wedge in front of the pocket's forward
    // overhang (the cone leans out past y=0 above ~z=55).
    translate([-160, 0, H_TOP_FRONT])
        rotate([-SLANT_ANG, 0, 0])
            translate([0, -500, 0])
                cube([320, 1000, 80]);
}

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

// The carved cavity itself (what the inlay fits into): the full-height
// shapes trimmed to the slant console top.
module cavity() {
    difference() {
        union() {
            // front: cone (lean continued past the measured cone) + passage
            // slot, floor at z=LIFT
            front_cone(R_T1_BOT, r_pocket(SLANT_CLIP_Z), LIFT, SLANT_CLIP_Z);
            passage1_box(P1_W / 2, LIFT, SLANT_CLIP_Z);
            // rear: prismatic, floor at z=0
            linear_extrude(SLANT_CLIP_Z)
                footprint_slab(Y_P1_REAR, 400);
        }
        slant_cutter();
    }
}

// Front-pocket radius at height z. Measured only over LIFT..LIFT+H_FRONT
// (the STL cone); above that the same lean is assumed to continue — the
// pocket is ~17 mm taller than the cone (see H_FRONT_MAT).
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
                front_cone(R_T1_BOT - TOL, r_pocket(SLANT_CLIP_Z) - TOL,
                           LIFT, SLANT_CLIP_Z);
                passage1_box(P1_W / 2 - TOL, LIFT, SLANT_CLIP_Z);
            }
            union() {
                // void floor at z = LIFT + WALL, OPEN at the slant top
                front_cone(R_T1_BOT - TOL - WALL,
                           r_pocket(SLANT_CLIP_Z) - TOL - WALL,
                           LIFT + WALL, SLANT_CLIP_Z);
                passage1_box(P1_W / 2 - TOL - WALL, LIFT + WALL,
                             SLANT_CLIP_Z);
            }
            slant_cutter();
            // passage-1 bridge relief: the car's bridge (passenger side,
            // spans 20 of the 24) is flush with the TPU mat, so the inlay
            // floor gets a shallow pocket under it and the inlay seats at
            // mat level, top flush. Set BRIDGE_RELIEF=0 if the bridge turns
            // out to sit below the mat.
            if (BRIDGE_RELIEF > 0)
                translate([-P1_W / 2, BRIDGE_Y0, LIFT + WALL - BRIDGE_RELIEF])
                    cube([BRIDGE_LEN, BRIDGE_W, BRIDGE_RELIEF]);
            // A-frame stud holes: the studs sit in the molded floor below
            // the inlay floor; a frame fitted inside the inlay clamps them
            // through these (the C-hook slots drop over the studs)
            if (STUD_HOLES)
                for (sx = [-1, 1])
                    translate([sx * STUD_X_SPAN / 2, STUD_Y, LIFT - 0.5])
                        cylinder(h = WALL + 1, d = STUD_HOLE_D);
        }

        // ---- rear (prismatic) section ----
        difference() {
            linear_extrude(SLANT_CLIP_Z)
                offset(-TOL) footprint_slab(Y_P1_REAR - 0.5, 400 + TOL);
            // inner void: offset in by WALL + TOL, floor WALL thick, open at
            // the slant top -- the tray mouth must not be capped
            translate([0, 0, WALL])
                linear_extrude(SLANT_CLIP_Z - WALL)
                    offset(-(WALL + TOL))
                        footprint_slab(Y_P1_REAR - 0.5, 400 + WALL + TOL);
            slant_cutter();
        }
    }
}

// Fit-check helper: render the cavity as a ghost alongside the inlay.
module cavity_ghost() {
    color("gray", 0.25) cavity();
}
