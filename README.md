Alpine Linux on the Asus Transformer Mini T102A
===============================================

The Asus Transformer Mini (model T102A or T102HA, which seem
interchangeable) is mostly functional with Alpine's stock
kernel. There's support for almost everything in the kernel,
however, and it just needs to be built. I've also written a
simple script for the ACPI daemon to invoke to put the tablet
to sleep when the folio is closed.

Kernel Configuration
--------------------

`T102HA.config` is the kernel configuration I've built based
on what the firmware reports through ACPI tables and `dmesg`
logs. Note that the DSDT shows several power management chips
(PMCs) but it seems only one is used in this PC. I tried
enabling support for all of them but the kernel only
successfully found one. From a disassembly of the DSDT, it
appears there's support for several PMCs, but only one is
selected based on a value from an operation region.

ACPI EC support is included, but the DSDT's _STA_ method
returns zero, so I may remove support for this. No kernel
messages mention the EC.

S0ix Support
------------

S0i3 only works once from the framebuffer console. After the
first suspend and resume, the system won't enter deep sleep
again as long as the framebuffer console remains active. The
GFX RENDER and GFX MEDIA PUNIT North Complex devices remain
active in D0. Once a Wayland compositor takes over, these 
enter D0i3 and can be suspended and resumed repeatedly,
entering S0i3 each time.

I suspected this when Intel's S0ix troubleshooting script
depended on a X11 utility to turn the display off. It's
probably not tested well in framebuffer mode, which makes
sense for the desktop use case.

ACPI Sleep
----------

The Power/Sleep button on the tablet is mapped to PWRF,
which Alpine's default ACPI handler treats as instant
shutdown by invoking `poweroff`. I just removed this handler.

The LID handler script I wrote puts the tablet to sleep, then
upon waking up checks whether the lid is still closed, and
goes back to sleep if it is. This way, connecting or
disconnecting the charger while the folio is closed only
wakes the tablet up for a very short time.

Issues
------

I use `kanshi` to rotate my Wayland sessions, and I include
`fbcon=rotate:1` on my kernel's command line. The tablet
defaults to portrait mode. I don't have the accelerometer
working as of yet. The folio's trackpad defaults to the
correct orientation, though.

The folio appears to the system as USB devices, which meant
disable-while-typing couldn't be enabled, as the folio
was detected as an external keyboard (which I guess is the
case!) Adding a quirk in
`/etc/libinput/local-overrides.quirks` corrected this,
courtesy of [werefkin's post](https://bbs.archlinux.org/viewtopic.php?id=300477).

How to Use These
----------------

`T102HA.config` is a kernel configuration file.

Place `local-overrides.quirks` in `/etc`. It marks the
folio keyboard as internal, allowing it to trigger
disable-while-typing.

`config` goes into your `$XDG_CONFIG_HOME/kanshi`. It rotates
the tablet display 270 degrees, perfect for use with the
folio attached.

`LID` contains the handler script for closing the folio. Copy
it to `/etc/acpi`, making sure to back up any existing LID
handlers you want to keep.
