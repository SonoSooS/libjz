#pragma once

#include <stdint.h>
#include <stdbool.h>

#ifdef _MSC_VER
#define MRC(rD,pc,op1,r1,r2,op2) rD = _MoveFromCoprocessor(pc, op1, r1, r2, op2)
#define MCR(rD,pc,op1,r1,r2,op2) _MoveToCoprocessor(rD, pc, op1, r1, r2, op2)
#else
#define MRC(rD,pc,op1,r1,r2,op2) asm volatile("MRC p" #pc ", " #op1 ", %0, c" #r1 ", c" #r2 ", " #op2 "\n\t" : "=r"(rD))
#define MCR(rD,pc,op1,r1,r2,op2) asm volatile("MCR p" #pc ", " #op1 ", %0, c" #r1 ", c" #r2 ", " #op2 "\n\t" :: "r"(rD))
#endif


typedef int8_t jzByte;
typedef uint16_t jzChar;
typedef int16_t jzShort;
typedef int32_t jzInt;
typedef int64_t jzLong;

typedef uint8_t jzBytecode;

typedef struct jz_vectordata
{
    void* Handler[256];  // naked noreturn callback
    void* ErrHandler[8]; // ???
} jzVector;

typedef struct jz_state
{
    jzInt StackIn[4]; // r0 - r3
    jzInt Local0;     // r4
    jzInt VectorData; // r5
    jzInt* StackTop;  // r6
    jzInt* LocalPool; // r7
    const jzBytecode* ExceptionAddr; // Address of exception
} jzState;


typedef jzBytecode const*(*jzUserHandlerCb)(jzState* state, const jzBytecode* JPC, void* userdata, jzInt cbData);
typedef jzInt(*jzEnterPfn)(jzState* state, const jzBytecode* JPC, jzUserHandlerCb callback, void* userdata);


void jzkHwEnable(bool enable, bool userland);


