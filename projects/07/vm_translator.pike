#!/usr/bin/pike

#include "commands.h";

Stdio.Buffer b;
int id = 0;

void syntax_err(string file, int n, string msg, mixed ...args)
{
    exit(1, "%s:%d " + msg, file, n, @args);
}

void handle_push_command(array(string) line, string file, int n)
{
    if (sizeof(line) != 3)
    {
        syntax_err(file, n, "Push needs 2 arguments, got: %d\n",
                    sizeof(line) - 1);
    }
    switch(line[1]){
        case "constant":
            b->add(sprintf(push_constant_template, (int)line[2]));
            break;
        case "static":
            b->add(sprintf(push_static_template, basename(file[..<3]),
                            (int)line[2]));
            break;
        case "local":
            b->add(sprintf(push_segment_template, (int)line[2], "LCL"));
            break;
        case "argument":
            b->add(sprintf(push_segment_template, (int)line[2], "ARG"));
            break;
        case "this":
            b->add(sprintf(push_segment_template, (int)line[2], "THIS"));
            break;
        case "that":
            b->add(sprintf(push_segment_template, (int)line[2], "THAT"));
            break;
        case "temp":
            b->add(sprintf(push_temp_template, (int)line[2]));
            break;
        case "pointer":
            int i = (int) line[2];
            string key;
            if (i == 0)
                key = "THIS";
            else if (i == 1)
                key = "THAT";
            else
            {
                syntax_err(file, n, "Invalid pointer index: %d\n", i);
            }
            b->add(sprintf(push_pointer_template, key));
            break;
        default:
            syntax_err(file, n, "Invalid push segment: %s\n", line[1]);
    }
}

void handle_pop_command(array(string) line, string file, int n)
{
    if (sizeof(line) != 3)
    {
        syntax_err(file, n, "Push needs 2 arguments, got: %d\n",
                    sizeof(line) - 1);
    }
    switch(line[1]){
        case "static":
            b->add(sprintf(pop_static_template, basename(file[..<3]),
                            (int)line[2]));
            break;
        case "local":
            b->add(sprintf(pop_segment_template, "LCL", (int)line[2]));
            break;
        case "argument":
            b->add(sprintf(pop_segment_template, "ARG", (int)line[2]));
            break;
        case "this":
            b->add(sprintf(pop_segment_template, "THIS", (int)line[2]));
            break;
        case "that":
            b->add(sprintf(pop_segment_template, "THAT", (int)line[2]));
            break;
        case "temp":
            b->add(sprintf(pop_temp_template, (int)line[2]));
            break;
        case "pointer":
            int i = (int) line[2];
            string key;
            if (i == 0)
                key = "THIS";
            else if (i == 1)
                key = "THAT";
            else
            {
                syntax_err(file, n, "Invalid pointer index: %d\n", i);
            }
            b->add(sprintf(pop_pointer_template, key));
            break;
        default:
            syntax_err(file, n, "Invalid pop segment: %s\n", line[1]);
    }
}

void handle_command(array(string) line, string file, int n,
                        string template, mixed ...args)
{
    if (sizeof(line) != 1)
    {
        syntax_err(file, n, "Too many arguments: %d\n", sizeof(line) - 1);
    }
    b->add(sprintf(template, @args));
}

void handle_line(array(string) line, string file, int n)
{
    switch(line[0])
    {
        case "push":
            handle_push_command(line, file, n);
            break;
        case "pop":
            handle_pop_command(line, file, n);
            break;
        case "add":
            handle_command(line, file, n, arithmetic_2_template, "+");
            break;
        case "sub":
            handle_command(line, file, n, arithmetic_2_template, "-");
            break;
        case "and":
            handle_command(line, file, n, arithmetic_2_template, "&");
            break;
        case "or":
            handle_command(line, file, n, arithmetic_2_template, "|");
            break;
        case "neg":
            handle_command(line, file, n, arithmetic_1_template, "-");
            break;
        case "not":
            handle_command(line, file, n, arithmetic_1_template, "!");
            break;
        case "eq":
            id++;
            handle_command(line, file, n, comp_template, id, "JEQ", id, id, id);
            break;
        case "gt":
            id++;
            handle_command(line, file, n, comp_template, id, "JGT", id, id, id);
            break;
        case "lt":
            id++;
            handle_command(line, file, n, comp_template, id, "JLT", id, id, id);
            break;
        default:
            exit(1, "%s:%d  Invalid command: %s\n", file, n, line[0]);
    }
}

void handle_file(string file)
{
    Stdio.File f = Stdio.File();
    if (!f->open(file, "r"))
    {
        werror("Failed to open: %s (%s)\n", file, strerror(f->errno()));
        return;
    }

    foreach(f->line_iterator(); int n; string line)
    {
        line = String.normalize_space(line);
        line = String.trim_all_whites(line);

        if (has_prefix(line, "//"))
            continue;

        if (!sizeof(line))
            continue;

        line = (line / "//")[0];
        line = String.trim_all_whites(line);
        array(string) split = line / " ";

        if (!sizeof(split))
            continue;

        handle_line(split, file, n);
    }
}

int main(int c, array v)
{
    array(string) files = ({ });

    if (c < 2)
        exit(1, "./vm_translator.pike [filename|directory]\n");

    string path = v[1];
    b = Stdio.Buffer();
    bool dir = false;

    if (Stdio.is_file(path))
    {
        files = ({ path });
    }
    else if (Stdio.is_dir(path))
    {
        dir = true;
        files = get_dir(path);
    }
    else
        exit(1, "%s doesn't exist\n", path);

    foreach (files, string file)
    {
        if (has_suffix(file, ".vm"))
        {
            if (dir)
                handle_file(combine_path(path, file));
            else
                handle_file(path);
        }
    }

    write("%s", b->read());

    return 0;
}
