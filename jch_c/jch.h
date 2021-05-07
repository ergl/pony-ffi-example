#ifndef __JCH_H_
#define __JCH_H_

extern "C"
{
  int32_t jch_chash(uint64_t key, uint32_t num_buckets);
  bool dummy_try(void* data);
  void dummy_raise_error(void* data);
}

#endif
