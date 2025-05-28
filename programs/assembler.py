"""
How the assembler should work (broadly)

Pass 1:
- Remove comments
- Tokenize lines

Pass 2:
- Store constants and links
- Convert immediate tokens into imm16, imm32, etc. tokens

Pass 3:
- Replace constant tokens with actual token
- Replace macros

Pass 4:
- Evaluate expression tokens (taking constants into mind)

Should have valid object code that can be converted to
machine code by a final pass
"""

from assembler_settings import * # constants, look-up tables, and configuration
from assembly_exceptions import *

# stripper
def strip_comment(line):
    line = line.replace("\n", "") # remove \n
    commentIndex = line.find("#") # find comment index

    if commentIndex >= 0:
        return line[:commentIndex].strip() # removes comment text and extra spaces
    
    return line # return clean line

def strip_comments(assembly_lines):
    striped_lines = []

    for line in assembly_lines:
        stripped_line = strip_comment(line)
        if stripped_line:
            striped_lines.append(stripped_line)
    
    return striped_lines

# tokenizer
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

def block_to_token(block):
    block = block.lower()

    # tokenize register
    if block in registers:
        return Token("REGISTER", registers[block])

    # tokenize immediate
    immediate = immediate_to_int(block)
    if immediate:
        return Token("IMMEDIATE", immediate)
    
    # tokenize constant
    if "(" in block or ")" in block:
        clean_expression = block.replace(" ", "")
        print(clean_expression)
        return Token("EXPRESSION", tokenize_expression(clean_expression))
    
    return Token("CONSTANT", block)

def tokenize_arguments(blocks, mnemonic, isInstruction, isDirective, isMacro):
    tokens = []

    for block in blocks:
        tokens.append(block_to_token(block))

    if isDirective:
        if mnemonic == "macro":
            tokens[0].token = "IDENTIFIER"
    
    return tokens

def line_to_blocks(line):
    line = line.strip().replace(",", "") # remove whitespace and commas (not required in Argon assembly)
    blocks = []

    expression_depth = 0
    block = ""
    for c in line:
        if c == " " and expression_depth == 0:
            blocks.append(block)
            block = ""
            continue
        elif c == "(":
            expression_depth += 1
        elif c == ")":
            expression_depth -= 1
        
        block += c
    
    if expression_depth != 0:
        raise MalformedExpressionError()
    
    if block:
        blocks.append(block)
        
    return blocks

def tokenize_line(line):
    tokens = []
    blocks = line_to_blocks(line)
    isInstruction = False
    isDirective = False
    isMacro = False

    # directive
    if blocks and blocks[0].startswith("."):
        isDirective = True
        mnemonic = blocks[0][1:].lower()

        if mnemonic in directives:
            tokens.append(Token("DIRECTIVE", mnemonic))
        else:
            raise UndefinedMnemonicError("Bad directive!")

    # opcode mnemonic
    elif blocks and blocks[0].lower() in mnemonics:
        isInstruction = True
        mnemonic = blocks[0].lower()
        tokens.append(Token("OPCODE", mnemonic))

    # macro mnemonic (assumed to be macro, we don't actually know if it is yet)
    else:
        isMacro = True
        mnemonic = blocks[0].lower()
        tokens.append(Token("MACRO", mnemonic))
        
    # get argument tokens
    tokens += tokenize_arguments(blocks[1:], mnemonic, isInstruction, isDirective, isMacro)
    
    return tokens

# constant replacer
def get_constants(tokenized_lines):
    constants = {}

    for line in tokenized_lines:
        if line[0].value == "define":
            constants[line[1].value] = line[2]

    return constants

def replace_constants(tokenized_lines, constants):
    for line in tokenized_lines:
        for token in line:
            if token.token == "CONSTANT":
                if token.value in constants:
                    real_token = constants[token.value]
                    token.token = real_token.token
                    token.value = real_token.value
                else:
                    raise UndefinedMnemonicError(f"\"{token.value}\" is an undefined constant")
    
    return tokenized_lines

def tokenize_expression(expression):
    # Assumes expression is stripped of spaces
    tokens = []
    expression_operators = ["+", "-", "*", "/", "%", "&", "|", "^", "<<", ">>", "~", "<", ">", "==", "!=", "(", ")"]
    
    i = 0
    while i < len(expression):
        # Try to match the longest operator starting at i
        matched_operator = None
        for op in sorted(expression_operators, key=len, reverse=True):  # Longest first
            if expression.startswith(op, i):
                matched_operator = op
                break
        
        if matched_operator:
            tokens.append(matched_operator)
            i += len(matched_operator)
            continue
        
        # Accumulate alphanumeric or underscore for variable/number
        if expression[i].isalnum() or expression[i] == "_":
            token = ""
            while i < len(expression) and (expression[i].isalnum() or expression[i] == "_"):
                token += expression[i]
                i += 1
            # Try to convert to integer (handles decimal, hex like 0x4)
            try:
                tokens.append(int(token, 0))  # Base 0 handles 0x, 0b, etc.
            except ValueError:
                tokens.append(token)  # Variable name
            continue
        
        raise ValueError(f"Invalid character in expression: {expression[i]}")
    
    return tokens

def precedence(operator):
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

if __name__ == "__main__":
    with open("programs/test1.asm", "r") as test1:
        asmlines = test1.readlines()

    stripped = strip_comments(asmlines)
    
    tokenized_lines = []
    for line in stripped:
        tokenized_lines.append(tokenize_line(line))
    
    for line in tokenized_lines:
        print(line)
    
    constants = get_constants(tokenized_lines)

    tokenized_expression = tokenized_lines[2][2].value
    result = evaluate_expression(tokenized_expression, constants)
    
    print("\n", tokenized_expression)
    print(result)
    
    """
    constants = get_constants(tokenized_lines)
    
    print("Tokens:")
    for line in tokenized_lines:
        print(line)
    
    print("\nFound constants:")
    print(constants)

    print("\nReplaced constants:")
    replaced = replace_constants(tokenized_lines, constants)
    for line in replaced:
        print(line)"""
