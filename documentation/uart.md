# UART Controller v0
Argon does, in fact, have a master! The UART Controller (need a name for it).

The UART controller can:
- Read/write to registers or cache, for simple tests or program loading
- Monitor state flags and report back to my laptop
- other things
- what else should this be able to do

# Features
- Fixed baud rate of 1 MBaud

# UART Protocol
- Odd parity
- 16-bit words (as many as agreed upon)
- 2 stop bits

# Control Protocol
Master (laptop) -> Slave (UART Controller)
1. Send 32-bit command (e.g., expect 32 words and put them at X in cache)
2. Payload (variable length)
3. Stop bits

Slave -> Master
1. Send 16-bit command (e.g., expect 1 word and treat it like so)
2. Payload (variable length)
3. Stop bits