# libjz

Based on the minimal amount of publically available information, and an unmeasurable amount of bruteforcing and observation, finally there is a driver and documentation on how to unlock and use the Jazelle core included (and most likely hidden) in some ARM CPU cores.

You can also reimplement this driver yourself based on the information documented in the [wiki tab](./wiki).

## CPU compatibility

While all CPUs with `J` in their name should have Jazelle in them (like `ARM926EJ-S` or `ARMv5TEJ`), in some cases it's not so obvious (for example some if not all `ARM11 MPCore` (`ARMv6K`) CPUs should have it).

The best bet is to run the below instructions in kernel mode to see if the Jazelle core exists or not. You know there is a Jazelle core if you don't get any CPU exception, and you get a value with some high and some low bits set with middle bits being mostly if not all zero (in `r0` in this example).
>     MOV r0, #2
>     MCR p14, 7, r0, c1, c0, 0
>     MRC p14, 7, r0, c0, c0, 0
On my ARM11 MPCore I get `0x74100064`.

A rule of thumb is that ARM7TDMI (ARMv4 ?) is too old to hava Jazelle, while ARMv7 CPUs are highly unlikely to have it due to being too new.

Here are a few CPUs which are known to have Jazelle in them:
- `ARM7EJ-S` (`ARMv5TEJ`)
- `ARM926EJ-S` (`ARMv5TEJ`)
- `ARM11MPCore` (`ARMv6K`)

Currently only the Jazelle core found in `ARM11MPCore` (`0x74100064`) is supported. Please open an issue if you need support for a different Jazelle identifier.

## Kernel compatibility

Currently libjz has only been developed and tested on a Nintendo 3DS running in usermode under Nintendo's Horizon kernel with kernel code execution support.

Any kernel should work if it can unlock Jazelle for you, or if you can enter kernel mode to unlock it yourself with a `jzk*` prefix function.

> Please note that functions starting with `jzk*` can only be executed in kernel mode, and will cause undefined instruction when attempted to be executed in usermode.

# License

See `LICENSE.txt`. You may use this driver in personal projects freely.

If you want to distribute your project with this driver, please include a link to my github user page in your program where it's easily user-accessible (like in your program's about section, or in the copyright printout in a console application).
