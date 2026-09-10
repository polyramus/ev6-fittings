# Cup-holder inlay

Parametric OpenSCAD inlay for the EV6 centre-console cup area: immobilises the
four factory spring tabs (the rattle source) and adds a rattle-free grip for a
58 mm thermos or a 66 mm 0.5 l PET bottle in the front pocket.

## Files

- `ev6_cup_inlay.scad` — grip parameters, render switches, assembly, fit report
- `lib_geometry.scad` — all dimensional parameters + the three-tray envelope,
  conical front pocket, inlay shell
- `lib_parts.scad` — arc leaf-spring grip, factory-tab traps, test cups
- `../data/` — the source data: `EV6 Utility Cup.stl`, `IMG_5344` (mat on a
  14" MBP, top view), `IMG_5345` (front pocket with the factory tabs),
  `IMG_5346` (console slant), `IMG_5347`/`IMG_5348` (mat + A-frame divider)

## Dimension provenance (2026-09-09)

- **Front pocket — precise.** `data/EV6 Utility Cup.stl` (Thingiverse, "EV6
  Utility Cup (Precision Fit)") is a *negative* of the front cavity: conical,
  Ø75.07 at the seating level → Ø82.46 at the console surface, 62.5 mm tall
  (walls lean out 3.7 mm/side). The part seats on the TPU mat, so the 8 mm
  step + 62.5 mm gives `H_DEPTH = 70.5`.
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
when pressed. Both front-pocket tabs sit ~45 deg each side of the passage
(photo `IMG_5345`) and are **broken at the tip** — that is the rattle source.

The front-pocket traps are **flush-press bosses**: a tapered plate following
the cone, its face 0.2 mm in front of the console wall face. The flap is
trapped behind the inlay wall, so the face alone limits its bulge to 0.2 mm
instead of 14 mm — no channel needed. Insertion: press both tabs in, drop
the inlay, and they stay immobilised.

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
- Print as-is (open top up): walls are vertical, no supports needed; the grip
  pad bridges ~4 mm above the pocket floor (`GRIP_Z0`).
- `TOL = 0.15` per side vs the car; drop to 0.1 if the fit feels loose.

## TODO — measurements still needed

Photo-derived values are soft-mat estimates (±3 mm); caliper to confirm:

- **Console top slant** — the console top is visibly slanted (higher at
  the front; `IMG_5346`). Owner's caliper reads 82 mm front / ~75 mm back
  console-to-floor, but the STL part is exactly 62.5 mm and seats flush, so
  the 82/75 reference (molded floor vs mat surface) and the slant's drop
  over what length still need confirming. Until then the model keeps a flat
  top at `H_DEPTH = 70.5`.
- `TAB1_Z0` — bottom of the 30 mm wall opening above the pocket floor. The
  photo shows the tabs sitting low (pivot ~30 mm up), so it is 0 for now.
- Tray-2 tab traps — position/orientation at the 75→51 step are still the
  placeholder box boss + channel (`BOSS_W` / `BOSS_LEN` / `TAB_CH_W` /
  `TAB_CH_D`); confirm the tabs are the same 7.5 x 30 flap family and where
  exactly they sit.
- `L_T2_CONN` (24), `L_T3_END_L` (50) / `L_T3_END_R` (20), `TIP_W` (12),
  `R_T3_CORNER` (6) — the rear end from the photo
- `BRIDGE_RELIEF` (1) — confirm the car's passage-1 bridge is flush with the
  mat top; set 0 if it sits below
- `GRIP_Z0` — land the grip band on the actual bottle's 66 mm body band
  (the test PET's 18 mm flare is a placeholder; measure the real bottle)
- The inlay seats on the TPU mat; if the mat compresses under the 62.5 mm
  front section, the seat height shifts — verify in the car

## The A-frame divider (not yet modeled)

The car's detachable A-frame (79 wide x 61 tall, 45 at the base, circular
cutout for the middle tray, rounded ~22 top) also damps the rattle from the
three loose plastic layers on the passenger-side console wall. Its inside
supports sit 50 mm apart; the owner tape-shims them to ~50.5 for a tighter
fit. To be modeled as a printable replacement with the 50.5 fit once its
in-use orientation is confirmed (see `IMG_5347`/`IMG_5348`).
