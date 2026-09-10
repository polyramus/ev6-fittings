# Cup-holder inlay

Parametric OpenSCAD inlay for the EV6 centre-console cup area: immobilises the
four factory spring tabs (the rattle source) and adds a rattle-free grip for a
58 mm thermos or a 66 mm 0.5 l PET bottle in the front pocket.

## Files

- `ev6_cup_inlay.scad` — grip parameters, render switches, assembly, fit report
- `lib_geometry.scad` — all dimensional parameters + the three-tray envelope,
  conical front pocket, inlay shell, slanted console top
- `lib_parts.scad` — arc leaf-spring grip, factory-tab traps, test cups
- `aframe.scad` — the A-frame divider (see below), standalone part
- `../data/` — the source data: `EV6 Utility Cup.stl`, `IMG_5344` (mat on a
  14" MBP, top view), `IMG_5345` (front pocket with the factory tabs),
  `IMG_5346` (console slant), `IMG_5347`/`IMG_5348` (mat + A-frame divider)

## Dimension provenance (2026-09-09, updated 2026-09-10)

- **Front pocket — precise (lower 62.5 mm).** `data/EV6 Utility Cup.stl`
  (Thingiverse, "EV6 Utility Cup (Precision Fit)") is a *negative* of the
  front cavity: conical, Ø75.07 at the seating level → Ø82.46 at its top,
  62.5 mm tall (walls lean out 3.7 mm/side). The part seats on the TPU mat.
  The pocket itself is taller (~79 mm from the mat to the console top — see
  the slant below), so the model continues the measured lean above the cone
  (`r_pocket`); the extra ~17 mm of wall is an assumption, flagged there.
- **Console top — slanted.** Caliper to the molded floor: 82 mm at the front,
  ~75 at the back; the TPU mat under the front pocket is ~3 mm, so the front
  pocket is ~79 from its floor (`H_FRONT_MAT`; if the caliper rested on the
  mat, set it to 82). With level floors (assumed) the top is one plane
  through (y=0, z=87) and (y=300.6, z=75) — `H_top(y)`, ~2.3°, falling to
  the rear. Everything is trimmed with `slant_cutter()`, so the inlay top is
  flush with the console top along the whole slant.
- **Rear footprint — photo.** `data/IMG_5344.jpg`: top view of the car's soft
  TPU mat on a 14" MacBook Pro (221.3 mm short side as scale). Total length
  298.9 mm, 24 mm passage, tab-notch pairs at both step corners, the 20×9 mm
  passenger-side bridge, and the long asymmetric tray-3 taper to a ~12 mm
  passenger tip (the LHD chamfer — the RHD variant is its mirror).
- **Everything else** calipered by the owner. "width" = X (transverse),
  "length" = Y (fore-aft).

## Render

```sh
openscad -o inlay.png   -D 'TEST_CUP="none"'    ev6_cup_inlay.scad
openscad -o thermos.png -D 'TEST_CUP="thermos"' ev6_cup_inlay.scad
openscad -o pet.png     -D 'TEST_CUP="pet"'     ev6_cup_inlay.scad
```

`TEST_CUP` drops a translucent test cup into the front pocket and renders the
grip mechanism engaged against it. The compile-time `echo` report prints
pocket ID at seat/grip height, per-cup deflection, and the max arm strain.

## The factory-tab traps (measured 2026-09-10)

The four factory tabs are spring flaps 7.5 wide x 30 tall in wall openings:
pivot near the top, ~14 mm of free-end travel, folding fully into the wall
when pressed (which is exactly how the owner keeps them quiet). All four sit
~30 mm above their tray floor — the tray-2 pair level with the front pair.
(The white lines in photo `IMG_5345` are duct-tape residue from earlier
makeshift fastening, not damage.)

- **Front pocket** — two tabs ~45 deg each side of the passage (photo
  `IMG_5345`), on the cone. Traps are **flush-press bosses**: a tapered
  plate following the cone, its face 0.2 mm in front of the console wall
  face. The flap is trapped behind the inlay wall, so the face alone limits
  its bulge to 0.2 mm instead of 14 mm — no channel needed.
- **Tray 2** — two identical tabs on the 75→51 step faces (the mat notch
  pair, 6 mm in from each passage-2 wall), flaps tilted 45 deg toward each
  other — an X seen from above. No feature needed: the inlay's offset wall
  band runs full height over those faces, so the band's own face (0.15 mm
  in front of the car face) is the flush-press limiter.

Insertion: press all four tabs in, drop the inlay, and they stay
immobilised.

## The grip mechanism

Three arc-segment leaf-spring tabs (passenger, driver, front; the rear
quadrant is left clear for the trapped factory tabs). Each arm is an annular
sector following the pocket curvature, so nothing pokes through the circular
wall. The pad is printed 0.3 mm past its stop face, so in the car the arm is
pre-stressed and the pad is always pressed home — zero free play, and a hard
stop at the other end of travel (the cup), so it cannot rattle. PET
engagement bends the 1.2 mm arm ~4.6 mm over a 20 mm lever (~2 % strain —
at the low end of PLA/PETG yield).

## Print notes

- FDM, 0.2 mm layers, PETG preferred (arm flex + car heat).
- Print as-is (open top up): walls are vertical or leaning out, no supports
  needed; the grip pad bridges ~4 mm above the pocket floor (`GRIP_Z0`).
  The top rim is a slanted plane (the console slant) — cosmetic only.
- `TOL = 0.15` per side vs the car; drop to 0.1 if the fit feels loose.

## TODO — measurements still needed

Photo-derived values are soft-mat estimates (±3 mm); caliper to confirm:

- `H_FRONT_MAT` (79) — is the 82 mm caliper read to the molded floor (as
  assumed, minus the ~3 mm mat) or to the mat itself (then 82)? Also the
  ~17 mm of front-pocket wall above the measured STL cone assumes the lean
  continues — confirm the pocket's true top radius.
- `L_T2_CONN` (24), `L_T3_END_L` (50) / `L_T3_END_R` (20), `TIP_W` (12),
  `R_T3_CORNER` (6) — the rear end from the photo
- `BRIDGE_RELIEF` (1) — confirm the car's passage-1 bridge is flush with the
  mat top; set 0 if it sits below
- `GRIP_Z0` — land the grip band on the actual bottle's 66 mm body band
  (the test PET's 18 mm flare is a placeholder; measure the real bottle)
- The inlay seats on the TPU mat; if the mat compresses under the front
  section, the seat height shifts — verify in the car. The mat also has
  slightly raised sides extending ~1 mm past the base.

## The A-frame divider (`aframe.scad`)

The car's detachable A-frame (79 wide x 61 tall, 45 at the base, circular
cutout for the middle tray, rounded ~22 top) runs **across** the front
pocket: the 79 mm is the transverse (X) width, press-fit in the 75→82.46
cone, and the "A" section stands in Y-Z (45 mm base along Y, 61 mm tall,
rounded ~22 top). It also damps the rattle from the three loose plastic
layers on the passenger-side console wall: two inside supports clamp onto
**two studs in the pocket floor** (50 mm apart on the factory part).
Pressing the frame down tightens the press fit in the cone, the console
walls bulge ever so slightly outward, and that tensions the three-layer
cover just enough to stop it rattling — the owner's 0.5 mm tape shims
(50 → 50.5 mm) strengthen the effect. The printable replacement is modeled
at **50.5** (the factory part is injection molded, but the shape lends
itself to FDM). See `IMG_5347`/`IMG_5348`.

The "A" is an **arch**: two legs 45 apart in Y, a web, a rounded top (r =
22.5, the closing semicircle over the 45), extruded 79 across the pocket.
The outer face is trimmed to the cone (`r_pocket - TOL`) so the 79 band
hugs it like the inlay — the factory 79 is the cone's ID at mid-height.

**Assumed, not measured** (flagged in the file header): where it sits in
Y, the cutout size/height, the floor-stud centreline and diameter, and the
leg thickness. One open contradiction: with the rear leg *on* the passage
the 24 mm full-height slot can't clear a circular cutout, so the model
sits the frame in front of the passage (`AFRAME_Y0 = 20`) — confirm the
real frame's position and whether its rear-leg opening is a slot.
