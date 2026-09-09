# Cup-holder inlay

Parametric OpenSCAD inlay for the EV6 centre-console cup area: immobilises the
four factory spring tabs (the rattle source) and adds a rattle-free grip for a
58 mm thermos or a 66 mm 0.5 l PET bottle in the front pocket.

## Files

- `ev6_cup_inlay.scad` — parameters (calipered + TODO), assembly, fit report
- `lib_geometry.scad` — the three-tray envelope, 8 mm step, inlay shell
- `lib_parts.scad` — arc leaf-spring grip, factory-tab traps, test cups

## Render

```sh
openscad -o inlay.png   -D 'TEST_CUP="none"'    ev6_cup_inlay.scad
openscad -o thermos.png -D 'TEST_CUP="thermos"' ev6_cup_inlay.scad
openscad -o pet.png     -D 'TEST_CUP="pet"'     ev6_cup_inlay.scad
```

`TEST_CUP` drops a translucent test cup into the front pocket and renders the
grip mechanism engaged against it. The compile-time `echo` report prints
pocket ID, per-cup deflection, and the max arm strain.

## The grip mechanism

Three arc-segment leaf-spring tabs (passenger, driver, front; the rear quadrant
is left clear for the trapped factory tabs). Each arm is an annular sector
following the pocket curvature, so nothing pokes through the circular wall.
The pad is printed 0.3 mm past its stop face, so in the car the arm is
pre-stressed and the pad is always pressed home — zero free play, and a hard
stop at the other end of travel (the cup), so it cannot rattle. PET engagement
bends the 1.2 mm arm ~4.6 mm over a 20 mm lever (~2 % strain).

## Print notes

- FDM, 0.2 mm layers, PETG preferred (arm flex + car heat).
- Print as-is (open top up): walls are vertical, no supports needed; the grip
  pad bridges ~4 mm above the pocket floor (`GRIP_Z0`).
- `TOL = 0.15` per side vs the car; drop to 0.1 if the fit feels loose.

## TODO — measurements still needed

- `H_DEPTH` — console surface to lower-tray floor
- `L_T2_CONN` — length of tray 2's 24 mm connector
- `L_T3_END_L` / `L_T3_END_R` / `R_T3_CORNER` — tray 3 triangular end
- `TAB1_ANG`, `TAB2_POS` — factory tab positions (a photo helps)
- `BOSS_W` / `BOSS_LEN` / `TAB_CH_W` / `TAB_CH_D` — factory tab size
- `GRIP_Z0` — land the grip band on the actual bottle's body band
