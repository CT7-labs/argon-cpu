# Register File
Argon has 16 registers, 15 read/write and 1 hard-wired zero register.

This doesn't seem like enough registers for most things, but as mentioned in the README, Argon isn't meant for high performance computing.

### Register mnemonics
| Reg | Name | Role | Convention | Notes |
|-----|------|------|------------|-------|
| r0  | zero | Hardwired 0 | Always 0 | No writes |
| r1  | ra   | Return Address | Caller-saved | For `JAL`, `RET` |
| r2  | rv   | Return Value | Caller-saved | Function results |
| r3–r6 | a0–a3 | Arguments | Caller-saved | Function inputs |
| r7–r10 | s0–s3 | Saved | Callee-saved | Local variables |
| r11–r14 | t0–t3 | Temporaries | Caller-saved | Scratch space |
| r15 | sp   | Stack Pointer | Callee-saved | Stack management |
