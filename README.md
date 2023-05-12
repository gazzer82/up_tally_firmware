# UpTallyFirmware

**Description**
Firmware for running the UpTally phoenix application on a Grisp2 board https://www.grisp.org

## Targets

Nerves applications produce images for hardware targets based on the
`MIX_TARGET` environment variable. If `MIX_TARGET` is unset, `mix` builds an
image that runs on the host (e.g., your laptop). This is useful for executing
logic tests, running utilities, and debugging. Other targets are represented by
a short name like `rpi3` that maps to a Nerves system image for that platform.
All of this logic is in the generated `mix.exs` and may be customized. For more
information about targets see:

https://hexdocs.pm/nerves/targets.html#content

## Getting Started

To install the UpTallyFirmware app:

- `export MIX_TARGET=grisp2`
- Install dependencies with `mix deps.get`
- Create firmware with `mix firmware`

If this is being installed onto a clean board:

- generate a firmware img `mix firmware.image`
- gzip it `gzip up_tally_firmware.img`
- copy it to a fat32 formwatted SD card, and insert into Grisp2 board
- Connect Grisp2 board to a computer using a USB cable
- Immediatley Open a serial console to the board `picocom /dev/tty.usbserial-011571 --baud 115200` and interrupt the boot sequence by pressing any key.
- Load the SD card by entering `ls mnt`
- Copy the image to the emmc `uncompress /mnt/mmc/up_tally_firmware.img.gz /dev/mmc1` then `reset`
- Board will now restart, run Ecto migrations and load the application

## Updating

If the board already has a running image:

- Generate the firmware `mix firmware`
- Upload it to the board with `./upload.sh` (This assumes the board is on IP address 192.168.10.25)
- Board will restart

## Resetting

To clear all existing persisted data follow these steps:

- Connect the board to a computer vua USB and allow the board to boot.
- Open a serial console to the board `picocom /dev/tty.usbserial-011571 --baud 115200` and interrupt the boot sequence by pressing any key.
- Corrupt the application folder to force a rebuild `dd if=/dev/zero of=/dev/mmcblk1p3 bs=128K count=1`
- Restart the board

## Learn more

- Official docs: https://hexdocs.pm/nerves/getting-started.html
- Official website: https://nerves-project.org/
- Forum: https://elixirforum.com/c/nerves-forum
- Discussion Slack elixir-lang #nerves ([Invite](https://elixir-slackin.herokuapp.com/))
- Source: https://github.com/nerves-project/nerves
- Nerves System Grisp 2 https://github.com/nerves-project/nerves_system_grisp2
