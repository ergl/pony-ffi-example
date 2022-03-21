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

use @list_create[Pointer[_List]]()
use @list_free[None](list: Pointer[_List])

use @list_push[None](list: Pointer[_List], data: Pointer[None])
use @list_pop[Pointer[None]](list: Pointer[_List])

primitive _List

struct Point
  var x: U64 = 0
  var y: U64 = 0

  new create(x': U64, y': U64) =>
    x = x'
    y = y'

  fun string(): String iso^ =>
    "(" + x.string() + "," + y.string() + ")"

actor Main
  new create(env: Env) =>
    let bucket_size: U32 = 1000000
    var random = MT

    for i in Range[U64](1, 20) do
      let r: U64 = random.next()
      let hash = @jch_chash(i, bucket_size)
      env.out.print(i.string() + ": " + hash.string())
    end

    try_errors(env)
    generic_list(env)

  fun tag try_errors(env: Env) =>
    if not @dummy_try(USize(0)) then
      env.out.print("Internal callback was raised and caught inside C")
    end
    try
      @dummy_raise_error(USize(0)) ?
    else
      env.err.print("Raised an error!")
    end

  fun tag generic_list(env: Env) =>
    let list = @list_create()
    let points = [as Point ref:
      Point(0, 0)
      Point(1,1)
      Point(2,2)
      Point(3,3)
    ]

    for p in points.values() do
      @list_push(list, NullablePointer[Point].create(p))
    end

    try
      var node = @list_pop[NullablePointer[Point]](list)
      while not node.is_none() do
        env.out.print(node()?.string())
        node = @list_pop[NullablePointer[Point]](list)
      end
    else
      @list_free(list)
    end
