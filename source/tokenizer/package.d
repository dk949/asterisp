module tokenizer;

import tokenizer.token;
import tokenizer.tokenizer;
public import tokenizer.token: TokenType, Token;

Token[] tokenize(string chars) {
    return Tokenizer(chars).run;
}
