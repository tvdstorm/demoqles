module lang::qla::Parse

import lang::qla::QL;
import util::Explode;
import ParseTree;
import util::Brackets;
import lang::rascal::grammar::definition::Priorities;


Tree parseQL(loc l) = parse(#Form, l);
Tree parseQL(str src) = parse(#Form, src);
Tree parseQL(str src, loc l) = parse(#Form, src, l);
Form explode(node n) = explode(#Form, n);

DoNotNest qlPriorities() = prioritiesOf(#Form);
