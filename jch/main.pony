"""
This is an example of Pony integrating with native code via the built-in FFI
support
"""

// We can remove this if we add `-p jch_c/` as a flag to `ponyc` in the makefile
use "path:../jch_c"
use "lib:jch"
use "collections"
use "random"
use @jch_chash[I32](hash: U64, bucket_size: U32)
use @dummy_raise_error[None](data: Pointer[None]) ?
use @dummy_try[Bool](data: Pointer[None])

use @list_create[Pointer[_List] tag]()
use @list_free[None](list: Pointer[_List] tag)

use @list_push[None](list: Pointer[_List] tag, data: Pointer[None])
use @list_pop[Pointer[None]](list: Pointer[_List] tag)

primitive _List

struct Point
  var x: U64 = 0
  var y: U64 = 0

  new create(x': U64, y': U64) =>
    x = x'
    y = y'

  fun string(): String iso^ =>
    "(" + x.string() + "," + y.string() + ")"

primitive JCH
  fun apply(key: U64, buckets: U32): I32 =>
    var k = key
    var b = I64(0)
    var j = I64(0)

    while j < buckets.i64() do
      b = j
      k = (k * 2862933555777941757) + 1
      j = ((b + 1).f64() * (I64(1 << 31).f64() / ((k >> 33) + 1).f64())).i64()
    end

    b.i32()

actor Main
  let _env: Env
  new create(env: Env) =>
    _env = env

    jch_example()
    try_example()
    list_example()

  be jch_example() =>
    let bucket_size: U32 = 1000000

    for i in Range[U64](1, 20) do
      let c_hash = @jch_chash(i, bucket_size)
      let pony_hash = JCH(i, bucket_size)
      _env.out.print(i.string() + ": " + c_hash.string() + " (C) " + pony_hash.string() + " (Pony)")
    end

  be try_example() =>
    if not @dummy_try(USize(0)) then
      _env.out.print("Internal callback was raised and caught inside C")
    end
    try
      @dummy_raise_error(USize(0)) ?
    else
      _env.err.print("Raised an error!")
    end

  be list_example() =>
    let list = @list_create()
    let elements = [as Point ref:
      Point(0, 0)
      Point(1,1)
      Point(2,2)
      Point(3,3)
    ]

    for elt in elements.values() do
      @list_push(list, NullablePointer[Point].create(elt))
    end

    try
      var node = @list_pop[NullablePointer[Point]](list)
      while not node.is_none() do
        _env.out.print(node()?.string())
        node = @list_pop[NullablePointer[Point]](list)
      end
    end

    @list_free(list)
