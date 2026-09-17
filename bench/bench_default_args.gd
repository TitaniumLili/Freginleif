extends Node
# remaining parameters fall back to default value expression

const ITERS := 10_000_000

func _scale(x: int, factor: int = 3) -> int:
	return x * factor

func run() -> int:
	var acc := 0
	for i in range(ITERS):
		acc += _scale(i)          #uses default
		acc += _scale(i, 2)       #explicit arg
	return acc
