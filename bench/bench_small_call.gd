extends Node
# tight loop in a small call

const ITERS = 20_000_000

func _small(a: int, b: int) -> int:
	return a + b * 2 - 1

func run() -> int:
	var acc := 0
	for i in range(ITERS):
		acc = _small(acc, i)
	return acc
