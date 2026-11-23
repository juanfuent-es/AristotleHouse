# Aristotle House, Route 02 Sensed: toolkit

## 1. Sensor tool (AH_Sensor_Tool.html)
Open in Chrome. Runs offline, nothing is uploaded.
1. Open image or icon (or drop it on the window).
2. Pick a preset: Work · infrared, Work · sensor grid, Work · daylight, House · mono, House · trace, Icon · heat.
3. Optional, for people: in Photoshop use Select > Subject, fill the selection white on black, export a PNG the same size, then "Add subject mask". Body read makes people warm and the room cool, like a real thermal camera.
4. Optional overlays: detection frame and readout label (for drafts; final frames are set in layout).
5. Export PNG, full size.

## 2. Photoshop LUTs (AH_infrared / night / daylight / mono .cube)
Hero retouching: soften the photo first (Gaussian Blur 4 to 8 px at 2000 px wide), add a Color Lookup adjustment layer, load the .cube. Add Noise 3 to 5% on top.
For an exact match, a Gradient Map with the stops below gives the same result.
Infrared stops: 0 #06040C · 16 #14093F · 34 #3A16F2 · 52 #E21FD0 · 68 #FF3D6E · 82 #FF7A1A · 93 #FFD43B · 100 #FFF6DA

## 3. Icons
Draw on AH_icon_grid_template.svg: 24 grid, 2 unit margin, 1.6 stroke, round caps and joins, black on transparent.
Export PNG 600 px, run through the Sensor tool in Icon mode (preset Icon · heat).

## 4. The 3D head
aristotle_2k_compat.glb renders new angles. Tier 2 scan marks are generated from the same renders and should be redrawn as clean master artwork in Illustrator before final delivery.

Colours: Void #0A0A0B · Signal white #F3F3F0 · Instrument grey #8B8B92 · Sensor green #3DFF8A (status only).
Type: ABC Diatype (Expanded, Regular, Mono) by Dinamo, licensed on approval.
