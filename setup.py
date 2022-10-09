import subprocess
import shutil


def setup(args: dict) -> None:
    print("Setting up mouse-tracker")

    print("Building release library")
    subprocess.run(["cargo", "build", "--release", "--lib",
                   "--manifest-path=rust/Cargo.toml"], check=True)

    print("Copying library")
    if args.os == "windows":
        shutil.copyfile("rust/target/release/mouse_poller.dll",
                        "mouse-poller/mouse_poller.dll")
    elif args.os == "linux":
        shutil.copyfile("rust/target/release/libmouse_poller.so",
                        "mouse-poller/libmouse_poller.so")
    elif args.os == "osx":
        print("""\nWARNING\nmouse-poller not yet implemented on osx""")
    else:
        raise Exception("Unhandled os: {}".format(args.os))

    if args.export:
        shutil.rmtree("rust")
        shutil.rmtree("__pycache__")

    print("Finished setting up mouse-tracker")


def clean(_args: dict) -> None:
    print("Cleaning up mouse-tracker")

    subprocess.run(
        ["cargo", "clean", "--manifest-path=rust/Cargo.toml"], check=True)

    print("Finished cleaning up mouse-tracker")


if __name__ == "__main__":
    from argparse import ArgumentParser

    parser = ArgumentParser()

    subparsers = parser.add_subparsers()

    setup_parser = subparsers.add_parser("setup")
    setup_parser.add_argument(
        "--os", choices=["windows", "linux", "osx"], required=True)
    setup_parser.set_defaults(func=setup)

    clean_parser = subparsers.add_parser("clean")
    clean_parser.set_defaults(func=clean)

    args = parser.parse_args()

    args.func(args)
