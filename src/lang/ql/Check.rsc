module lang::ql::Check


import lang::ql::QL;
import lang::ql::Types;
import lang::ql::Resolve;
import Message;
import ParseTree;
import IO;
import Relation;
import Set;

set[Message] checkForm(Form f, Refs refs) = tc(f, refs); // + detectCycles(f);

//set[str] uses(Question q) = { "<x>" | /(Expr)`<Id x>` := q };
//  
//set[str] defs(Question q) = { "<x>" | /Var x := q };

//set[Message] detectCycles(Form f) 
//  = { error("Cycle involving <x>", f.name@\loc) | x <- carrier(g), <x, x> in g }
//  when g := ( {} | it + defs(q) * uses(q) | q <- flatten(f) )+;

set[Message] tc(Form f, Refs r) = ( {} | it + tc(q, r) | q <- f.questions );

set[Message] tc((Question)`if (<Expr c>) <Question q>`, Refs r) = checkCond(c, r) + tc(q, r);

set[Message] tc((Question)`if (<Expr c>) <Question q1> else <Question q2>`, Refs r)
  = checkCond(c, r) + tc(q1, r) + tc(q2, r);

set[Message] tc((Question)`{ <Question* qs> }`, Refs r) 
  = ( {} | it + tc(q, r) |  q <- qs );

set[QLType] declaredTypes(str x, Refs r) = x in r.def ? r.def[x]<1> : {};
bool hasMultipleTypes(str x, Refs r) = size(declaredTypes(x, r)) > 1;
bool hasDuplicateLabel(str l, Refs r) = size(r.labels[l]) > 1;

set[Message] tcq(Question q, Refs r)
  = { error("Redeclared with different type", q@\loc) | hasMultipleTypes("<q.name>", r) }
  + { warning("Duplicate label", q.label@\loc) | hasDuplicateLabel("<q.label>", r) }
  ;

set[Message] tc(q:(Question)`<Label l> <Var n>: <Type t> = <Expr e>`, Refs r)
  = tcq(q, r) + tc(e ,r);

set[Message] tc(q:(Question)`<Label l> <Var n>: <Type t>`, Refs r)  
  = tcq(q, r); 

default set[Message] tc(Question q, Refs r) = {};

set[Message] checkCond(Expr c, Refs r) 
   = { error("Condition should be boolean", c@\loc) | qlTypeOf(c, r) != boolean() }
   + tc(c, r);

default set[Message] tc(Expr _, Refs r) = {};

bool hasDeclaration(Id x, Refs r) = r.use[x@\loc]() != {};

set[Message] tc(e:(Expr)`<Id x>`, Refs r) 
  = {error("Undefined name", e@\loc) | !hasDeclaration(x, r) }; 
  
set[Message] tc((Expr)`(<Expr e>)`, Refs r) = tc(e, r);
set[Message] tc(n:(Expr)`!<Expr e>`, Refs r) = tc(n, checkBoolean, r, e);
set[Message] tc(e:(Expr)`<Expr lhs> * <Expr rhs>`, Refs r) = tc(e, checkNumeric, r, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> / <Expr rhs>`, Refs r) = tc(e, checkNumeric, r, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> + <Expr rhs>`, Refs r) = tc(e, checkNumeric, r, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> - <Expr rhs>`, Refs r) = tc(e, checkNumeric, r, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> \> <Expr rhs>`, Refs r) = tc(e, checkNumeric, r, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> \>= <Expr rhs>`, Refs r) = tc(e, checkNumeric, r, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> \< <Expr rhs>`, Refs r) = tc(e, checkNumeric, r, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> \<= <Expr rhs>`, Refs r) = tc(e, checkNumeric, r, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> == <Expr rhs>`, Refs r) = tc(e, checkEq, r, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> != <Expr rhs>`, Refs r) = tc(e, checkEq, r, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> && <Expr rhs>`, Refs r) = tc(e, checkBoolean, r, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> || <Expr rhs>`, Refs r) = tc(e, checkBoolean, r, lhs, rhs);

/*
 * Helper function to do automatic calling of tc on sub-expressions
 * and to prevent type-checking if the sub-expressions can't be typed.
 */

set[Message] tc(Expr e, set[Message](list[QLType], loc) check, Refs r, Expr kids...) {
  ts = [ qlTypeOf(k, r) | k <- kids ];
  errs = ( {} | it + tc(k, r) | k <- kids );
  if (bottom() notin ts) {
    errs += check(ts, e@\loc);
  }
  return errs;
}

set[Message] checkBoolean(list[QLType] ts, loc l)  
  = ( true | it && boolean() !:= t | t <- ts )
  ? { error("Expression should have boolean type", l) }
  : {}; 

set[Message] checkNumeric(list[QLType] ts, loc l)  
  = ( true | it && (integer() := t || money() := t) | t <- ts )
  ? {}
  : { error("Expression should have numeric type", l) }; 

set[Message] checkString(list[QLType] ts, loc l)  
  = ( true | it && string() !:= t | t <- ts ) 
  ? { error("Expression should have string type", l) } 
  : {}; 

set[Message] checkEq(list[QLType] ts, loc l) 
  = { error("Incomparable types", l) | ts[0] != ts[1] }; 

default QLType qlTypeOf(Expr _, Refs r) = QLType::bottom();
  
QLType qlTypeOf(e:(Expr)`<Id x>`, Refs r) = t 
  when {QLType t} := declaredTypes("<x>", r);
   
QLType qlTypeOf((Expr)`(<Expr e>)`, Refs r) = qlTypeOf(e);
QLType qlTypeOf((Expr)`<Integer _>`, Refs r) = integer();
QLType qlTypeOf((Expr)`true`, Refs r) = boolean();
QLType qlTypeOf((Expr)`false`, Refs r) = boolean();
QLType qlTypeOf((Expr)`<String _>`, Refs r) = string();
QLType qlTypeOf(n:(Expr)`!<Expr e>`, Refs r) = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> * <Expr rhs>`, Refs r) = lub(qlTypeOf(lhs), qlTypeOf(rhs));
QLType qlTypeOf(e:(Expr)`<Expr lhs> / <Expr rhs>`, Refs r) = lub(qlTypeOf(lhs), qlTypeOf(rhs));
QLType qlTypeOf(e:(Expr)`<Expr lhs> + <Expr rhs>`, Refs r) = lub(qlTypeOf(lhs), qlTypeOf(rhs));
QLType qlTypeOf(e:(Expr)`<Expr lhs> - <Expr rhs>`, Refs r) = lub(qlTypeOf(lhs), qlTypeOf(rhs));
QLType qlTypeOf(e:(Expr)`<Expr lhs> \> <Expr rhs>`, Refs r) = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> \>= <Expr rhs>`, Refs r) = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> \< <Expr rhs>`, Refs r) = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> \<= <Expr rhs>`, Refs r) = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> == <Expr rhs>`, Refs r) = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> != <Expr rhs>`, Refs r) = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> && <Expr rhs>`, Refs r) = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> || <Expr rhs>`, Refs r) = boolean();


QLType lub(money(), QLType::integer()) = money();
QLType lub(QLType::integer(), money()) = money();
QLType lub(QLType t1, QLType t2) = t1 when t1 == t2;
default QLType lub(QLType t1, QLType t2) = bottom();
