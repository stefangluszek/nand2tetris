#!/usr/bin/pike

mapping(string:int) symbols = ([
    "SP":       0x0000,
    "LCL":      0x0001,
    "ARG":      0x0002,
    "THIS":     0x0003,
    "THAT":     0x0004,
    "SCREEN":   0x4000,
    "KDB":      0x6000,
    "R0": 0, "R1": 1, "R2": 2,"R3": 3, "R4": 4, "R5": 5, "R6": 6, "R7": 7,
    "R8": 8, "R9": 9, "R11": 11, "R12": 12, "R13": 13, "R14": 14, "R15": 15,
]);

string filename;

string a_instruction(int val)
{
    int base = 0xff0000;
    return sprintf("%b", base | val)[8..];
}

string c_instruction(string val)
{
    /*
    *   Handle C-instruction
    *   dest=comp;jmp
    */
    int base = 0xff0000;
    string dest, comp, jmp;
    int d, ac, j;

    if (has_value(val, "=") && has_value(val, ";"))
    {
        if (!(sscanf(val, "%s=%s;%s", dest, comp, jmp) == 3)
            || !sizeof(dest) || !sizeof(dest) || !sizeof(jmp))
            return 0;
    }
    else if (has_value(val, "="))
    {
        if (!(sscanf(val, "%s=%s", dest, comp) == 2)
            || !sizeof(dest) || !sizeof(comp))
            return 0;
    }
    else if (has_value(val, ";"))
    {
        if (!(sscanf(val, "%s;%s", comp, jmp) == 2)
            || !sizeof(comp) || !sizeof(jmp))
            return 0;
    }
    else
        return 0;

    switch(comp){
        case "0":
            ac = 0b0101010;
            break;
        case "1":
            ac = 0b0111111;
            break;
        case "-1":
            ac = 0b0111010;
            break;
        case "D":
            ac = 0b0001100;
            break;
        case "A":
            ac = 0b0110000;
            break;
        case "!D":
            ac = 0b0001101;
            break;
        case "!A":
            ac = 0b0110001;
            break;
        case "-D":
            ac = 0b0001111;
            break;
        case "-A":
            ac = 0b0110011;
            break;
        case "D+1":
            ac = 0b0011111;
            break;
        case "A+1":
            ac = 0b0110111;
            break;
        case "D-1":
            ac = 0b0001110;
            break;
        case "A-1":
            ac = 0b0110010;
            break;
        case "D+A":
            ac = 0b0000010;
            break;
        case "D-A":
            ac = 0b0010011;
            break;
        case "A-D":
            ac = 0b0000111;
            break;
        case "D&A":
            ac = 0b0000000;
            break;
        case "D|A":
            ac = 0b0010101;
            break;
        case "M":
            ac = 0b1110000;
            break;
        case "!M":
            ac = 0b1110001;
            break;
        case "-M":
            ac = 0b1110011;
            break;
        case "M+1":
            ac = 0b1110111;
            break;
        case "M-1":
            ac = 0b1110010;
            break;
        case "D+M":
            ac = 0b1000010;
            break;
        case "D-M":
            ac = 0b1010011;
            break;
        case "M-D":
            ac = 0b1000111;
            break;
        case "D&M":
            ac = 0b1000000;
            break;
        case "D|M":
            ac = 0b1010101;
            break;
        default:
            return 0;
    }

    switch(jmp){
        case 0:
        case "":
            j = 0b000;
            break;
        case "JGT":
            j = 0b001;
            break;
        case "JEQ":
            j = 0b010;
            break;
        case "JGE":
            j = 0b011;
            break;
        case "JLT":
            j = 0b100;
            break;
        case "JNE":
            j = 0b101;
            break;
        case "JLE":
            j = 0b110;
            break;
        case "JMP":
            j = 0b111;
            break;
        default:
            return 0;
    }

    switch(dest){
        case 0:
        case "":
            d = 0b000;
            break;
        case "M":
            d = 0b001;
            break;
        case "D":
            d = 0b010;
            break;
        case "MD":
            d = 0b011;
            break;
        case "A":
            d = 0b100;
            break;
        case "AM":
            d = 0b101;
            break;
        case "AD":
            d = 0b110;
            break;
        case "AMD":
            d = 0b111;
            break;
        default:
            return 0;
    }
    int res = 0b111 << 13;
    res += ac << 6;
    res += d << 3;
    res += j;
    return sprintf("%b", base | res)[8..];
}

void first_pass(Stdio.File f)
{
    int pc;

    foreach(f->line_iterator(true); int n; string line)
    {
        string label;
        string current = String.trim_all_whites(line);
        current -= " ";
        current = (current / "//")[0];

        if (has_prefix(current, "//") || !sizeof(current))
            continue;

        if (sscanf(current, "(%s)", label))
        {
            if (has_index(symbols, label))
                exit(1, "%s:%d: Duplicated label: %s\n", filename, n, label);

            symbols[label] = pc;
            continue;
        }
        pc++;
    }
}

void second_pass(Stdio.File f)
{
    int variable_address = 0x0010;
    string current_instruction;
    Stdio.Buffer b = Stdio.Buffer();

    foreach(f->line_iterator(true); int n; string line)
    {
        string|int var;
        string current = String.trim_all_whites(line);
        current -= " ";
        current = (current / "//")[0];  //Remove comments, such as this one

        if (has_prefix(current, "//") || !sizeof(current) ||
                sscanf(current, "(%*s)"))
            continue;

        if (sscanf(current, "@%d", var))
        {
            if (var < 0)
                exit(2, "%s:%d: Constants must be non-negative.\n", filename, n);

            current_instruction = a_instruction(var);
        }
        else if (sscanf(current, "@%s", var))
        {
            if (has_index(symbols, var))
            {
                var = symbols[var];
            }
            else
            {
                symbols[var] = variable_address;
                var = variable_address++;
            }
            current_instruction = a_instruction(var);
        }
        else
        {
            current_instruction = c_instruction(current);
        }
        if (!current_instruction)
            exit(3, "%s:%d: Invalid instruction: %s\n", filename, n, current);

        b->add(current_instruction + "\n");
    }
    write("%s", b->read());
}

int main(int c, array v)
{
    if (c < 2)
        exit(1, "Usage ./assembler.pike filename.asm > filename.hack\n");

    filename = v[1];
    Stdio.File file = Stdio.File();
    if (!file->open(filename, "r"))
        exit(1, "Failed to open; %s (%s).\n", filename, strerror(file->errno()));

    first_pass(file);
    file->seek(0);
    second_pass(file);
    return 0;
}
