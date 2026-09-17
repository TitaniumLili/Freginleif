extends Node
# none of this is able to be inlined (non monomorphic) and thus
# serves as a control group

const ITERS := 10_000_000

func _small(a: int, b: int) -> int:
	return a + b * 2 - 1

class Base:
	func compute(a: int, b: int) -> int:
		return a + b

class Derived extends Base:
	func compute(a: int, b: int) -> int:
		return a + b * 2 - 1

func run() -> int:
	var obj: Base = Derived.new()
	var acc := 0
	for i in range(ITERS):
		acc = obj.compute(acc, i)
	return acc
