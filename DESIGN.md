---
name: "Aristotle House — Heatmap"
version: "1.0"
colors:
  primary: "#0B0A0F"
  ink: "#0B0A0F"
  charcoal: "#2E2E31"
  bone: "#F2EFE8"
  violet: "#4B2EF5"
  lilac: "#C7B8FF"
  pink: "#FF4FB4"
  night: "#141416"
  soft: "#C9C4D4"
  mute: "#A49FB0"
  line: "#3D3A4A"
  paper-line: "#CFCAC0"
  paper-mute: "#625D55"
  danger: "#C2185B"
  danger-night: "#FF7A9F"
typography:
  display:
    fontFamily: "Zalando Sans Expanded"
    fontWeight: 600
    fontSize: "140px"
    lineHeight: "0.92"
    letterSpacing: "-0.03em"
  headline:
    fontFamily: "Zalando Sans Expanded"
    fontWeight: 600
    fontSize: "56px"
    lineHeight: "1"
    letterSpacing: "-0.02em"
  subhead:
    fontFamily: "Inter"
    fontWeight: 500
    fontSize: "30px"
    lineHeight: "1.2"
  body:
    fontFamily: "Inter"
    fontWeight: 400
    fontSize: "18px"
    lineHeight: "1.5"
  readout:
    fontFamily: "Inter"
    fontWeight: 500
    fontSize: "13px"
    letterSpacing: "0.04em"
spacing:
  1: "4px"
  2: "8px"
  4: "16px"
  6: "24px"
  8: "32px"
  16: "64px"
rounded:
  none: "0px"
components:
  button-primary:
    backgroundColor: "{colors.bone}"
    textColor: "{colors.ink}"
    typography: "{typography.body}"
    rounded: "{rounded.none}"
  button-primary-hover:
    backgroundColor: "{colors.violet}"
    textColor: "{colors.bone}"
  button-day:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.bone}"
  surface-night:
    backgroundColor: "{colors.night}"
    textColor: "{colors.bone}"
  surface-day:
    backgroundColor: "{colors.bone}"
    textColor: "{colors.ink}"
---

# Aristotle House — Heatmap

Based on the brand presentation "Route 02, Heatmap" (23 November 2026). Where the
toolkit README in `design/toolkit` differs (ABC Diatype, sensor green), the
presentation wins.

## Overview
The classical form, read by modern senses. A face the world already knows, seen
through the instruments an experiential agency works with every day. Most of every
surface is ink or bone; heat appears where there is something to read.

## Colors
- **Ink, charcoal, bone** are the shadow, the stone and the marble of the bust. They carry most of every surface.
- **Violet** is the unseen, **lilac** is attention, **pink** is a person.
- **Two registers.** The House speaks in the bust's colours with a touch of violet. The Work shows the full spectrum, on people and places. Day uses the spectrum on bone.
- **Contrast.** Violet on ink is below 3:1: never set text in it. On ink the accent for text is lilac; on bone it is violet.

### Spectra
| Name | Use | Stops |
| --- | --- | --- |
| Lyceum | The Work | 0 `#07060D` · 18 `#1B1464` · 36 `#4B2EF5` · 52 `#C7B8FF` · 66 `#FF4FB4` · 78 `#FF2E7E` · 88 `#FF7A5C` · 100 `#FFEFC2` |
| Lyceum ring | Isotherms | 0 `#07060D` · 20 `#1B1464` · 38 `#5B3BFF` · 55 `#FF3FA8` · 68 `#C9B6FF` · 82 `#FF6FB8` · 92 `#FFB08A` · 100 `#FFF3D6` |
| Ultra | The House | 0 `#0B0A14` · 30 `#2A1FA8` · 55 `#5F5CFF` · 75 `#A9A6FF` · 88 `#FF9A84` · 100 `#F3EEE4` |
| Lyceum day | White grounds | 0–32 `#F2EFE8` · 48 `#C7B8FF` · 62 `#6E52FF` · 76 `#FF4FB4` · 90 `#FF7A5C` · 100 `#FFD9A0` |

The WebGL scene reads them from `app/javascript/scene/spectra.js`.

## Typography
- **Zalando Sans Expanded** for display and headlines, always in capitals (CSS `text-transform`, so content stays in sentence case). In the header the name is live type: Zalando, capitals, 800, so it takes the foil. The wordmark artwork in `public/brand` keeps its own case.
- On the holding screen its weight axis (200–900) is live: the letter under the cursor turns black, the far ones go thin. Glass thickness follows the weight.
- **Inter** for everything that is read, and for the readouts (500, 13px, caps, +4%).
- Readouts are a quiet layer at the edges. Do not use them as a label above every section.
- Fonts are self-hosted in `public/fonts` under the SIL Open Font License.

## Marks
- **The gaze** has two masters: light shapes on dark grounds, dark shapes on light grounds. Never inverted, outlined or recoloured inside.
- **The gaze** also signs favicons and app icons. Browser tabs use the dark master on a light browser theme and the light master on a dark theme; raster fallbacks and app icons use the dark master on bone.
- **The seal** is available as a secondary compact mark.
- As space shrinks the brand drops a layer: wordmark and icon, icon alone, seal.
- Files live in `public/brand`. They were extracted from the presentation; replace them with the master artwork when the studio delivers it.
- The default social image is `public/brand/share.jpg`, 1280 × 640. Its editable composition is `design/share.html`, using the self-hosted Zalando Sans Expanded and Inter fonts. Capture it at that viewport after fonts load; page covers still override it.

## Micrographics
- The set lives in one sprite, `public/brand/micro.svg`, drawn in the text colour with the `micrograph` helper: symbols (crosshair, globe, barcode, ruler, peripatetic, portrait, seated, head-left, head-front, head-right) and the toolkit's line icons (`icon-*`).
- They belong to the interiors: projects, House, sign in, admin. Small, one per place, never louder than the text.
- The holding screen only uses the three heads, which turn the bust, and a small sight on the pointer.
- Never publish the presentation's sample readings.

## Climate
- `/climate.json` describes the air over Dubai; the holding screen shows hour, temperature and wind, and moves with them. Sun above 4° turns the page to bone and the spectrum to Lyceum day; below, ink and Lyceum. Never a mix of both. Near the horizon a band of heat rises.
- Temperature moves the whole reading along the spectrum: violet and lilac when cool, orange and cream when hot. Wind drives the drift, humidity the halo, cloud flattens the light.
- Live, Day and Night preview the page with the forecast for 13:00 and 23:00. `/?at=17:10` previews any hour.
- With no data the reading is hidden, not invented. MET Norway is credited in `/humans`.

## Layout & Elevation
- Square corners, 1px rules, no shadows. Depth comes from light and from tone.
- Corners carry the facts; the centre carries the feeling.
- Everything is ink with bone type: site, sign in, admin, editor and errors. Bone grounds appear only when it is day in Dubai.
- One shell for every page, `layouts/application`. Admin, sign in, errors and the holding screen render inside it, with the same header, footer and components. Administrators get one thin bar on top.

## Motion
- Heat moves slowly, like attention. Nothing bounces.
- The bust turns to study whoever is there. The pointer leaves warmth that fades.
- With reduced motion the scene is a still image.

## Foil
- The holographic foil of the presentation lives on type, not on cards. Whatever is set in Zalando capitals takes it (`display`, `lead`, `headline`, `title`, `wordmark`), and so do text links. It spreads from the point of contact and follows the pointer.
- On ink it uses the presentation's eleven stops; on bone only their saturated half. Never on body text, buttons or fields.
- Touch screens and keyboards keep the usual states.

## Editing
- Editing keeps the page as visitors see it: fields inherit its type and only add a 1px rule.
- Tools are quiet: one bar at the top, one above the text.

## Do's and Don'ts
- Do show people, clients' products and finished spaces as shot, without filters.
- Do let the client lead on their work: their name as a fact, never their logo redrawn.
- Don't put a spectrum behind text that has to be read or behind a form.
- Don't publish the presentation's sample clients, people or figures.

## Implementation
Tailwind is the only styling layer, in `app/assets/stylesheets/design-system/`:

- `tokens.css`: palette, type scale, the gutter and the roles as utilities (`bg-canvas`, `text-copy`, `text-soft`, `text-mute`, `border-line`, `text-accent`, `text-danger`), plus the variants `day:` and `tall:`.
- `theme.css`: the values of those roles for `.night` and `.day`, and the base styles.
- `components.css`: the components, written with `@apply`.

A pattern that repeats becomes a component there; anything that happens once is written
with utilities in the view. No other stylesheets, and no raw colours in views. Token values
are kept in step with this front matter by hand.
