from bitstring import BitArray as B


"""
0001011
0101011
1011011
1111011




"""
def intrp_instructions():
    dict_lines = []
    define_lines = []
    declare_lines = []

    instructions = [

    {'name': 'par_rst',         'type': 'r', 'operands': 'D,S,T', 'class': 'INSN_CLASS_F',  'opcode': '00010', 'funct3': '000', 'funct7': '0000000'},
    {'name': 'par_ask',         'type': 'r', 'operands': 'D,S,T', 'class': 'INSN_CLASS_F',  'opcode': '00010', 'funct3': '001', 'funct7': '0000000'},
    {'name': 'par_tell',        'type': 'r', 'operands': 'D,S,T', 'class': 'INSN_CLASS_F',  'opcode': '00010', 'funct3': '010', 'funct7': '0000000'},
    {'name': 'par_print_int',   'type': 'r', 'operands': 'D,S,T', 'class': 'INSN_CLASS_F',  'opcode': '01010', 'funct3': '000', 'funct7': '0000000'},
    {'name': 'par_print_float', 'type': 'r', 'operands': 'D,S,T', 'class': 'INSN_CLASS_F',  'opcode': '01010', 'funct3': '001', 'funct7': '0000000'},

    ]



    for el in instructions:
        el['label'] = el['name'].upper()
        if el['type']=='r':
            el['match'] = B(f"bin={el['funct7']}0000000000{el['funct3']}00000{el['opcode']}11").hex.lstrip("0")
            el['mask'] = B("bin=11111110000000000111000001111111").hex.lstrip("0")
        elif el['type']=='i':
            el['match'] = B(f"bin=0000000000000000000000000{el['opcode']}11").hex.lstrip("0")
            el['mask'] = B("bin=00000000000000000000000001111111").hex.lstrip("0")
        define_lines.append(f"#define MATCH_{el['label']} 0x{el['match']}")
        define_lines.append(f"#define MASK_{el['label']} 0x{el['mask']}")


    for el in instructions:
        declare_lines.append(f"DECLARE_INSN({el['name']}, MATCH_{el['label']}, MASK_{el['label']})")



    for el in instructions:
        dict_lines.append([f"{el['name']}", 0, el['class'], el['operands'] if el['type']=='r' else "d,a", f"MATCH_{el['label']}", f"MASK_{el['label']}", "match_opcode", 0])



    return define_lines, declare_lines, dict_lines


def print_dict(x):
    print('{"', end ='')
    print(x[0], end ='')
    print('"', end ='')
    print(f', {x[1]}, {x[2]}, "{x[3]}", {x[4]}, {x[5]}, {x[6]}, {x[7]}', end ='')
    print('},', end ='')

    print()

def write_to_toolchain(define_lines, declare_lines):

    num_dec = 12
    if (num_dec == int(num_dec)) and num_dec in list(range(1, 17)):

        with open('main_dummy.txt', 'w') as f:
            f.write(f"dfksdfjh\n\n")
            f.write(f"start\n")
            f.write(f"//num_dec_def\n")
            f.write(f"    localparam                                              num_dec             = 2;\n")
            f.write("    reg                 [address_len - 1 : 0]               budget              ;\n")
            f.write(f"end\n")
            f.write(f"dfksdfjh\n\n")



    with open('main_dummy.txt', 'r') as main_file:
        with open('temp_dummy.txt', 'w') as temp_file:
                main_file_lines = main_file.readlines()

                next_line_is_target = False
                done_replacing = False

                for line in main_file_lines:

                    if (not next_line_is_target) and (not done_replacing):
                        temp_file.write(f"{line}\n")
                    else:
                        temp_file.write()
                    if '//num_dec_def' in line:
                        next_line_is_target = True






    f.close()

if __name__ == '__main__':
    define_lines, declare_lines, dict_lines= intrp_instructions()

    for el in dict_lines:
        print_dict(el)

    for el in define_lines:
        print(el)

    for el in declare_lines:
        print(el)


    # write_to_toolchain(define_lines, declare_lines)
