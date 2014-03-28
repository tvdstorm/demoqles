module lang::ql::Check


import lang::ql::QL;
import lang::ql::Types;
import lang::ql::TypeOf;
import lang::ql::Resolve;
import lang::ql::CheckExpr;
import Message;
import ParseTree;
import Relation;
import Set;

bool hasMultipleTypes(Id x, Refs r) = size(declaredTypes(x, r)) > 1;
bool hasDuplicateLabel(Label l, Refs r) = size(r.labels[l]) > 1;

set[Message] checkForm(Form f, Refs refs) = tc(f, refs); // + detectCycles(f);

set[Message] tc(Form f, Refs r) = ( {} | it + tc(q, r) | q <- f.questions );

set[Message] tc((Question)`if (<Expr c>) <Question q>`, Refs r) = checkCond(c, r) + tc(q, r);

set[Message] tc((Question)`if (<Expr c>) <Question q1> else <Question q2>`, Refs r)
  = checkCond(c, r) + tc(q1, r) + tc(q2, r);

set[Message] tc((Question)`{ <Question* qs> }`, Refs r) 
  = ( {} | it + tc(q, r) |  q <- qs );

set[Message] tcq(Label l, Id n, Refs r)
  = { error("Redeclared with different type", n@\loc) | hasMultipleTypes(n, r) }
  + { warning("Duplicate label", l@\loc) | hasDuplicateLabel(l, r) }
  ;

set[Message] tc(q:(Question)`<Label l> <Id n>: <Type t> = <Expr e>`, Refs r)
  = tcq(l, n, r) + tc(e ,r);

set[Message] tc(q:(Question)`<Label l> <Id n>: <Type t>`, Refs r)  
  = tcq(l, n, r); 

default set[Message] tc(Question q, Refs r) = {};

set[Message] checkCond(Expr c, Refs r) 
   = { error("Condition should be boolean", c@\loc) | qlTypeOf(c, r) != boolean() }
   + tc(c, r);


//set[str] uses(Question q) = { "<x>" | /(Expr)`<Id x>` := q };
//  
//set[str] defs(Question q) = { "<x>" | /Var x := q };

//set[Message] detectCycles(Form f) 
//  = { error("Cycle involving <x>", f.name@\loc) | x <- carrier(g), <x, x> in g }
//  when g := ( {} | it + defs(q) * uses(q) | q <- flatten(f) )+;
