"""
No macro support just yet, we'll add that later

=== General Token Types: ===
REGISTER    :   self-explanatory
IMMEDIATE   :   an immediate value
SYMBOL      :   symbol that needs to be replaced from the symbol table
OPERATOR    :   mathematical operators like ~, +, and ()
OPCODE      :   instruction opcode
DIRECTIVE   :   assembler directive

=== Organization Token Types: ===
SEP         :   represents a comma between operands (i.e., ADD t0, t1, t2)
ENDL        :   endline
STARTEX     :   Start of an expression
ENDEX       :   End of an expression

"""

# token constants
REGISTER    = "register"
IMMEDIATE   = "IMMEDIATE"
SYMBOL      = "SYMBOL"
OPERATOR    = "OPERATOR"
MNEMONIC    = "MNEMONIC"
DIRECTIVE   = "DIRECTIVE"
LABEL       = "LABEL"
ENDL        = "$ENDL"

class Block:
    def __init__(self, value, line):
        self.value = value
        self.line = line
    def __repr__(self):
        return f"({self.value} @ {self.line})"

class Token:
    def __init__(self, token=None, value=None, line=None, size=None):
        self.token = token # directive, mnemonic, etc.
        self.value = value # register, immediate, etc.
        self.line = line # line number
        self.size = size # size in bytes
    def __repr__(self):
        out = ""
        if self.token[0:1] != "$":
            out += f"{self.token}: {self.value}"
        else:
            out += f"{self.token}"
        
        if self.line:
            out += f" @ {self.line}"
        
        return f"({out})"
    
    def __eq__(self, x):
        return self.token == x

expression_operators = "( ) + - * / % << >> & | ^ ~ < > == !=".split()

# Look-up tables

# thanks to Grok for dictionary
registers = {
    "r0": 0,        # Read-only zero
    "zero": 0,      # Alias for r0
    "z":  0,        # Alias r0
    "r1": 1,        # a0: Function argument 0 (caller)
    "a0": 1,        # Alias for r1
    "r2": 2,        # a1: Function argument 1 (caller)
    "a1": 2,        # Alias for r2
    "r3": 3,        # a2: Function argument 2 (caller)
    "a2": 3,        # Alias for r3
    "r4": 4,        # a3: Function argument 3 (caller)
    "a3": 4,        # Alias for r4
    "r5": 5,        # v0: Return value 0 (callee)
    "v0": 5,        # Alias for r5
    "r6": 6,        # v1: Return value 1 (callee)
    "v1": 6,        # Alias for r6
    "r7": 7,        # s0: General purpose saved register 0 (caller)
    "s0": 7,        # Alias for r7
    "r8": 8,        # s1: General purpose saved register 1 (caller)
    "s1": 8,        # Alias for r8
    "r9": 9,        # s2: General purpose saved register 2 (caller)
    "s2": 9,        # Alias for r9
    "r10": 10,      # s3: General purpose saved register 3 (caller)
    "s3": 10,       # Alias for r10
    "r11": 11,      # s4: General purpose saved register 4 (caller)
    "s4": 11,       # Alias for r11
    "r12": 12,      # s5: General purpose saved register 5 (caller)
    "s5": 12,       # Alias for r12
    "r13": 13,      # s6: General purpose saved register 6 (caller)
    "s6": 13,       # Alias for r13
    "r14": 14,      # s7: General purpose saved register 7 (caller)
    "s7": 14,       # Alias for r14
    "r15": 15,      # t0: General purpose temporary register 0 (callee)
    "t0": 15,       # Alias for r15
    "r16": 16,      # t1: General purpose temporary register 1 (callee)
    "t1": 16,       # Alias for r16
    "r17": 17,      # t2: General purpose temporary register 2 (callee)
    "t2": 17,       # Alias for r17
    "r18": 18,      # t3: General purpose temporary register 3 (callee)
    "t3": 18,       # Alias for r18
    "r19": 19,      # t4: General purpose temporary register 4 (callee)
    "t4": 19,       # Alias for r19
    "r20": 20,      # t5: General purpose temporary register 5 (callee)
    "t5": 20,       # Alias for r20
    "r21": 21,      # t6: General purpose temporary register 6 (callee)
    "t6": 21,       # Alias for r21
    "r22": 22,      # t7: General purpose temporary register 7 (callee)
    "t7": 22,       # Alias for r22
    "r23": 23,      # gp: Global pointer
    "gp": 23,       # Alias for r23
    "r24": 24,      # sp: Stack pointer
    "sp": 24,       # Alias for r24
    "r25": 25,      # st: Status register
    "st": 25,       # Alias for r25
    "r26": 26,      # is: Interrupt status
    "is": 26,       # Alias for r26
    "r27": 27,      # ra: Return address
    "ra": 27,       # Alias for r27
    "r28": 28,      # porta: I/O register for port A
    "porta": 28,    # Alias for r28
    "r29": 29,      # ddira: Direction control for port A
    "ddira": 29,    # Alias for r29
    "r30": 30,      # portb: I/O register for port B
    "portb": 30,    # Alias for r30
    "r31": 31,      # ddirb: Direction control for port B
    "ddirb": 31     # Alias for r31
}

# 0-N -> mnemonic has 0-N arguments
# -1  -> mnemonic has variable arguments
mnemonics = {
    # ================ [ OPCODES ] ================
    # ALU arithmetic
    "add": 3,   # ADD rd, rs, rt
    "sub": 3,   # SUB rd, rs, rt
    "addi": 3,  # ADDI rd, rs, imm16
    "subi": 3,  # SUBI rd, rs, imm16

    # ALU logical
    "and": 3,   # AND rd, rs, rt
    "or": 3,    # OR rd, rs, rt
    "nor": 3,   # NOR rd, rs, rt
    "xor": 3,   # XOR rd, rs, rt
    "andi": 3,  # ANDI rd, rs, imm16
    "ori": 3,   # ORI rd, rs, imm16
    "nori": 3,  # NORI rd, rs, imm16
    "xori": 3,  # XORI rd, rs, imm16

    # ALU bit operations
    "setb": 2,  # SETB rd, shamt
    "clrb": 2,  # CLRB rd, shamt

    # ALU shifting
    "sll": 3,   # SLL rd, rs, rt
    "slli": 3,  # SLLI rd, rs, shamt
    "srl": 3,   # SRL rd, rs, rt
    "srli": 3,  # SRLI rd, rs, shamt
    "sra": 3,   # SRA rd, rs, rt
    "srai": 3,  # SRAI rd, rs, shamt

    # Branching / jumping
    "beq": 3,   # BEQ rs, rt, offset16
    "bne": 3,   # BNE rs, rt, offset16
    "slt": 3,   # SLT rd, rs, rt
    "sltu": 3,  # SLTU rd, rs, rt
    "jmp": 1,   # JMP jtarg26
    "jmpr": 1,  # JMPR rs
    "jal": 1,   # JAL jtarg26
    "jalr": 2,  # JALR rd, rs

    # Memory operations
    "lui": 2,   # LUI rd, imm16
    "lw": 3,    # LW rd, rs, offset16
    "lh": 3,    # LH rd, rs, offset16
    "lb": 3,    # LB rd, rs, offset16
    "sw": 3,    # SW rs, rt, offset16
    "sh": 3,    # SH rs, rt, offset16
    "sb": 3,    # SB rs, rt, offset16

    # ================ [ DIRECTIVES ] ================
    ".define": 2,
    ".macro": -1,
    ".endmacro": 0,
    ".section": 1
}

sections = [
    "CODE", # code
    "DATA"  # initialized data
]

std_procedures = [
    ".main"
]

rtype_mnemonics = [
    "add",
    "sub",
    "and",
    "or",
    "nor",
    "xor",
    "setb",
    "clrb",
    "setbi",
    "clrbi",
    "sll",
    "srl",
    "sra",
    "sllv",
    "srlv",
    "srav",
    "slt",
    "sltu",
    "jmpr",
    "jalr"
]

itype_mnemonics = [
    "addi",
    "subi",
    "andi",
    "ori",
    "nori",
    "xori",
    "beq",
    "bne",
    "lui",
    "lw",
    "lh",
    "lb",
    "sw",
    "sh",
    "sb"
]

jtype_mnemonics = [
    "jmp",
    "jal"
]