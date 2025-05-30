#!/usr/bin/env python3
from assembler_settings import * # constants, look-up tables, and configuration
from assembly_exceptions import *

# helpful tokens
ENDL    = "$ENDL"       # end line
ENDF    = "$ENDF"       # end file
STARTF  = "$STARTF"     # start file
STARTEX = "$STARTEX"    # start expression
ENDEX   = "$ENDEX"      # end expression

def raw_to_blocks(raw):
    # convert raw assembly into semantic blocks
    index = 0
    line = 1
    column = 1
    blocks = [STARTF]
    current_block = ""
    nextline = False
    expression_depth = 0

    # because the block-inator breaks without a newline at the end
    if raw[-1] != "\n":
        raw += "\n"

    try:
        while index < len(raw):
            c = raw[index]
            index += 1
            if index < len(raw):
                nextc = raw[index]
            else:
                nextc = "\x00"
            
            if c in "\n#;":
                nextline = True
            
            if c.isalnum() or c in "_.:":
                current_block += c
            
            if c in " ,()\n":
                if len(current_block) > 0:
                    blocks.append(current_block)
                    current_block = ""
                    current_type = ""
                else:
                    if c == ",":
                        raise IHonestlyDontKnowBoss(f"Too many separators at ({line}, {column})")
            
            if c in "()":
                if c == "(":
                    expression_depth += 1
                elif c == ")":
                    expression_depth -= 1
                
                if expression_depth < 0:
                    raise IHonestlyDontKnowBoss(f"Bad expression at ({line}, {column})")
                
                blocks.append(c)

            elif c in expression_operators or c + nextc in expression_operators:
                if c in expression_operators and not c + nextc in expression_operators:
                    blocks.append(c)
                else:
                    blocks.append(c + nextc)

                    index += 1

            
            if nextline:
                # reset types
                current_type = ""
                
                if expression_depth != 0:
                    raise IHonestlyDontKnowBoss(f"Bad expression at ({line}, {column})")
                
                # find newline
                original_nextc = nextc
                while c != "\n":
                    c = raw[index]
                    index += 1
                
                line += 1
                column = 1
                nextline = False
                if blocks[-1] != ENDL and blocks[-1] != STARTF:
                    blocks.append(ENDL)
                continue
            
            column += 1
    except IndexError:            
        raise IHonestlyDontKnowBoss(
            "something is unfinished, here's the deets",
            f"Line: {line}",
            f"Column: {column}",
            f"Expression depth: {expression_depth}")
    
    return blocks + [ENDF]

def immediate_to_int(block):
    # hexadecimal representation
    if block[0:2] == "0x":
        return int(block[2:], 16)
    
    # binary representation
    if block[0:2] == "0b":
        return int(block[2:], 16)
    
    # decimal representation
    try:
        return int(block)
    except ValueError:
        return None

def blocks_to_tokens(blocks):
    tokens = []

    # make sure the blocks are blocks
    assert blocks[0] == STARTF
    assert blocks[-1] == ENDF

    state = ""
    block_index = 1 # skip STARTF
    expression_depth = 0
    while block_index < len(blocks):
        b = blocks[block_index]
        if b != ENDF:
            nb = blocks[block_index + 1]
        else:
            break # we reached the end of the blocks
        
        if b in mnemonics:
            if b[0] != ".":
                tokens.append(Token(
                    "MNEMONIC",
                    b,
                    -1, # unknown
                    -1, # unknown
                    b
                ))
            else:
                tokens.append(Token(
                    "DIRECTIVE",
                    b,
                    -1, # unknown
                    -1, # unknown
                    b
                ))
        elif b in sections:
            tokens.append(Token(
                "SECTION",
                b,
                -1,
                -1,
                b
            ))
        elif b in expression_operators:
            tokens.append(Token(
                "OPERATOR",
                b,
                -1, # unknown
                -1, # unknown
                b
            ))

            if b == "~":
                if expression_depth == 0:
                    tokens.insert(-1, Token(
                        STARTEX
                    ))
                expression_depth += 0.5

            elif b == "(":
                if expression_depth == 0:
                    tokens.insert(-1, Token(
                        STARTEX
                    ))
                
                expression_depth += 1
            elif b == ")":
                if expression_depth == 0:
                    raise MalformedExpressionError("Bad expression!")
                
                expression_depth -= 1
                if expression_depth < 1:
                    tokens.append(Token(
                        ENDEX
                    ))
            
        elif b == ENDL:
            tokens.append(Token(
                ENDL
            ))
        elif b in registers:
            tokens.append(Token(
                "REGISTER",
                registers[b],
                -1,
                -1,
                b
            ))
        elif b[-1] == ":":
            tokens.append(Token(
                "PROCEDURE",
                b[:-1],
                -1,
                -1,
                b
            ))
        else:
            int_b = immediate_to_int(b)
            if int_b:
                tokens.append(Token(
                    "IMMEDIATE",
                    int_b,
                    -1, # unknown
                    -1, # unknown
                    b
                ))
            else:
                if blocks[block_index - 1] != ENDL:
                    tokens.append(Token(
                        "SYMBOL",
                        b,
                        -1, # unknown
                        -1, # unknown
                        b
                    ))
                else:
                    tokens.append(Token(
                        "MACRO",
                        b,
                        -1, # unknown
                        -1, # unknown
                        b
                    ))

        block_index += 1
    
    return tokens

def get_symbol_definitions(tokens, namespace="global"):
    # returns dictionary containing symbol labels and their values
    # while verifying that the .define directive 
    symbols = {}
    symbols[namespace] = {}

    i = 0
    while i < len(tokens):
        tok = tokens[i]
        if tok.token == "DIRECTIVE" and tok.value == ".define":
            symbol_tok = tokens[i + 1]
            value_tok = tokens[i + 2]
            symbols[namespace][symbol_tok.value] = value_tok
            i += 3
        elif tok.token == "PROCEDURE":
            namespace = tok.value
            symbols[namespace] = {}
            i += 1
        else:
            i += 1
    
    return symbols

def parse_macro_definitions(tokens):
    macro_definitions = {}
    out_tokens = []
    
    current_tokens = []
    current_identifier = ""
    reading_macro = False
    for tok in tokens:
        if reading_macro:
            if not current_identifier:
                current_identifier = tok.value
            elif tok.value != ".endmacro":
                current_tokens.append(tok)
            else:
                macro_definitions[current_identifier] = current_tokens
                current_identifier = ""
                current_tokens = []
                reading_macro = False
                continue
    
        else:
            if tok.value == ".macro":
                reading_macro = True
                continue
            else:
                if not (tok.token == ENDL and out_tokens[-1].token == ENDL):
                    out_tokens.append(tok)
            
    return macro_definitions, out_tokens

def replace_symbols(tokens, symbols, namespace="global"):
    # replaces the symbol tokens within the tokens list, then returns the new tokens

    i = 0
    while i < len(tokens):
        tok = tokens[i]
        if tok.token == "SYMBOL":
            tokens[i] = symbols[namespace][tok.value]
        elif tok.token == "PROCEDURE":
            namespace = tok.value
            symbols[namespace] = {}
        
        i += 1
    
    return tokens

def precedence(operator):
    # C-like operation precedence, according to Grok
    if operator in ["+", "-"]:
        return 0
    elif operator in ["|"]:
        return 1
    elif operator in ["^"]:
        return 2
    elif operator in ["&"]:
        return 3
    elif operator in ["<<", ">>"]:
        return 4
    elif operator in ["*", "/", "%"]:
        return 5
    elif operator in ["~"]:
        return 13
    return -1  # Invalid operator

def compute(operator, operand1, operand2):
    result = None
    # Arithmetic
    if operator == "+":
        result = operand1 + operand2
    elif operator == "-":
        result = operand1 - operand2
    elif operator == "*":
        result = operand1 * operand2
    elif operator == "/":
        result = operand1 // operand2  # Integer division
    elif operator == "%":
        result = operand1 % operand2
    # Bitwise
    elif operator == "&":
        result = operand1 & operand2
    elif operator == "|":
        result = operand1 | operand2
    elif operator == "^":
        result = operand1 ^ operand2
    elif operator == "<<":
        result = operand1 << operand2
    elif operator == ">>":
        result = operand1 >> operand2
    elif operator == "~":
        result = ~operand1
    else:
        raise ValueError(f"Invalid operator: {operator}")
    
    return result

def evaluate_expression(expression, constants):
    operands = []
    operators = []
    expression_operators = ["+", "-", "*", "/", "%", "&", "|", "^", "<<", ">>", "~", "<", ">", "==", "!=", "(", ")"]
    
    for token in expression:
        if isinstance(token, int):
            operands.append(token)
        elif token in constants:
            operands.append(constants[token])
        elif token == "(":
            operators.append(token)
        elif token == ")":
            while len(operators) != 0 and operators[-1] != "(":
                operator = operators.pop()
                if operator not in expression_operators:
                    raise ValueError(f"Invalid operator on stack: {operator}")
                if operator != "~":
                    if len(operands) < 2:
                        raise ValueError("Not enough operands for binary operator")
                    operand2 = operands.pop()
                    operand1 = operands.pop()
                else:
                    if len(operands) < 1:
                        raise ValueError("Not enough operands for unary operator")
                    operand2 = operands.pop()
                    operand1 = 0  # Don't care
                result = compute(operator, operand1, operand2)
                operands.append(result)
            if len(operators) == 0:
                raise ValueError("Mismatched parentheses")
            operators.pop()  # Discard (
        elif token in expression_operators:
            thisOp = token
            while (len(operators) != 0 and operators[-1] != "(" and 
                   precedence(operators[-1]) >= precedence(thisOp)):
                operator = operators.pop()
                if operator not in expression_operators:
                    raise ValueError(f"Invalid operator on stack: {operator}")
                if operator != "~":
                    if len(operands) < 2:
                        raise ValueError("Not enough operands for binary operator")
                    operand2 = operands.pop()
                    operand1 = operands.pop()
                else:
                    if len(operands) < 1:
                        raise ValueError("Not enough operands for unary operator")
                    operand2 = operands.pop()
                    operand1 = 0  # Don't care
                result = compute(operator, operand1, operand2)
                operands.append(result)
            operators.append(thisOp)
    
    while len(operators) != 0:
        operator = operators.pop()
        if operator not in expression_operators:
            raise ValueError(f"Invalid operator on stack: {operator}")
        if operator != "~":
            if len(operands) < 2:
                raise ValueError("Not enough operands for binary operator")
            operand2 = operands.pop()
            operand1 = operands.pop()
        else:
            if len(operands) < 1:
                raise ValueError("Not enough operands for unary operator")
            operand2 = operands.pop()
            operand1 = 0
        result = compute(operator, operand1, operand2)
        operands.append(result)
    
    if len(operators) == 0 and len(operands) == 1:
        return operands[0]
    raise ValueError("Invalid expression")

def print_blocks(blocks):
    for b in blocks:
        if b != ENDL:
            print(b, end=" ")
        else:
            print()

def print_tokens(tokens, verbose=False):
    for tok in tokens:
        if tok.token != ENDL:
            print(tok, end=" ")
        else:
            print(tok) if verbose else print()

"""
How the assembler should work (broadly)

Step 1:
- Convert raw assembly into blocks (remove comments, spaces, and newlines)
- Convert blocks into tokens

Pass 2:
- Store symbol definitions

Pass 3:
- Remove macro definitions and store in separate dictionary

Pass 4:
- Replace symbols (bearing sections in mind)

Pass 5
- Expand macros

Pass 6:

Should have valid object code that can be converted to
machine code by a final pass
"""

if __name__ == "__main__":
    with open("programs/test1.asm", "r") as test1:
        rawtext = test1.read()

    # step 1
    blocks = raw_to_blocks(rawtext)
    tokens = blocks_to_tokens(blocks)
    print_tokens(tokens)

    # step 2
    symbols = get_symbol_definitions(tokens)

    # step 3
    macro_definitions, no_macro_definitions_tokens = parse_macro_definitions(tokens)
    print_tokens(no_macro_definitions_tokens, 1)

    # step 4
    expanded_tokens = expand_macros(no_macro_definitions_tokens, macro_definitions)

    # step 5
