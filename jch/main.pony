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

  fun tag try_errors(env: Env) =>
    if not @dummy_try(USize(0)) then
      env.out.print("Internal callback was raised and caught inside C")
    end
    try
      @dummy_raise_error(USize(0)) ?
    else
      env.err.print("Raised an error!")
    end
