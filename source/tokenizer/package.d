module tokenizer;

import tokenizer.tokenizer;

public import tokenizer.token: TokenType, Token;
public import tokenizer.location: Loc;

Token[] tokenize(string chars, string filename) {
    return Tokenizer(chars, filename).run;
}
