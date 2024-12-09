'''


8 bit SAP 1 Assembler

Target Build:
8SAP2

'''

import os

DATA = 0
EXEC = 1

OPS = {"NOP": (0, 1),
       "LDI": (1, 2),
       "LDA": (2, 2),
       "LDB": (3, 2),
       "JMP": (4, 2),
       "JPZ": (5, 2),
       "JPC": (6, 2),
       "STR": (7, 2),
       "LDM": (8, 1),
       "MOV": (9, 1),
       "OUT": (10, 1),
       "STM": (11, 1),
       "ADD": (12, 1),
       "SUB": (13, 1),
       "SFT": (14, 1),
       "HLT": (15, 1)
       }

sections = {
    "p": {"name": "p","type": 1,"size": 0,"offset": 0,"file": 0,"data": ""},
    "m": {"name": "m","type": 0,"size": 0,"offset": 0,"file": 0,"data": ""},
    "x": {"name": "x","type": 1,"size": 0,"offset": 0,"file": 1,"data": ""},
    "d": {"name": "d","type": 0,"size": 0,"offset": 0,"file": 1,"data": ""},
    }

output_sections = []

def raiseSyntaxError(ln, filename):
    error_str = "Invalid Syntax at line: {}:{}".format(filename, ln)
    SyntaxError(error_str)


def assemble_SAP(source, filename):
    """
    Assemble SAP program
    """

    ln = 0
    
    data_bytes = 0
    data_size = 0

    curr_section = None

    # Iterate Over all lines in source
    for line in source:
        
        # Incriment line ocunter
        ln += 1

        # check for comments or malformed lines
        if (line[0] in ["#","/",'*']) or (len(line) < 2) or (line == ""):
            continue

        # get list of symbols on line
        syms = line.rstrip('\n').split(' ')

        #print(syms)
        if len(syms) < 1:
            continue

        if len(syms[0]) < 1:
            continue

        # First two chars of first symbol
        s00 = syms[0][0]
        s01 = syms[0][1]

        # Check for section headers
        if s00 == ".":
            if s01 in sections:
                # Assemble new Section
                
                # output last section
                print(curr_section)
                
                # Set cursor con current
                curr_section = dict(sections[s01])
                
                # Get number of attributes and parse
                n_atrib = len(syms) - 1
                #print(n_atrib)
                
                # Parse Offset
                if(n_atrib >= 1):
                    #print(syms[1])
                    try:
                        offset = int(syms[1], 16)
                    except:
                        offset = 0
                    curr_section["offset"] = offset

                # Parse Size
                if(n_atrib >= 2):
                    #print(syms[2])
                    try:
                        data_size = int(syms[2], 16)
                    except:
                        data_size = 0
                    curr_section["size"] += data_size

                data_bytes = 0
                
                print("New Section: {}: {} {}".format(curr_section["name"], curr_section["offset"], curr_section["size"]))
                
                # Add section definition to map
                output_sections.append(curr_section)
                
        else:
            # Data and Opcodes Pasing
            # Check for expected Data
            if (data_bytes < data_size):
                
                if (curr_section["type"] == 0):
                
                    data_bytes += 1
                    try:
                        curr_section["data"] += syms[0] + " "
                    except:
                        raiseSyntaxError(ln,filename)
                else:
                    #raiseSyntaxError(ln,filename)
                

                    # Opcode Parser
                    # Check for symbol in operators
                    value = 0
                    op_name = syms[0]
                    
                    if not (op_name in OPS):
                        raiseSyntaxError(ln,filename)
                    
                    op = OPS[op_name]
                    if len(syms) >= op[1]:
                        if (op[1] == 2):
                            oprnd = syms[1]
                            if oprnd[0] == "#":
                                value = int(oprnd[1:])

                        for sym in syms:
                            if sym in ["", " ", "\t"]:
                                continue
                            if (sym == "//") or (sym[0:2] == "//"):
                                break
                    else:
                        raiseSyntaxError(ln,filename)

                    # Generate Opcode
                    opcode = "0x{:02x}".format(((op[0] << 4) | (value & 0x0F)))
                    print( "\t--> OP: {} #{} => {}".format(op_name,value,opcode) )
                    
                    # Add to section
                    curr_section['data'] += opcode + " "
                    data_bytes += 1
            else:
                raiseSyntaxError(ln,filename)

    # output last section
    #print(curr_section)

    # Concatante Sections to files
    PROM = ""
    RAM  = ""
    for sec in output_sections:
        
        # Sort for exec and data sections in RAM
        if (sec['name'] in ['x','d']) and (sec["file"] == 1):
            print(sec)
        
            # Pad to offset
            dof =  sec['offset'] - len(RAM.rstrip(" ").split(" "))
            print(dof)
            for _ in range(dof):
                RAM += '0x00 '

            # Pad to size
            dsz =  sec['size'] - len(sec['data'].rstrip(" ").split(" "))
            print(dsz)
            for _ in range(dsz):
                sec['data'] += '0x00 '

            # Add Section to file
            RAM += sec['data']

        elif (sec['name'] in ['p']) and (sec["file"] == 0):

            codes = PROM.split(" ")
            # Pad to offset
            dof =  sec['offset'] - len(PROM.rstrip(" ").split(" "))
            
            for _ in range(dof):
                PROM += '0x00 '

            # Pad to size
            dsz =  sec['size'] - len(sec['data'].rstrip(" ").split(" "))
            print(dsz)
            for _ in range(dsz):
                sec['data'] += '0x00 '

            # Add Section to file
            PROM += sec['data']

    #print(PROM)

    opcodes = PROM.split(' ')
    opcodes.remove('')
    prom = bytes([int(d,16) for d in opcodes])

    

    opcodes = RAM.split(' ')
    opcodes.remove('')
    ram = bytes([int(d,16) for d in opcodes])
    
    step = 8
    for i in range(0,len(opcodes),step):
        msg = ""
        for n in range(step):
            msg += "{}, ".format(opcodes[i+n])
        print(msg)

    return prom, ram
            

def assemble_file(filename):
    with open(filename, 'r') as f:
        source = f.readlines()
    return assemble_SAP(source, filename)

def write_to_files(filename, code):
    with open(f'{filename}.bin', 'wb') as f:
        f.write(code)

'''

import tkinter as tk
from tkinter.filedialog import askopenfilename

def select_file():
    filename = askopenfilename(title='Select file', filetypes=(('assembly', '*.s'), ('All files', '*.*')))
    if filename:
        root, ext = os.path.splitext(filename)
        if not os.path.exists(root):
            os.mkdir(root)
        
        basename = os.path.basename(root)
        print(basename)
        
        boot, app = assemble_file(filename)
        write_to_files(root + "/" + basename + ".boot", boot)
        write_to_files(root + "/" + basename + ".app",  app)

        
def main ():
    root = tk.Tk()
    root.withdraw()
    select_file()
'''

if __name__ == '__main__':

    # main()

    filename = "primesfinder.s"
    root, ext = os.path.splitext(filename)
    basename = os.path.basename(root)

    if not os.path.exists(root):
        os.mkdir(root)

    boot, app = assemble_file(filename)
    write_to_files(root + "/" + basename + ".boot", boot)
    write_to_files(root + "/" + basename + ".app",  app)

