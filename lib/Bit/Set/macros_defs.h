#include "EXTERN.h"
#include "XSUB.h"
#include "bit.h"
#include "perl.h"
#include "perlapi.h"

/******************************************************************************
 *                                   CONSTANTS
 ******************************************************************************/
#define STACK_MAX 65536 // maximum size array to allocate at the stack

#define UNDEF_ERROR "Bitset cannot be undef"

#define UNDEF_DB_ERROR "Bit_DB cannot be undef"

#define UNDEF_NON_REF_ARRAY_ERROR                                              \
  "indices should be a defined reference to an array"

/******************************************************************************
 *                                   MACROS
 ******************************************************************************/
#define SV_TO_TYPE(type, sv, msg)                                              \
  (!SvOK(sv) ? (croak(msg), (type)0)                                           \
             : INT2PTR(type, SvIV(SvROK(sv) ? SvRV(sv) : (sv))))

#define SV_TO_VOID(sv)                                                         \
  (!SvOK(sv) || !SvIOK(sv) || !looks_like_number(sv)                           \
       ? NULL                                                                  \
       : INT2PTR(void *, SvIV(sv)))

#define ALLOC_ARRAY_IN_STACK_OR_HEAP(name, type, n)                            \
  type name##_stack[STACK_MAX];                                                \
  type *name =                                                                 \
      ((n) <= STACK_MAX) ? name##_stack : (type *)Newx(name, (n), type);

#define FREE_ARRAY_IN_STACK_OR_HEAP(name)                                      \
  do {                                                                         \
    if ((name) != (name##_stack)) {                                            \
      Safefree(name);                                                          \
    }                                                                          \
  } while (0);

#define FILL_INT_ARRAY_FROM_AV(av, dst, n)                                     \
  do {                                                                         \
    for (int __i = 0; __i < (n); ++__i) {                                      \
      SV **__svp = av_fetch((av), __i, 0);                                     \
      (dst)[__i] = (int)SvIV(*__svp);                                          \
    }                                                                          \
  } while (0)

#define RETURN_BLESSED_REFERENCE(classname, obj)                               \
  do {                                                                         \
    ST(0) = sv_newmortal();                                                    \
    sv_setiv(newSVrv(ST(0), (classname)), PTR2IV((obj)));                      \
  } while (0);

#define RETURN_INTEGER_SCALAR(integerobject)                                   \
  do {                                                                         \
    ST(0) = sv_newmortal();                                                    \
    sv_setiv(ST(0), integerobject);                                            \
  } while (0);


/******************************************************************************
 *                                   TYPEDEFS
 ******************************************************************************/

typedef SV *INTEGER_ARRAY_REF;
typedef Bit_T Bit_T_obj;
typedef Bit_DB_T Bit_DB_T_obj;

// note SETOP_COUNT_OPTS typemap is defined in typemap file
