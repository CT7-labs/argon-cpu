# stripper

def strip_comment(line):
    commentIndex = line.find("#")

    if commentIndex >= 0:
        return line[:commentIndex].strip() # removes comment text and extra spaces
    
    return line # return original line

def strip_comments(assembly_lines):
    striped_lines = []

    for line in assembly_lines:
        stripped_line = strip_comment(line)
        if stripped_line:
            striped_lines.append(stripped_line)
    
    return striped_lines


# tokenizer
mnemonics = "add sub beq slt" # unfinished
directives = "macro endmacro text data"

class Token:
    def __init__(self, token, value):
        self.token = token # identifier, keyword, literal, etc.
        self.value = value # r13, .section, 0x1234, etc.
    
    def __repr__(self):
        return f"{self.token}: {self.value}"

def tokenize_line(line):
    tokens = []
    blocks = line.split()

    # handle directives
    if blocks and blocks[0].startswith("."):
        directive_name = blocks[0][1:].lower()
        if directive_name in directives:
            tokens.append(Token("DIRECTIVE", blocks[0].replace(".", "")))
            for block in blocks[1:]:
                tokens.append(Token("IDENTIFIER", block.replace(",", "")))  # Handle macro name, params
    
    # handle mnemoniccs
    if blocks and blocks[0].lower() in mnemoniccs:
        mnemonic_name = blocks[0].lower()
        if mnemonic_name
    
    return tokens

if __name__ == "__main__":
    with open("programs/test1.asm", "r") as test1:
        asmlines = test1.readlines()

    stripped = strip_comments(asmlines)
    print(stripped)
    tokenized = tokenize_line(stripped[0])
    print(tokenized)