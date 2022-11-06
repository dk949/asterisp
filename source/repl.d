module repl;
import std.stdio;

import repl;
import errors;
import eval: eval;
import parser;
import types;

void runRepl(string prompt = "*> ") {
    while (true) {
        write(prompt);
        auto line = stdin.readln;
        if (line == "exit\n")
            break;
        try {
            line
                .tokenize
                .parse
                .eval
                .writeln;
        } catch (SyntaxError e) {
            stderr.writeln("SyntaxError: ", e.message);
        } catch (ArgumentError e) {
            stderr.writeln("ArgumentError: ", e.message);
        } catch (TypeError e) {
            stderr.writeln("TypeError: ", e.message);
        } catch (VariableError e) {
            stderr.writeln("VariableError: ", e.message);
        } catch (InterpreterError e) {
            stderr.writeln("InterpreterError: ", e.message);
        }
    }
}
