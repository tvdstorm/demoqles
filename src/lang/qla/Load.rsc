module lang::qla::Load

import lang::qla::Parse;
import lang::qla::AST;
import ParseTree;

Form load(loc l) = implodeQL(parseQL(l));
Form load(str src) = implodeQL(parseQL(src));

Form implodeQL(Tree f) = implode(#Form, f);