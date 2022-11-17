module args;

import errors;

import std.file;

struct Args {
    string fileName;
    this(string[] args) {
        switch (args.length) {
            case 0:
            case 1:
                fileName = null;
                break;
            case 2:
                if (args[1].exists && args[1].isFile)
                    fileName = args[1];
                else
                    throw new InterpreterFileError("No such file: " ~ args[1]);
                break;
            default:
                throw new InterpreterArgError("Too many arguments");
        }
    }
}
