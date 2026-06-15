extends SceneTree
# ---------------------------------------------------------------------------
# Windowed screenshot capturer for Godot 4.6.
# IMPORTANT: this needs a rendering context, so it is run WITHOUT --headless.
# verify.sh launches it like:
#   VERIFY_SHOT="/abs/path/shot_<ts>.png" godot --path "<PROJECT>" \
#       --rendering-driver metal --script "res://_verify/screenshot.gd"
#
# It loads the main scene, lets it render for a few seconds, grabs one frame
# from the root viewport, saves it as a PNG (path from $VERIFY_SHOT), and quits.
# ---------------------------------------------------------------------------

const MAIN_SCENE := "res://Main.tscn"
const WAIT_FRAMES := 180   # ~3 seconds at 60 FPS

var frames := 0
var out_path := ""

func _initialize() -> void:
	out_path = OS.get_environment("VERIFY_SHOT")
	if out_path == "":
		out_path = "res://_verify/shot.png"
	print("=== screenshot.gd start (target: %s) ===" % out_path)
	var packed := load(MAIN_SCENE)
	if packed == null:
		printerr("SHOT_FAIL: cannot load " + MAIN_SCENE)
		quit(1)
		return
	var inst: Node = (packed as PackedScene).instantiate()
	root.add_child(inst)
	current_scene = inst

func _process(_delta: float) -> bool:
	frames += 1
	if frames < WAIT_FRAMES:
		return false  # keep running
	var img := root.get_texture().get_image()
	if img == null:
		printerr("SHOT_FAIL: viewport image is null (no render context?)")
		quit(1)
		return true
	var err := img.save_png(out_path)
	if err != OK:
		printerr("SHOT_FAIL: save_png error %d for %s" % [err, out_path])
		quit(1)
		return true
	print("SHOT_OK: " + out_path)
	quit(0)
	return true
