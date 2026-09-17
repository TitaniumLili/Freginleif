extends Node

const SCAN_ROOT: String = "res://"
const RUNS: int = 5

const SKIP_DIRS: Array[String] = [".godot", "addons"]

class BenchResult:
	var path: String
	var name: String
	var times_ms: Array[float]
	var min_ms: float
	var max_ms: float
	var avg_ms: float
	var last_return: Variant

	func _init(
		p_path: String,
		p_name: String,
		p_times_ms: Array[float],
		p_min_ms: float,
		p_max_ms: float,
		p_avg_ms: float,
		p_last_return: Variant
	) -> void:
		path = p_path
		name = p_name
		times_ms = p_times_ms
		min_ms = p_min_ms
		max_ms = p_max_ms
		avg_ms = p_avg_ms
		last_return = p_last_return

func _ready() -> void:
	var scripts: Array[String] = _discover_bench_scripts(SCAN_ROOT)

	if scripts.is_empty():
		print("No runnable benchmark scripts found under %s" % SCAN_ROOT)
		return

	print("Found %d benchmark script(s):" % scripts.size())
	for path: String in scripts:
		print("  - %s" % path)
	print("")

	var results: Array[BenchResult] = []
	for path: String in scripts:
		var result: BenchResult = _run_benchmark(path)
		results.append(result)
	
	_print_report(results)


func _discover_bench_scripts(root: String) -> Array[String]:
	var found: Array[String] = []
	var stack: Array[String] = [root]

	while not stack.is_empty():
		var dir_path: String = stack.pop_back()
		var dir: DirAccess = DirAccess.open(dir_path)
		if dir == null:
			continue

		dir.list_dir_begin()
		var entry: String = dir.get_next()
		while entry != "":
			if entry == "." or entry == "..":
				entry = dir.get_next()
				continue

			var full_path: String = dir_path.path_join(entry)

			if dir.current_is_dir():
				if not SKIP_DIRS.has(entry):
					stack.append(full_path)
			elif entry.ends_with(".gd") and entry.to_lower().begins_with("bench"):
				found.append(full_path)

			entry = dir.get_next()
		dir.list_dir_end()

	found.sort()
	return found


func _run_benchmark(path: String) -> BenchResult:
	var script: GDScript = load(path)
	var times_ms: Array[float] = []
	var last_return: Variant = null

	for i: int in range(RUNS):
		var inst: Node = script.new()
		add_child(inst)

		var t0: int = Time.get_ticks_usec()
		last_return = inst.run()
		var t1: int = Time.get_ticks_usec()

		var elapsed_ms: float = float(t1 - t0) / 1000.0
		times_ms.append(elapsed_ms)

		inst.queue_free()
		remove_child(inst)

	var min_ms: float = times_ms[0]
	var max_ms: float = times_ms[0]
	var sum_ms: float = 0.0
	for t: float in times_ms:
		min_ms = minf(min_ms, t)
		max_ms = maxf(max_ms, t)
		sum_ms += t
	var avg_ms: float = sum_ms / float(times_ms.size())

	return BenchResult.new(
		path,
		path.get_file(),
		times_ms,
		min_ms,
		max_ms,
		avg_ms,
		last_return
	)


func _print_report(results: Array[BenchResult]) -> void:
	print("")
	print("~~~~~~~~ le epic bench (%d runs) ~~~~~~" % RUNS)
	print("%-32s %10s %10s %10s" % ["script", "min (ms)", "max (ms)", "avg (ms)"])
	print("-".repeat(76))

	var sorted_results: Array[BenchResult] = results.duplicate()
	sorted_results.sort_custom(
		func(a: BenchResult, b: BenchResult) -> bool: return a.avg_ms < b.avg_ms
	)

	for r: BenchResult in sorted_results:
		print("%-32s %10.3f %10.3f %10.3f" % [r.name, r.min_ms, r.max_ms, r.avg_ms])

	print("~".repeat(76))
