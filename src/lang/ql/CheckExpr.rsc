module lang::ql::CheckExpr

import lang::ql::QL;
import lang::ql::Types;
import lang::ql::TypeOf;
import lang::ql::Resolve;

import Message;
import ParseTree;
import Relation;
import Set;

//Helper function to do automatic calling of tc on sub-expressions
// and to prevent type-checking if the sub-expressions can't be typed.
set[Message] tc(Expr e, set[Message](list[QLType], loc) check, Info i, Expr kids...) {
  ts = [ qlTypeOf(k, i) | k <- kids ];
  errs = ( {} | it + tc(k, i) | k <- kids );
  if (error() notin ts) {
    errs += check(ts, e@\loc);
  }
  return errs;
}

set[Message] checkBoolean(list[QLType] ts, loc l)
  = {error("Expression should have boolean type", l)}
  when any(t <- ts, t != boolean());  

set[Message] checkNumeric(list[QLType] ts, loc l)  
  = {error("Expression should have numeric type", l)} 
  when any(t <- ts, t != money(), t != integer()); 

set[Message] checkEquals(list[QLType] ts, loc l) = {error("Incomparable types", l)}
  when any(t1 <- ts, t2 <- ts, t1 != t2); 

set[Message] tc(e:(Expr)`<Id x>`, Info i) = {error("Undefined name", e@\loc)}
  when i.refs.use[x@\loc] == {}; 
  
set[Message] tc((Expr)`(<Expr e>)`, Info i) = tc(e, i);
set[Message] tc(n:(Expr)`!<Expr e>`, Info i) = tc(n, checkBoolean, i, e);
set[Message] tc(e:(Expr)`<Expr lhs> * <Expr rhs>`, Info i)   = tc(e, checkNumeric, i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> / <Expr rhs>`, Info i)   = tc(e, checkNumeric, i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> + <Expr rhs>`, Info i)   = tc(e, checkNumeric, i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> - <Expr rhs>`, Info i)   = tc(e, checkNumeric, i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> \> <Expr rhs>`, Info i)  = tc(e, checkNumeric, i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> \>= <Expr rhs>`, Info i) = tc(e, checkNumeric, i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> \< <Expr rhs>`, Info i)  = tc(e, checkNumeric, i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> \<= <Expr rhs>`, Info i) = tc(e, checkNumeric, i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> == <Expr rhs>`, Info i)  = tc(e, checkEquals, i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> != <Expr rhs>`, Info i)  = tc(e, checkEquals, i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> && <Expr rhs>`, Info i)  = tc(e, checkBoolean, i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> || <Expr rhs>`, Info i)  = tc(e, checkBoolean, i, lhs, rhs);

default set[Message] tc(Expr _, Info i) = {}; 


