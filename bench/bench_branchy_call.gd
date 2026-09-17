extends Node
# small fn wiht branches and multiple returns

const ITERS = 10_000_000

func _classify(x: int) -> int:
	if x % 15 == 0:
		return 0
	elif x % 3 == 0:
		return 1
	elif x % 5 == 0:
		return 2
	return 3

func run() -> int:
	var acc := 0
	for i in range(ITERS):
		acc += _classify(i)
	return acc
