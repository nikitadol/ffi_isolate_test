#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct MyStruct {
  uintptr_t index;
  intptr_t isolate_hash;
} MyStruct;

const struct MyStruct *create_my(uintptr_t index, intptr_t isolate_hash);

/**
 * # Safety
 * - `ptr` should be from [`create`]
 */
void free_my(const struct MyStruct *ptr);

/**
 * # Safety
 */
bool init_my(void *data);

/**
 * # Safety
 */
void set_finalizable(Dart_Handle capability,
                     void *ptr,
                     intptr_t external_allocation_size,
                     void (*callback)(void *ptr));
