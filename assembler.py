"""
An extensible assembler for Argon, my custom CPU
"""
from pathlib import Path
import tomlkit
import sys

ASSEMBLER_VERSION = "0.1"
CONFIG_VERSION = "0.1"

# read target CONFIG
script_dir = Path(__file__).parent
config_path = script_dir / "argon06.toml"
with open(config_path, "r") as file:
    CONFIG = tomlkit.parse(file.read())
assert CONFIG["CONFIG_VERSION"] == CONFIG_VERSION

# Loc classs
class Loc:
    def __init__(self, ln=-1, col=-1):
        self.ln = ln
        self.col = col
    
    def endl(self):
        self.ln += 1
        self.col = 1
    
    def inc(self, x=1):
        self.col += x
    
    def __str__(self):
        if self.ln > 0 and self.col > 0:
            return f"{self.ln}, {self.col}"
        return ""
    
    def __bool__(self):
        return self.ln > 0 and self.col > 0

# Token class
class Token:
    def __init__(self, t, d=None, loc=Loc(-1,-1)):
        """Optionally-locatable Token for lexical shenanigans"""
        self.t = t
        self.d = d
        self.loc = loc
    
    def is_same_token(self, token):
        return self.t == token.t
    
    def is_same_value(self, token):
        return self.d == token.d
    
    def set_data(self, newdata):
        self.d = newdata
    
    def set_type(self, newt):
        self.t = newt
    
    def set_loc(self, newloc):
        self.loc = newloc
    
    def set_to(self, token):
        self.t = token.t
        self.d = token.d
        self.loc = token.loc
    
    def __repr__(self):
        out = f"({self.t} "
        if type(self.d) != None: out += f"{self.d}"
        if self.loc: out += f" @{self.loc}"
        out += ")"
        return out
    
    def __str__(self):
        return self.__repr__()

# Token types
DIRECTIVE   =   "<DIRECTIVE>"
OPCODE      =   "<OPCODE>"
MACRO       =   "<MACRO>"
IMM         =   "<IMM>"
REG         =   "<REG>"
EXPR        =   "<EXPR>"
ARG         =   "<ARG>"
SYM         =   "<SYMBOL>"
ENDL        =   "<ENDL>"
PROCEDURE   =   "<PROCEDURE>"

# tokenization yay!
def get_mnemonic_token(string, loc):
    string = string.lower() # for case-insensitive mnemonics

    if string in CONFIG["OPCODES"]:
        return Token(OPCODE, string, loc)
    elif string in CONFIG["DIRECTIVES"]:
        return Token(DIRECTIVE, string, loc)

    return Token(MNEMONIC, string, loc)

def is_immediate(string):
    if string[0:2] == "0x":
        return int(string[2:], 16)
    elif string.isdigit():
        return int(string)
    return False

def is_expression(string):
    return string[0] == "(" and string[-1] == ")"

def is_argument(string):
    return string[0] == "\\"

def is_register(string):
    string = string.lower()

    for i in range(32):
        if string in CONFIG["REGISTERS"][str(i)]:
            return i
    
    return False

def get_operand_token(string, loc):
    immediate = is_immediate(string)
    expression = is_expression(string)
    arguments = is_arguments(string)

def lines_to_blocks(lines):
    blocks = []
    for line in lines:
        blocks.extend([x for x in line.split(",") if x != ""])
        if blocks[-1] != ENDL: blocks.append(ENDL)
    
    newblocks = []
    blocks.insert(0, ENDL)
    lastblock = None
    for block in blocks:
        if lastblock == ENDL:
            newblocks.extend(block.strip().split())
        else:
            newblocks.append(block.strip())
        
        lastblock = block
    
    return newblocks[1:] # removes the <ENDL> at the start of the lsit

def tokenize_assembly(asm_string):
    # states
    lines = asm_string.split("\n")
    blocks = lines_to_blocks(lines)
    
    # remove comments
    cleanedblocks = []
    inComment = False
    for block in blocks:
        if block == "#":
            inComment = True
        
        if block == ENDL:
            inComment = False
        
        if not inComment:
            cleanedblocks.append(block)
    
    # remove duplicate ENDL blocks
    blocks = cleanedblocks.copy()
    cleanedblocks = []
    lastblock = None
    for block in blocks:
        if block != ENDL:
            cleanedblocks.append(block)
        elif lastblock != ENDL:
            cleanedblocks.append(block)
        
        lastblock = block
    
    blocks = cleanedblocks.copy()

    # convert blocks into lines for more intuitive manipulation
    lines = []
    scratch = []
    for block in blocks:
        if block != ENDL:
            scratch.append(block)
        else:
            lines.append(scratch)
            scratch = []
    
    # convert lines into tokens
    tokens = []
    for line in lines:
        op = None
        for block in line:
            if not op:
                op = block
                if op in CONFIG["OPCODES"]:
                    tokens.append(Token(OPCODE, op))
                elif op[0] == "." and op[1:] in CONFIG["DIRECTIVES"]:
                    tokens.append(Token(DIRECTIVE, op))
                else:
                    tokens.append(Token(MACRO, op)) # the macro might not be defined yet. we'll catch this later
            else:
                block_imm = is_immediate(block)
                block_reg = is_register(block)
                block_expr = is_expression(block)
                block_arg = is_argument(block)
                if block_imm:
                    tokens.append(Token(IMM, block_imm))
                elif type(block_reg) != bool:
                    tokens.append(Token(REG, block_reg))
                elif block_expr:
                    tokens.append(Token(EXPR, block_expr))
                elif block_arg:
                    tokens.append(Token(ARG, block))
                else:
                    if block[0] != ".":
                        tokens.append(Token(SYM, block)) # assume symbol
                    else:
                        tokens.append(Token(PROCEDURE, block)) # assume procedure label
        
        tokens.append(Token(ENDL))
    
    return tokens

# instruction class
class Instruction:
    def __init__(self, opcode, itype, operands=None, fields=None, loc=None):
        """
        opcode      - raw opcode
        itype       - R-, I-, or J-type instruction
        operands    - dictionary containing operand tokens
        fields      - dictionary containing fields like shamt or funct6
        loc         - index of instruction in the array of executable instructions
        """
        self.opcode = opcode
        self.itype = itype
        self.operands = {} if operands is None else operands
        self.fields = {} if fields is None else fields
        self.loc = -1 if loc is None else loc
    
    def __repr__(self):
        return f"({self.itype}:{self.opcode} {self.operands})"

# top-level functions

def tokens_to_lines(tokens):
    lines = []
    scratch = []
    for token in tokens:
        if token.t != ENDL:
            scratch.append(token)
        else:
            lines.append(scratch)
            scratch = []
    
    return lines

def lines_to_procedures(lines):
    current_subroutine = ""
    procedures = {}
    symbols = {}
    inst_index = 0

    for line in lines:
        op = line[0]
        mnemonic = op.d

        if mnemonic[0] == "." and mnemonic[1:] in CONFIG["DIRECTIVES"]:
            if mnemonic == ".equ":
                symbols[line[1].d] = line[2]
        
        elif mnemonic[0] == "." and mnemonic[-1] == ":":
            current_subroutine = mnemonic[:-1]
            procedures[current_subroutine] = []

        if mnemonic in CONFIG["OPCODES"]:
            for token in line:
                if token.t == SYM:
                    token.set_to(symbols[token.d])
            
            instconf = CONFIG["OPCODES"][mnemonic]
            inst = Instruction(instconf["opcode"], instconf["type"], loc=inst_index)

            if inst.itype == "R":
                inst.operands["rd"] = line[1].d
                inst.operands["rs"] = line[2].d
                inst.operands["funct6"] = instconf["funct6"]
                
                if instconf["shamt"]:
                    inst.operands["rt"] = 0
                    inst.operands["shamt"] = line[3].d
                else:
                    inst.operands["rt"] = line[3].d
                    inst.operands["shamt"] = 0
            
            elif inst.itype == "I":
                inst.operands["rd"] = line[1].d
                inst.operands["rs"] = line[2].d
                if inst.opcode != 8 and inst.opcode != 9:
                    inst.operands["imm16"] = line[3].d
                else:
                    inst.operands["target"] = line[3].d
            
            elif inst.itype == "J":
                inst.operands["target"] = line[1].d
            
            procedures[current_subroutine].append(inst)
            inst_index += 1
    
    # evaluate jump target addresses
    for proc in procedures:
        for inst in procedures[proc]:
            if inst.itype == "J" and inst.opcode == 17:
                target = inst.operands["target"]
                target_index = procedures[target][0].loc
                inst.operands["jtarg26"] = target_index
            
            if inst.itype == "I" and (inst.opcode == 8 or inst.opcode == 9):
                target = inst.operands["target"]
                target_index = procedures[target][0].loc
                current_index = inst.loc
                inst.operands["imm16"] = target_index - current_index
    
    return procedures

def get_rtype_bytes(op, rd, rs, rt, shamt, funct):
    result = ((op & 0b111111) |          # bits 5–0
              (rs & 0b11111) << 6 |      # bits 10–6
              (rd & 0b11111) << 11 |     # bits 15–11
              (rt & 0b11111) << 16 |     # bits 20–16
              (shamt & 0b11111) << 21 |  # bits 25–21
              (funct & 0b111111) << 26)  # bits 31–26
    result_bytes = result.to_bytes(4, byteorder="little")
    assert result < 2 ** 32
    return result_bytes

def get_itype_bytes(op, rd, rs, imm16):
    result = ((op & 0b111111) |
              (rs & 0b11111) << 6 |
              (rd & 0b11111) << 11 |
              (imm16 & 0xFFFF) << 16)
    assert result < 2 ** 32
    return result.to_bytes(4, byteorder="little")

def get_jtype_bytes(op, offset26):
    result = ((op & 0b111111) |
               (offset26 & 0x3ffffff) << 6)
    assert result < 2 ** 32
    return result.to_bytes(4, byteorder="little")

def procedures_to_bytecode(procedures, padto=4096):
    bytecode = bytearray()
    for proc in procedures:
        for inst in procedures[proc]:
            if inst.itype == "R":
                bytecode += get_rtype_bytes(
                    inst.opcode,
                    inst.operands["rd"],
                    inst.operands["rs"],
                    inst.operands["rt"],
                    inst.operands["shamt"],
                    inst.operands["funct6"],
                )
            elif inst.itype == "I":
                bytecode += get_itype_bytes(
                    inst.opcode,
                    inst.operands["rd"],
                    inst.operands["rs"],
                    inst.operands["imm16"]
                )
            elif inst.itype == "J":
                bytecode += get_jtype_bytes(
                    inst.opcode,
                    inst.operands["jtarg26"]
                )
            else:
                raise Exception("AAAA")
    
    if len(bytecode) < padto:
        bytecode += bytes(padto - len(bytecode))
    
    return bytecode

def assemble_file(filepath):
    with open(filepath, "r") as file:
        rawasm = file.read()
    tokens = tokenize_assembly(rawasm)
    lines = tokens_to_lines(tokens)
    procedures = lines_to_procedures(lines)
    bytecode = procedures_to_bytecode(procedures)
    return bytecode

def write_hex_to(filepath, bytecode):
    with open(filepath, "w") as file:
        # Process bytes in groups of 4
        for i in range(0, len(bytecode), 4):
            # Take up to 4 bytes starting at index i
            chunk = bytecode[i:i+4]
            # Convert to 32-bit integer (big-endian)
            value = 0
            for j, b in enumerate(chunk):
                value |= (b & 0xFF) << (8 * (3 - j))
            # Write as 8-digit hex (zero-padded, lowercase)
            file.write(f"{value:08x}\n")

if __name__ == "__main__":
    srcfile = sys.argv[1]
    outfile = sys.argv[1].split(".")[0] + ".o"
    bytecode = assemble_file(srcfile)
    write_hex_to(outfile, bytecode)
    print("success!")
q