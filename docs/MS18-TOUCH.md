# MS18 twelve-theme touch scanner

This document describes the original MS18 shield, not the separate MS18T shield.
Target: `kblade//zmk`, `prospector_ms18 scanner_display`. Standalone BLE observer.
Display: ST7789, 240×280 portrait / 280×240 landscape. Touch: CST816T,
using Zephyr CST816-family driver (`hynitron,cst816s`); hardware compatibility remains unverified.

Touch wiring follows S7venYoung/zmk-prospector `scanner-mode`, hardware module
`7ff9302680c7c5dc9e12b4f3497204c99881de08`:

| FPC pin | Signal | Trial MCU pin |
|---|---|---|
| 13 | TP_SCL | P0.05 |
| 14 | TP_SDA | P0.04 |
| 15 | TP_RST | P0.28 |
| 16 | TP_INT | P0.02 |

FPC pin numbers are panel connections, not MCU GPIO numbers. Actual MS18 PCB
routing must be confirmed on hardware. Display wiring retains the MS18 overlay.

On the theme page, swipe down/up for next/previous theme (all twelve wrap).
Double tap cycles palette on FIELD/OPERATOR/RADII. Swipe right opens a compact
navigation page; swipe down opens brightness settings. Drag the slider to set
1–100%; swipe up returns to navigation, then left returns to themes.
This port preserves scanner-mode's gesture directions and coordinate rotation;
it uses compact navigation/brightness panels, not the complete legacy settings UI.
Touch and DYA share setting values; changes are saved after two seconds of inactivity.

The current `touch.sh` builds MS18T, not this MS18 target. Physical MS18 touch
behavior and PCB routing still need device verification.
