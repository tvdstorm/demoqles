module lang::qla::Format

import util::Box;
import lang::qla::AST;
import Node;
import lang::qla::FormatExpr;

Box format(form(x, qs))
  = V(H("form", x, "{", hs=1),
      I(formatList(qs)),
      "}"
    );
      

Box format(question(l, x, t))
  = H(l, H(x.name, ":"), getName(t), hs = 1);

Box format(computed(l, x, t, e))
  = H(l, H(x.name, ":"), getName(t), "=", format(e), hs = 1);
      

Box format(group(qs)) = V("{", I([format(q) | q <- qs]), "}");

Box format(ifThen(e, q)) 
  = H("if", H("(", format(e), ")"), format(q), hs=1);

      
list[Box] formatList(list[Question] qs)
  = [ format(q) | q <- qs ];