#ifndef _STDINT_H
#define _STDINT_H

/* Exact-width integer types */

#ifndef __int8_t_defined
#define __int8_t_defined
typedef signed char int8_t;
typedef short int16_t;
//typedef long int32_t;
typedef long long int64_t;
#endif

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
#ifndef __uint32_t_defined
#define __uint32_t_defined
typedef unsigned long uint32_t_enttec;
#endif
typedef unsigned long long uint64_t;

#endif /* _STDINT_H */