extends Node
# tries to inline nested calls, so a fn is flattened completely if it is able to be

const ITERS := 10_000_000

func _inner(x: int) -> int:
	return x * x + 1

func _outer(x: int) -> int:
	var a := _inner(x)
	var b := _inner(x + 1)
	return a - b

func run() -> int:
	var acc := 0
	for i in range(ITERS):
		acc += _outer(i)
	return acc
