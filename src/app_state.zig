const std = @import("std");
const rl = @import("raylib");
const SceneTag = @import("scene.zig").SceneTag;


pub const AppState = struct {
	should_exit: bool,
	current_scene: SceneTag,

	pub fn getInstanceMut() *AppState {
		if (!is_initialized) {
			instance = AppState{
				.should_exit = false,
				.current_scene = .MainMenu,
			};
			is_initialized = true;
		}
		return &instance;
	}

	pub fn getInstance() *const AppState {
		return &AppState.getInstanceMut().*; // "re-borrow"
	}
};

var instance: AppState = undefined;
var is_initialized: bool = false;
