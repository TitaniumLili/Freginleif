extends Node
# loooop de loooooop

const ITERS := 2_000_000

func _sum_to(n: int) -> int:
	var total := 0
	for j in range(n):
		var doubled := j * 2
		total += doubled
	return total

func run() -> int:
	var acc := 0
	for i in range(ITERS):
		acc += _sum_to(5)
	return acc
