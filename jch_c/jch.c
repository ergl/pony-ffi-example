#include <stdlib.h>
#include <assert.h>
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

struct Node {
  void* data;
  struct Node* next;
};

struct List {
  struct Node* head;
};

struct List* list_create() {
  struct List* l = malloc(sizeof(struct List));
  l->head = NULL;
  return l;
}

void list_free(struct List* list) {
  assert(list != NULL);

  if (list->head != NULL) {
    struct Node* node = list->head;
    while(node->next != NULL) {
      struct Node* old = node;
      node = node->next;
      free(old);
    }
  }

  free(list);
}

void list_push(struct List* list, void* data) {
  assert(list != NULL);

  struct Node* node = malloc(sizeof(struct Node));
  node->data = data;
  node->next = NULL;

  struct Node* cur = list->head;
  if (cur == NULL) {
    node->next = cur;
    list->head = node;
  } else {
    while (cur->next != NULL) {
      cur = cur->next;
    }

    cur->next = node;
  }
}

void* list_pop(struct List* list) {
  assert(list != NULL);

  struct Node* cur = list->head;
  if (cur == NULL) {
    return NULL;
  }

  list->head = cur->next;
  void* data = cur->data;
  free(cur);
  return data;
}
