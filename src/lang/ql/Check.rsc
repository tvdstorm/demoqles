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

set[Message] checkForm(Form f, Info i) = tc(f, i); // + detectCycles(f);

set[Message] tc(Form f, Info i) = ( {} | it + tc(q, i) | q <- f.questions );

set[Message] tci(Expr c, Info i) 
  = { error("Condition should be boolean", c@\loc) | qlTypeOf(c, i) != boolean() }
  + tc(c, i);

set[Message] tc((Question)`if (<Expr c>) <Question q>`, Info i) 
  = tci(c, i) + tc(q, i);

set[Message] tc((Question)`if (<Expr c>) <Question q1> else <Question q2>`, Info i)
  = tci(c, i) + tc(q1, i) + tc(q2, i);

set[Message] tc((Question)`{ <Question* qs> }`, Info i) 
  = ( {} | it + tc(q, i) |  q <- qs );

set[Message] tcq(Label l, Id n, Info i)
  = { error("Redeclared with different type", n@\loc) | hasMultipleTypes(n@\loc, i) }
  + { warning("Duplicate label", l@\loc) | hasDuplicateLabel(l, i) }
  ;

set[Message] tc(q:(Question)`<Label l> <Id n>: <Type t> = <Expr e>`, Info i)
  = tcq(l, n, i) + tc(e ,i);

set[Message] tc(q:(Question)`<Label l> <Id n>: <Type t>`, Info i)  
  = tcq(l, n, i); 

default set[Message] tc(Question q, Info i) = {};

bool hasMultipleTypes(loc x, Info i) = size(i.refs.def[x]) > 1;

bool hasDuplicateLabel(Label l, Info i) = size(i.labels[l]) > 1;


//set[str] uses(Question q) = { "<x>" | /(Expr)`<Id x>` := q };
//  
//set[str] defs(Question q) = { "<x>" | /Var x := q };

//set[Message] detectCycles(Form f) 
//  = { error("Cycle involving <x>", f.name@\loc) | x <- carrier(g), <x, x> in g }
//  when g := ( {} | it + defs(q) * uses(q) | q <- flatten(f) )+;
