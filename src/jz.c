#include "jz.h"



void jzkHwEnable(bool enable, bool userland)
{
    uint32_t reg;
    
    MRC(reg, 14, 7, 1, 0, 0);
    if(userland)
        reg |= 2;
    else
        reg &= ~2;
    MCR(reg, 14, 7, 1, 0, 0);
    
    MRC(reg, 14, 7, 2, 0, 0);
    if(enable)
        reg |= 1;
    else
        reg &= ~1;
    MCR(reg, 14, 7, 2, 0, 0);
}
