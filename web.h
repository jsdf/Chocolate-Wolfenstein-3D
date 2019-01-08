
#ifndef WEB_H 
#define WEB_H

typedef void (*continuation_ptr_t)( int );

void em_continuation_push(continuation_ptr_t returnto);
void em_continuation_return();

#endif