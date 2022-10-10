import platform
import subprocess
import shutil
import os

WINDOWS: str = "windows"
LINUX: str = "linux"
OSX: str = "osx"


def setup(args: dict) -> None:
    print("Setting up mouse-tracker")

    print("Building release library for OS {}".format(args.os), flush=True)
    subprocess.run(["cargo", "build", "--release", "--lib",
                   "--manifest-path=rust/Cargo.toml"], check=True)
    print("Finished building release library", flush=True)

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
        if os.path.isdir("__pycache__"):
            shutil.rmtree("__pycache__")
        shutil.rmtree(".github")

    print("Finished setting up mouse-tracker")


def clean(_args: dict) -> None:
    print("Cleaning up mouse-tracker")

    print("Running cargo clean", flush=True)
    subprocess.run(
        ["cargo", "clean", "--manifest-path=rust/Cargo.toml"], check=True)
    print("Finished running cargo clean", flush=True)

    print("Finished cleaning up mouse-tracker")


if __name__ == "__main__":
    os.chdir(os.path.dirname(os.path.realpath(__file__)))

    from argparse import ArgumentParser

    parser = ArgumentParser()

    subparsers = parser.add_subparsers()

    setup_parser = subparsers.add_parser("setup")
    setup_parser.add_argument(
        "--os", choices=["windows", "linux", "osx"], default="")
    setup_parser.add_argument("--export", action="store_true")
    setup_parser.set_defaults(func=setup)

    clean_parser = subparsers.add_parser("clean")
    clean_parser.set_defaults(func=clean)

    args = parser.parse_args()

    if not args.os:
        args.os = platform.system()
        if args.os == "Windows":
            args.os = WINDOWS
        elif args.os == "Linux":
            args.os = LINUX
        elif args.os == "Darwin":
            args.os = OSX
        else:
            raise Exception("Unhandled OS: {}".format(args.os))

    args.func(args)
