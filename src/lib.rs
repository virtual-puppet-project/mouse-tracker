use gdnative::prelude::*;
use mouse_rs::Mouse;

#[derive(NativeClass)]
#[inherit(Reference)]
struct MousePoller(Mouse);

#[methods]
impl MousePoller {
    fn new(_owner: &Reference) -> Self {
        MousePoller(Mouse::new())
    }

    #[method]
    fn works_on_system(&self) -> bool {
        self.0.get_position().is_ok()
    }

    #[method]
    fn get_position(&self) -> Vector2 {
        let pos_res = self.0.get_position();

        return if pos_res.is_ok() {
            let pos = pos_res.unwrap();
            Vector2::new(pos.x as f32, pos.y as f32)
        } else {
            godot_error!("Unable to get mouse position, this is likely a bug!");
            Vector2::ZERO
        };
    }
}

fn init(handle: InitHandle) {
    handle.add_class::<MousePoller>();
}

godot_init!(init);
