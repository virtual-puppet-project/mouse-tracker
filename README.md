# mouse-tracker
A mouse tracker for [vpuppr](https://github.com/virtual-puppet-project/vpuppr).

Uses [mouse-rs](https://github.com/AltF02/mouse-rs) via [GDNative](https://docs.godotengine.org/en/stable/tutorials/scripting/gdnative/what_is_gdnative.html) to poll a user's mouse position.

## Building

1. Install the latest stable [Rust](https://www.rust-lang.org/) toolchain
2. Install Python 3.8+
3. Run `python3 setup.py --setup`

## Using with [vpuppr](https://github.com/virtual-puppet-project/vpuppr)

### Prebuilt release

1. [Download the latest release](https://github.com/virtual-puppet-project/mouse-tracker/releases)
2. Find vpuppr's resource folder (usually located next to the executable)
3. Unzip the contents of the prebuilt release into `resources/extensions/mouse-tracker/`. Create the folder if it does not exist
4. Use the tracker in the app!

### Manual build

1. Find vpuppr's resource folder
2. Create a new folder at `resources/extensions/mouse-tracker/`
3. Copy the following folders and files to that new directory
    * `./mouse-poller/`
    * `./translations/`
    * `mouse_tracker.gd`
    * `gui.gd`
    * `config.toml`
4. Use the tracker in the app!
