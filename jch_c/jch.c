#include <stdint.h>
#include <limits.h>
#include "math.h"
#include "pony.h"

// A reasonably fast, good period, low memory use, xorshift64* based prng
double lcg_next(uint64_t* x)
{
  *x ^= *x >> 12;
  *x ^= *x << 25;
  *x ^= *x >> 27;
  return (double)(*x * 2685821657736338717LL) / ULONG_MAX;
}

// Jump consistent hash
int32_t jch_chash(uint64_t key, uint32_t num_buckets)
{
  uint64_t seed = key;
  int b = -1;
  uint32_t j = 0;

  do {
    b = j;
    double r = lcg_next(&seed);
    j = floor((b + 1)/r);
  } while(j < num_buckets);

  return (int32_t)b;
}

void dummy_raise_error(void* arg)
{
  (void) arg;
  pony_error();
}

bool dummy_try(void* data)
{
  return pony_try(&dummy_raise_error, data);
}
