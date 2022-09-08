# mouse-tracker
A mouse tracker for [vpuppr](https://github.com/virtual-puppet-project/vpuppr).

Uses [mouse-rs](https://github.com/AltF02/mouse-rs) via [GDNative](https://docs.godotengine.org/en/stable/tutorials/scripting/gdnative/what_is_gdnative.html) to poll a user's mouse position.

## Building

1. Install the latest stable [Rust](https://www.rust-lang.org/) toolchain
2. Run `cargo build --lib --release` to build the library
3. Copy the compiled library under `target/release/<lib-name>.<lib-extension>` to `lib/`
