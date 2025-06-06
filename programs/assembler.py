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

def argument_to_token(text, pos):
    if text in registers:
        return Token(REGISTER, registers[text], pos)
    
    value = get_value(text)
    if type(value) == int:
        return Token(IMMEDIATE, value, pos)
    elif value in expression_operators:
        return Token(OPERATOR, value, pos)
    return Token(SYMBOL, value, pos)

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
                blocks.append(ENDL)
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
                blocks.append(ENDL)
                scratch = ""
                state = "mnemonic"
                l += 1
        
        if state == "comment" and text[i] == "\n":
            state = "mnemonic"
            l += 1
        
        i += 1
    
    if scratch and state == "argument":
        blocks.append(scratch.strip())
        blocks.append(ENDL)
    
    return blocks

def print_tokens(tokens, v=False):
    for t in tokens:
        if v or t.token != ENDL:
            print(t, end=" ")
            
        if t.token == ENDL:
            print()

def print_blocks(blocks, v=False):
    for b in blocks:
        if b or b.value == "\n":
            print(b, end=" ")
        
        if b.value == "\n":
            print()

blocks = raw_to_blocks(text)
for block in blocks:
    print(block)