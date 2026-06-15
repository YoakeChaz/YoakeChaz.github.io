extends SceneTree
# ---------------------------------------------------------------------------
# Headless project validator for Godot 4.6
# Run (called automatically by verify.sh):
#   godot --headless --path "<PROJECT>" --script "res://_verify/validate.gd"
#
# Walks every .gd / .tscn / .tres / .res under res:// and reports:
#   - GDScript files that fail to load/compile (syntax / parse errors)
#   - Scenes that fail to load (broken ext_resource / missing uid) or instantiate
#   - Resources that fail to load
# Prints "VERIFY_OK" and exits 0 when clean, "VERIFY_FAIL" + a list and
# exits 1 when anything is broken.
# ---------------------------------------------------------------------------

const SKIP_DIRS := [".godot", ".git", ".import"]

var errors: Array = []
var checked := 0

func _initialize() -> void:
	print("=== validate.gd start ===")
	var files := _scan("res://")
	for f in files:
		if f.ends_with(".gd"):
			_check_script(f)
		elif f.ends_with(".tscn") or f.ends_with(".scn"):
			_check_scene(f)
		elif f.ends_with(".tres") or f.ends_with(".res"):
			_check_resource(f)
	print("Checked %d file(s)." % checked)
	if errors.is_empty():
		print("VERIFY_OK: no script/scene/resource errors found")
		quit(0)
	else:
		printerr("VERIFY_FAIL: %d problem(s) found:" % errors.size())
		for e in errors:
			printerr("  - " + str(e))
		quit(1)

func _scan(root: String) -> Array:
	var out: Array = []
	var dir := DirAccess.open(root)
	if dir == null:
		return out
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if entry == "." or entry == "..":
			entry = dir.get_next()
			continue
		var path := root.path_join(entry)
		if dir.current_is_dir():
			if not SKIP_DIRS.has(entry):
				out.append_array(_scan(path))
		else:
			out.append(path)
		entry = dir.get_next()
	dir.list_dir_end()
	return out

func _check_script(path: String) -> void:
	checked += 1
	var res := ResourceLoader.load(path, "Script", ResourceLoader.CACHE_MODE_IGNORE)
	if res == null:
		errors.append("Script failed to load/compile: " + path)

func _check_scene(path: String) -> void:
	checked += 1
	var packed := ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_REPLACE)
	if packed == null:
		errors.append("Scene failed to load (broken ext_resource / missing uid?): " + path)
		return
	var inst: Node = (packed as PackedScene).instantiate()
	if inst == null:
		errors.append("Scene failed to instantiate: " + path)
	else:
		inst.free()

func _check_resource(path: String) -> void:
	checked += 1
	var res := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)
	if res == null:
		errors.append("Resource failed to load: " + path)
