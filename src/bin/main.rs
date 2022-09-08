use mouse_rs::Mouse;
use std::{thread, time};

fn main() {
    println!(
        "Running in binary mode, this is just a test of mouse_rs\nPrinting mouse position 3 times!"
    );

    let mouse = Mouse::new();
    let delay = time::Duration::from_secs(1);

    for _ in 0..3 {
        print_and_sleep(&mouse, &delay);
    }

    println!("Done!");
}

fn print_and_sleep(mouse: &Mouse, delay: &time::Duration) {
    let pos = mouse.get_position().unwrap();
    println!("x: {}, y: {}", pos.x, pos.y);

    thread::sleep(*delay);
}
