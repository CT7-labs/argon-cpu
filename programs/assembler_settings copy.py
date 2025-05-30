# Constants
class Token:
    def __init__(self, token, value):
        self.token = token # directive, opcode, etc.
        self.value = value # register, immediate, etc.
    def __repr__(self):
        return f"({self.token}: {self.value})"

expression_operators = "( ) + - * / % << >> & | ^ ~ < > == !=".split()

# Look-up tables

# thanks to Grok for dictionary
registers = {
    "r0": 0,      # Read-only zero
    "r1": 1,      # a0: Function argument 0 (caller)
    "a0": 1,      # Alias for r1
    "r2": 2,      # a1: Function argument 1 (caller)
    "a1": 2,      # Alias for r2
    "r3": 3,      # a2: Function argument 2 (caller)
    "a2": 3,      # Alias for r3
    "r4": 4,      # a3: Function argument 3 (caller)
    "a3": 4,      # Alias for r4
    "r5": 5,      # v0: Return value 0 (callee)
    "v0": 5,      # Alias for r5
    "r6": 6,      # v1: Return value 1 (callee)
    "v1": 6,      # Alias for r6
    "r7": 7,      # s0: General purpose saved register 0 (caller)
    "s0": 7,      # Alias for r7
    "r8": 8,      # s1: General purpose saved register 1 (caller)
    "s1": 8,      # Alias for r8
    "r9": 9,      # s2: General purpose saved register 2 (caller)
    "s2": 9,      # Alias for r9
    "r10": 10,    # s3: General purpose saved register 3 (caller)
    "s3": 10,     # Alias for r10
    "r11": 11,    # s4: General purpose saved register 4 (caller)
    "s4": 11,     # Alias for r11
    "r12": 12,    # s5: General purpose saved register 5 (caller)
    "s5": 12,     # Alias for r12
    "r13": 13,    # s6: General purpose saved register 6 (caller)
    "s6": 13,     # Alias for r13
    "r14": 14,    # s7: General purpose saved register 7 (caller)
    "s7": 14,     # Alias for r14
    "r15": 15,    # t0: General purpose temporary register 0 (callee)
    "t0": 15,     # Alias for r15
    "r16": 16,    # t1: General purpose temporary register 1 (callee)
    "t1": 16,     # Alias for r16
    "r17": 17,    # t2: General purpose temporary register 2 (callee)
    "t2": 17,     # Alias for r17
    "r18": 18,    # t3: General purpose temporary register 3 (callee)
    "t3": 18,     # Alias for r18
    "r19": 19,    # t4: General purpose temporary register 4 (callee)
    "t4": 19,     # Alias for r19
    "r20": 20,    # t5: General purpose temporary register 5 (callee)
    "t5": 20,     # Alias for r20
    "r21": 21,    # t6: General purpose temporary register 6 (callee)
    "t6": 21,     # Alias for r21
    "r22": 22,    # t7: General purpose temporary register 7 (callee)
    "t7": 22,     # Alias for r22
    "r23": 23,    # gp: Global pointer
    "gp": 23,     # Alias for r23
    "r24": 24,    # sp: Stack pointer
    "sp": 24,     # Alias for r24
    "r25": 25,    # st: Status register
    "st": 25,     # Alias for r25
    "r26": 26,    # is: Interrupt status
    "is": 26,     # Alias for r26
    "r27": 27,    # ra: Return address
    "ra": 27,     # Alias for r27
    "r28": 28,    # porta: I/O register for port A
    "porta": 28,  # Alias for r28
    "r29": 29,    # ddira: Direction control for port A
    "ddira": 29,  # Alias for r29
    "r30": 30,    # portb: I/O register for port B
    "portb": 30,  # Alias for r30
    "r31": 31,    # ddirb: Direction control for port B
    "ddirb": 31   # Alias for r31
}

mnemonics = {
    # ALU arithmetic
    "add":  ["REGISTER", "REGISTER", "REGISTER"],   # ADD rd, rs, rt
    "sub":  ["REGISTER", "REGISTER", "REGISTER"],   # SUB rd, rs, rt
    "addi": ["REGISTER", "REGISTER", "IMM16"],      # ADDI rd, rs, imm16
    "subi": ["REGISTER", "REGISTER", "IMM16"],      # SUBI rd, rs, imm16

    # ALU logical
    "and":  ["REGISTER", "REGISTER", "REGISTER"],   # AND rd, rs, rt
    "or":   ["REGISTER", "REGISTER", "REGISTER"],   # OR rd, rs, rt
    "nor":  ["REGISTER", "REGISTER", "REGISTER"],   # NOR rd, rs, rt
    "xor":  ["REGISTER", "REGISTER", "REGISTER"],   # XOR rd, rs, rt
    "andi": ["REGISTER", "REGISTER", "IMM16"],      # ANDI rd, rs, imm16
    "ori":  ["REGISTER", "REGISTER", "IMM16"],      # ORI rd, rs, imm16
    "nori": ["REGISTER", "REGISTER", "IMM16"],      # NORI rd, rs, imm16
    "xori": ["REGISTER", "REGISTER", "IMM16"],      # XORI rd, rs, imm16

    # ALU bit operations
    "setb": ["REGISTER", "SHAMT"],                  # SETB rd, shamt
    "clrb": ["REGISTER", "SHAMT"],                  # CLRB rd, shamt

    # ALU shifting
    "sll":  ["REGISTER", "REGISTER", "REGISTER"],   # SLL rd, rs, rt
    "slli": ["REGISTER", "REGISTER", "SHAMT"],      # SLLI rd, rs, shamt
    "srl":  ["REGISTER", "REGISTER", "REGISTER"],   # SRL rd, rs, rt
    "srli": ["REGISTER", "REGISTER", "SHAMT"],      # SRLI rd, rs, shamt
    "sra":  ["REGISTER", "REGISTER", "REGISTER"],   # SRA rd, rs, rt
    "srai": ["REGISTER", "REGISTER", "SHAMT"],      # SRAI rd, rs, shamt

    # Branching / jumping
    "beq":  ["REGISTER", "REGISTER", "IMM16"],      # BEQ rs, rt, offset16
    "bne":  ["REGISTER", "REGISTER", "IMM16"],      # BNE rs, rt, offset16
    "slt":  ["REGISTER", "REGISTER", "REGISTER"],   # SLT rd, rs, rt
    "sltu": ["REGISTER", "REGISTER", "REGISTER"],   # SLTU rd, rs, rt
    "jmp":  ["IMM26"],                              # JMP jtarg26
    "jmpr": ["REGISTER"],                           # JMPR rs
    "jal":  ["IMM26"],                              # JAL jtarg26
    "jalr": ["REGISTER", "REGISTER"],               # JALR rd, rs

    # Memory operations
    "lui":  ["REGISTER", "IMM16"],                  # LUI rd, imm16
    "lw":   ["REGISTER", "REGISTER", "IMM16"],      # LW rd, rs, offset16
    "lh":   ["REGISTER", "REGISTER", "IMM16"],      # LH rd, rs, offset16
    "lb":   ["REGISTER", "REGISTER", "IMM16"],      # LB rd, rs, offset16
    "sw":   ["REGISTER", "REGISTER", "IMM16"],      # SW rs, rt, offset16
    "sh":   ["REGISTER", "REGISTER", "IMM16"],      # SH rs, rt, offset16
    "sb":   ["REGISTER", "REGISTER", "IMM16"]       # SB rs, rt, offset16
}

directives = "define macro endmacro".split() # unfinished