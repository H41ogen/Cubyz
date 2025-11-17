const std = @import("std");

const main = @import("../../main.zig");
const Vec2f = main.vec.Vec2f;
const c = main.Window.c;
const gui = @import("../gui.zig");
const GuiComponent = gui.GuiComponent;
const GuiWindow = gui.GuiWindow;
const Button = @import("../components/Button.zig");
const CheckBox = @import("../components/CheckBox.zig");
const HorizontalList = @import("../components/HorizontalList.zig");
const Label = @import("../components/Label.zig");
const VerticalList = @import("../components/VerticalList.zig");
const ContinuousSlider = @import("../components/ContinuousSlider.zig");

pub var window = GuiWindow{
	.contentSize = Vec2f{192, 192},
	.closeIfMouseIsGrabbed = true,
};

const padding: f32 = 8;
pub var needsUpdate: bool = false;

fn frictionFormatter(allocator: main.heap.NeverFailingAllocator, value: f32) []const u8 {
	return std.fmt.allocPrint(allocator.allocator, "Friction: {d:.2}", .{value}) catch unreachable;
}

fn updateCinematicCamera(newValue: bool) void {
	main.game.camera.cinematicCamera.vel = @splat(0);
	main.game.camera.cinematicMode = newValue;
}
fn updateCinematicCameraFriction(newValue: f32) void {
	main.game.camera.cinematicCamera.friction = @round(newValue*100)/100;
}

pub fn onOpen() void {
	const list = VerticalList.init(.{padding, 16 + padding}, 364, 8);

	list.add(Label.init(.{0, 0}, 192, "Cinematic Camera", .center));
	list.add(CheckBox.init(.{0, 0}, 192, "Enabled?", main.game.camera.cinematicMode, &updateCinematicCamera));
	list.add(ContinuousSlider.init(.{0, 0}, 192, 0, 1, main.game.camera.cinematicCamera.friction, &updateCinematicCameraFriction, &frictionFormatter));

	list.finish(.center);
	window.rootComponent = list.toComponent();
	window.contentSize = window.rootComponent.?.pos() + window.rootComponent.?.size() + @as(Vec2f, @splat(padding));
	gui.updateWindowPositions();
}

pub fn onClose() void {
	if(window.rootComponent) |*comp| {
		comp.deinit();
	}
}

pub fn render() void {
	if(needsUpdate) {
		needsUpdate = false;
		const oldScroll = window.rootComponent.?.verticalList.scrollBar.currentState;
		onClose();
		onOpen();
		window.rootComponent.?.verticalList.scrollBar.currentState = oldScroll;
	}
}
