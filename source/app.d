module app;

import args;
import exec;
import repl;

void main(string[] argv) {
    auto parsedArgs = Args(argv);

    if (parsedArgs.fileName)
        execFile(parsedArgs.fileName);
    else
        runRepl();
}
