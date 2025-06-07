from assembler_settings import *

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

def raw_to_blocks(text):
    i = 0   # text index
    l = 1
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
    
    return None

def block_to_symbol(block):
    # check if symbol, return token if so
    if block.value in registers:
        return Token(REGISTER, registers[block.value], block.line)
    elif block.value == ENDL:
        return Token(ENDL)
    elif block.value[0] == ".":
        return Token(DIRECTIVE, block.value, block.line)
    elif block.value in mnemonics:
        return Token(MNEMONIC, block.value, block.line)
    return Token(SYMBOL, block.value, block.line)

def tokenize_blocks(blocks):
    tokens = []
    for b in blocks:
        token = block_to_immediate(b)
        if not token:
            token = block_to_symbol(b)
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
            print(current_type, next_type, block[i])
            if next_type == current_type:
                scratch += block[i]
            elif next_type != current_type and next_type != None:
                tokens.append(scratch)
                scratch = block[i]
        current_type = get_type(scratch)

        i += 1
    
    if scratch:
        tokens.append(scratch)
    
    return tokens

def parse_tokens(tokens):
    global_symbols = {}
    data_symbols = {}
    i = 0
    section = None  # No section initially
    scratch = []  # Buffer for current line
    text_tokens = []  # Tokens within .text

    while i < len(tokens):
        tok = tokens[i]
        if tok.token == ENDL:
            if scratch:  # Process non-empty line
                cmd = scratch[0]
                if cmd.token == DIRECTIVE:
                    if cmd.value == ".define":
                        global_symbols[scratch[1].value] = scratch[2]
                    elif cmd.value in [".text", ".data"]:
                        section = cmd.value
                elif cmd.token == MNEMONIC and section == ".text":
                    for t in scratch:
                        if t.token == SYMBOL:
                            if t.value in global_symbols:
                                new_token = global_symbols[t.value]
                                text_tokens.append(new_token)
                            else:
                                is_expression = False
                                for op in expression_operators:
                                    if op in t.token:
                                        is_expression = True
                                        break
                                
                                if is_expression:
                                    expression_tokens = get_expr_tokens(t.value)
                                    
                                    # evaluate expression tokens
                                    # append final token
                        else:
                            text_tokens.append(t)
                    text_tokens.append(Token(ENDL, None, tok.line))
            scratch = []  # Reset after processing line
        else:
            scratch.append(tok)
        i += 1

    # Handle last line if no ENDL
    if scratch and scratch[0].token == MNEMONIC and section == ".text":
        text_tokens.extend(scratch)
        text_tokens.append(Token(ENDL, None, scratch[0].line))

    return text_tokens

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

blocks = raw_to_blocks(text)
tokens = tokenize_blocks(blocks)
parsed = parse_tokens(tokens)
print("Tokens:")
print_tokens(tokens)
print("\nParsed Tokens:")
print_tokens(parsed)
print(get_expr_tokens("~(this + is << 4 * test)"))