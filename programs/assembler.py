from assembler_settings import *
from assembly_exceptions import *

testfile_dir = "programs/test1.asm"
with open(testfile_dir, 'r') as testfile:
    text = testfile.read()

def get_value(text):
    if text[:2] == "0x":
        return int(text[2:], 16)
    elif text[:2] == "0b":
        return int(text[2:], 2)
    elif text.isdigit():
        return int(text)
    
    return text # it must be a symbol

def clean_spacing(text):
    # needed because raw_to_blocks is dumb and can't handle indentation apparently
    # this is the EASIEST solution, not the best 
    return text.replace("    ", "")

def raw_to_blocks(text):
    i = 0   # text index
    l = 1
    text = clean_spacing(text)
    blocks = []
    scratch = ""
    state = "mnemonic"
    while i < len(text):
        # fill scratch with mnemonic
        if state == "mnemonic":
            if text[i] not in " \n" and text[i] != "#":
                scratch += text[i]
            elif text[i] == "#":
                state = "comment"
            elif text[i] == " ":
                blocks.append(Block(scratch.strip("\n"), l))
                scratch = ""
                state = "argument"
            elif len(scratch) > 1:
                blocks.append(Block(scratch.strip("\n"), l))
                blocks.append(Block(ENDL, l))
                scratch = ""
                state = "mnemonic"
                l += 1
            else:
                l += 1
        elif state == "argument":
            if text[i] not in ",\n#":
                scratch += text[i]
            elif text[i] == ",":
                blocks.append(Block(scratch.strip(), l))
                scratch = ""
                state = "argument"
            elif text[i] == "#":
                blocks.append(Block(scratch.strip(), l))
                scratch = ""
                state = "comment"
            else:
                blocks.append(Block(scratch.strip(), l))
                blocks.append(Block(ENDL, l))
                scratch = ""
                state = "mnemonic"
                l += 1
        
        if state == "comment" and text[i] == "\n":
            state = "mnemonic"
            l += 1
        
        i += 1
    
    if scratch and state == "argument":
        blocks.append(Block(scratch.strip(), l))
        blocks.append(Block(ENDL, l))
    
    return blocks

def block_to_immediate(block):
    # check if immediate, return token if so
    if block.value.isdigit(): # e.g. 123
        return Token(IMMEDIATE, int(block.value), block.line)
    
    elif block.value[:2] == "0x": # e.g. 0x123ABC
        return Token(IMMEDIATE, int(block.value[2:], 16), block.line)

    elif block.value[:2] == "0b": # e.g. 0b10101111
        return Token(IMMEDIATE, int(block.value[2:], 2), block.line)
    
    return None # not an immediate, either a symbol or mnemonic

def block_to_symbol(block):
    # check if symbol, return token if so
    if block.value in registers:
        return Token(REGISTER, registers[block.value], block.line)
    elif block.value == ENDL:
        return Token(ENDL)
    elif len(block.value) > 0 and block.value[0] == "." and block.value in mnemonics:
        return Token(DIRECTIVE, block.value, block.line)
    elif len(block.value) > 0 and block.value[0] == ".":
        return Token(LABEL, block.value, block.line)
    elif block.value in mnemonics:
        return Token(MNEMONIC, block.value, block.line)
    elif block.value:
        return Token(SYMBOL, block.value, block.line)

def tokenize_blocks(blocks):
    tokens = []
    for b in blocks:
        token = block_to_immediate(b)
        if token:
            tokens.append(token)
        else:
            token = block_to_symbol(b)
            if token:
                tokens.append(token)
    
    return tokens

def get_type(block):
    if block.isdigit(): return "digit"
    elif block.isalnum() or "_" in block: return "symbol"
    elif block == " ": return None
    elif block == "(": return "parenthesis" # hacky fix to split ~ and ( into different tokens
    else: return "operator"

def get_expr_tokens(block):
    tokens = []
    scratch = ""
    current_type = None
    i = 0
    while i < len(block):
        if current_type == None:
            scratch += block[i]
        else:
            next_type = get_type(block[i])
            if next_type == current_type or next_type == "digit" and current_type == "symbol":
                scratch += block[i]
            elif next_type != current_type and next_type != None:
                tokens.append(scratch)
                scratch = block[i]
        current_type = get_type(scratch)

        i += 1
    
    if scratch:
        tokens.append(scratch)
    
    out = []
    for t in tokens:
        if t.isdigit():
            out.append(int(t))
        elif t[:2] == "0x":
            out.append(int(t[2:], 16))
        elif t[:2] == "0b":
            out.append(int(t[2:], 2))
        else:
            out.append(t)

    return out

def get_operator_precedence(op):
    precedence = {
        '(': 0,
        ')': 0,
        '==': 1,
        '!=': 1,
        '<': 2,
        '>': 2,
        '&': 3,
        '^': 4,
        '|': 5,
        '<<': 6,
        '>>': 6,
        '+': 7,
        '-': 7,
        '*': 8,
        '/': 8,
        '%': 8,
        '~': 9   # Unary operator, highest precedence
    }
    return precedence.get(op, -1)  # Return -1 for non-operators

def apply_operator(op, stack):
    if op == '~':
        if len(stack) < 1:
            raise ValueError("Insufficient operands for '~'")
        a = stack.pop()
        return ~a
    else:
        if len(stack) < 2:
            raise ValueError(f"Insufficient operands for '{op}'")
        b = stack.pop()
        a = stack.pop()
        if op == '+':
            return a + b
        elif op == '-':
            return a - b
        elif op == '*':
            return a * b
        elif op == '/':
            if b == 0:
                raise ValueError("Division by zero")
            return a // b  # Integer division for C-like behavior
        elif op == '%':
            if b == 0:
                raise ValueError("Modulus by zero")
            return a % b
        elif op == '<<':
            return a << b
        elif op == '>>':
            return a >> b
        elif op == '&':
            return a & b
        elif op == '|':
            return a | b
        elif op == '^':
            return a ^ b
        elif op == '<':
            return int(a < b)
        elif op == '>':
            return int(a > b)
        elif op == '==':
            return int(a == b)
        elif op == '!=':
            return int(a != b)
        else:
            raise ValueError(f"Unknown operator: {op}")

def evaluate_expr_tokens(expr_tokens, global_symbols):
    # Shunting Yard algorithm to convert infix to RPN
    output = []
    operator_stack = []
    
    for token in expr_tokens:
        if isinstance(token, int):
            output.append(token)
        elif token in global_symbols:
            if global_symbols[token].token == IMMEDIATE:
                output.append(global_symbols[token].value)
            else:
                raise TypeError("bad type, expected immediate")
        elif token in expression_operators:
            if token == '(':
                operator_stack.append(token)
            elif token == ')':
                while operator_stack and operator_stack[-1] != '(':
                    output.append(operator_stack.pop())
                if operator_stack and operator_stack[-1] == '(':
                    operator_stack.pop()  # Remove '('
            else:
                # Handle unary '~' (no previous operand or after another operator)
                is_unary = (token == '~' and 
                           (not output or 
                            expr_tokens[expr_tokens.index(token)-1] in ['(', '+', '-', '*', '/', '%', '<<', '>>', '&', '|', '^', '~', '<', '>', '==', '!=']))
                current_precedence = get_operator_precedence(token)
                # Pop operators with equal or higher precedence (for left-associative operators)
                while (operator_stack and operator_stack[-1] != '(' and 
                       get_operator_precedence(operator_stack[-1]) >= current_precedence):
                    output.append(operator_stack.pop())
                operator_stack.append(token)
        else:
            raise ValueError(f"Invalid token: {token}")

    # Pop remaining operators
    while operator_stack:
        op = operator_stack.pop()
        if op in ['(', ')']:
            raise ValueError("Mismatched parentheses")
        output.append(op)

    # Evaluate RPN expression
    stack = []
    for token in output:
        if isinstance(token, (int, float)):
            stack.append(token)
        else:
            result = apply_operator(token, stack)
            stack.append(result)

    if len(stack) != 1:
        raise ValueError("Invalid expression: too many operands")
    
    return stack[0]

def is_expression(token):
    for op in expression_operators:
        if op in token.value:
            return True
    return False

def tokens_to_blobs(tokens):
    blobs = []

    scratch = []
    for tok in tokens:
        if tok.token != ENDL:
            scratch.append(tok)
        else:
            blobs.append(scratch)
            scratch = []

    return blobs

def parse_blobs(blobs):
    symbols = {}
    procedures = {}
    data = {} # not implemented yet
    
    # verify number of arguments
    for b in blobs:
        mnemonic = b[0].value
        if mnemonic[-1] != ":" and len(b) - 1 != mnemonics[mnemonic]:
            raise IHonestlyDontKnowBoss("incorrect number of arguments")
    
    # define symbols
    for b in blobs:
        mnemonic = b[0].value
        if mnemonic == ".define":
            symbol = b[1].value
            token = b[2]
            symbols[symbol] = token
    
    # organize executable code into procedures
    current_procedure = None
    current_section = None
    for b in blobs:
        mnemonic = b[0].value

        if current_section == "CODE":
            if mnemonic[-1] == ":":
                current_procedure = mnemonic.strip(":")
                procedures[current_procedure] = [] # yes this clears a previous procedure if you define two different procedures with the same name
            else:
                # parse symbols
                newb = []
                for tok in b:
                    if tok.token == SYMBOL and tok.value in symbols:
                        newb.append(symbols[tok.value])
                    elif tok.token == SYMBOL and is_expression(tok):
                        newb.append(Token(IMMEDIATE, evaluate_expr_tokens(get_expr_tokens(tok.value), symbols)))
                    elif tok.token == SYMBOL and tok.value not in symbols:
                        raise IHonestlyDontKnowBoss(tok)
                    else:
                        newb.append(tok)
                
                procedures[current_procedure].append(newb)
        
        if mnemonic == ".section":
            current_section = b[1].value
    
    return procedures

def print_tokens(tokens, v=False):
    for t in tokens:
        if v or t.token != ENDL:
            print(t, end=" ")
            
        if t.token == ENDL:
            print()

def print_blocks(blocks, v=False):
    for b in blocks:
        if b or b.value == ENDL:
            print(b, end=" ")
        
        if b.value == ENDL:
            print()

def print_blobs(blobs):
    for b in blobs:
        print(b)

def get_rtype_bytes(op, rd, rs, rt, shamt, funct):
    result = ((op & 0b111111) |
              (rd & 0b11111) << 6 |
              (rs & 0b11111) << 11 |
              (rt & 0b11111) << 16 |
              (shamt & 0b11111) << 21 |
              (funct & 0b111111) << 26)
    return result.to_bytes(4, byteorder="little")

def get_itype_bytes(op, rd, rs, imm16):
    result = ((op & 0b111111) |
              (rd & 0b11111) << 6 |
              (rs & 0b11111) << 11 |
              (imm16 & 0xFFFF) << 16)
    return result.to_bytes(4, byteorder="little")

def get_jtype_bytes(op, offset26):
    result = ((op & 0b111111) |
               offset26 & 0x3ffffff << 6)
    return result.to_bytes(4, byteorder="little")

def blob_to_bytecode(blob):
    mnemonic = blob[0].value
    if mnemonic in rtype_mnemonics:
        op = 1
        rd = blob[1].value
        rs = blob[2].value
        rt = blob[3].value
        shamt = blob[3].value # yes this means shamt will have nonzero values even if it's not being used :/
        funct = rtype_mnemonics.index(mnemonic)

        return get_rtype_bytes(op, rd, rs, rt, shamt, funct)
    elif mnemonic in itype_mnemonics:
        op = 2 + itype_mnemonics.index(mnemonic) # to avoid 0 (reserved) and 1 (r-type)
        rd = blob[1].value
        rs = blob[2].value
        imm16 = blob[3].value

        return get_itype_bytes(op, rd, rs, imm16)
    elif mnemonic in jtype_mnemonics:
        op = 17 + jtype_mnemonics.index(mnemonic)
        jtarg26 = blob[1].value

        return get_jtype_bytes(op, jtarg26)
    
    raise Exception(blob)

def procedures_to_bytecode(procedures):
    # all procedures code will be packed into a binary containing all instructions
    # while respecting jumps/branches between procedures

    # get indexes of all procedures
    lengths = {}
    for p in procedures:
        lengths[p] = len(procedures[p]) * 4
    
    length = 0
    for l in lengths:
        length += lengths[l]
    
    loc = 0
    indexes = {}
    for p in procedures:
        indexes[p] = loc
        loc += lengths[p]
    
    # respect labels
    for p in procedures:
        for b in procedures[p]:
            for t in b:
                if t.token == LABEL:
                    # this is a MESS but it WORKS and THAT'S WHAT COUNTS
                    ti = b.index(t)
                    bi = procedures[p].index(b)
                    procedures[p][bi][ti] = Token(IMMEDIATE, indexes[t.value])

    # add procedures to bytearray
    bytecode = bytearray()
    for p in procedures:
        for blob in procedures[p]:
            bytecode += blob_to_bytecode(blob)
    
    return bytecode

def get_instruction_bits(instruction):
    bits = ""
    for b in instruction:
        bits += f"{b:08b}-"
    return bits[:-1]

def get_instruction_hex(instruction):
    words = ""
    for b in instruction:
        words += f"{b:02X}"
    return words

def print_bytecode(bytecode, printtype):
    i = 0
    while i < len(bytecode):
        instruction = bytecode[i:i+4]
        """
        opcode = instruction & 0b111111
        if opcode == 1: # r-type
            rs = """
        print(get_instruction_bits(instruction)) if printtype == "bits" else print(get_instruction_hex(instruction))
        i += 4

blocks = raw_to_blocks(text)
tokens = tokenize_blocks(blocks)
blobs = tokens_to_blobs(tokens)
procedures = parse_blobs(blobs)
bytecode = procedures_to_bytecode(procedures)
print_bytecode(bytecode, "hex")
print()
print_bytecode(bytecode, "bits")
