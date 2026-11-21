# Local kblade / ms2 hardware definitions

`prospector-zmk-module/` is based on the vendored source snapshot of
`kbladewht/prospector-zmk-module@37146e417cd95ec95ab144ed9ebb6632da06bd8e`.
It includes the kblade board, ms2 shield, display/backlight drivers, shared fonts,
DTS bindings and compatibility headers. The upstream LICENSE and per-file notices
are retained. The MS18T shield and its connector mapping were added from
`kbladewht/prospector-zmk-module@e2b2f5ceb9987865bdea0d9c2962b79a6e892c0f`.
Existing board and shield pin definitions remain unchanged.

The board is defined at `prospector-zmk-module/boards/kblade/` and still builds as
`kblade//zmk`. There is no west project fetching this hardware repository.
Both build scripts add the local module through ZMK_EXTRA_MODULES. Do not add a
second remote prospector-zmk-module project to this workspace: that would duplicate
board/module registration.

The normal Zephyr/ZMK/SDK dependencies remain external; this snapshot replaces the
hardware project only. The source commits above are provenance, not build fetches.

Local MS18T adaptation: the upstream MS18T shield currently disables/removes the
CST816S node. This kl-touch branch restores it using I2C SDA P0.04, SCL P0.05,
TP_IRQ P1.11 (D0), and TP_RST P0.03 (D1), matching the MS18T connector mapping.

Local adaptation: when DYA display settings are enabled, its brightness is the
single owner. The stock screen no longer applies its NVS manual brightness,
1% no-keyboard dimming, or fixed-brightness resume override. Backlight boot PWM
matches DYA's default 60% with the ms2 inverted duty mapping. Board/pin/partition
files remain unchanged.
