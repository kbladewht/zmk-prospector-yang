# MS18T twelve-theme touch scanner

Target: `kblade//zmk`, `prospector_ms18t scanner_display`. Standalone BLE observer.
Display: ST7789, 240×280 portrait / 280×240 landscape. Touch: CST816T,
using Zephyr CST816-family driver (`hynitron,cst816s`); hardware compatibility remains unverified.

MS18T touch wiring:

| Signal | MCU pin |
|---|---|
| TP-INT | P0.29 |
| TP-SDA | P1.15 |
| TP-SCL | P1.13 |
| TP-RET | P0.02 |

The CST816T uses Zephyr's CST816-family driver (`hynitron,cst816s`) at I2C
address `0x15`. TP-RET is wired to the controller reset pin. Display wiring
uses the MS18T shield overlay.

APDS9960 ambient-light sensor wiring:

| Signal | MCU pin |
|---|---|
| SDA | P0.31 |
| SCL | P0.26 |

The APDS9960 uses a separate I2C1 bus from the touch controller and is polled
without an interrupt pin. Brightness is automatically adjusted when the sensor
is detected. The display page shows the current brightness; its manual slider is
temporarily disabled for sensor testing.
The sensor requires 3.3 V, GND, and I2C pull-ups (often present on the breakout).

On the theme page, swipe down/up for next/previous theme (all twelve wrap).
Double tap cycles palette on FIELD/OPERATOR/RADII. Swipe right opens a compact
navigation page; swipe down opens the automatic-brightness status. Swipe up
returns to navigation, then left returns to themes.
This port preserves scanner-mode's gesture directions and coordinate rotation.
The overlay is laid out for the complete 280x240 landscape viewport: the
navigation cards use symmetric 24-pixel margins, the brightness percentage and
slider are centered, and the slider has an extended touch area. The slider uses
the scanner-mode horizontal coordinate mapping so its knob follows the finger
and dragging right increases brightness. The MS18 backlight uses a direct PWM
mapping: 1% is dim and 100% is full brightness.
Touch and DYA share setting values; changes are saved after two seconds of inactivity.

Build with `bash scripts/build-ms18-scanner.sh /path/to/west-workspace`, or run
the manual Actions workflow on `kl-touch`; these only build. `touch.sh` also
waits for the bootloader disk and copies the UF2 to it.

Host validation covered 288 layout states with zero unsafe, clipped, or overlapping
rectangles; receiver tests passed. Firmware compilation with this pin mapping
succeeded. Physical touch and APDS9960 behavior still need device testing.
