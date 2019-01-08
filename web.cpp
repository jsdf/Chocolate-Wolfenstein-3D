
#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#endif
#include <assert.h>
#include "web.h"


continuation_ptr_t em_continuation_stack[100];
int em_continuation_stack_top = 0;

void em_continuation_push(continuation_ptr_t returnto) {
  #ifdef __EMSCRIPTEN__
  assert(returnto != NULL);
  em_continuation_stack[em_continuation_stack_top] = returnto;
  em_continuation_stack_top++;
  #endif
}

void em_continuation_return() {
  #ifdef __EMSCRIPTEN__
  continuation_ptr_t returnto = em_continuation_stack[em_continuation_stack_top];
  assert(em_continuation_stack_top>0);
  assert(returnto != NULL);
  em_continuation_stack_top--;

  emscripten_async_call((void (*)(void *))returnto, 0, -1);
  #endif
}
