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

actor Main
  var _env: Env

  new create(env: Env) =>
    _env = env

    let bucket_size: U32 = 1000000
    var random = MT

    for i in Range[U64](1, 20) do
      let r: U64 = random.next()
      let hash = @jch_chash(i, bucket_size)
      _env.out.print(i.string() + ": " + hash.string())
    end
