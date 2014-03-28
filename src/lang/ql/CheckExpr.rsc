module lang::ql::CheckExpr

import lang::ql::QL;
import lang::ql::Types;
import lang::ql::Resolve;

import Message;
import ParseTree;
import Relation;
import Set;

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
  = { error("Expression should have boolean type", l) | any(t <- ts, t != boolean()) };  

set[Message] checkNumeric(list[QLType] ts, loc l)  
  = { error("Expression should have numeric type", l) | any(t <- ts, t != money(), t != integer()) }; 

set[Message] checkString(list[QLType] ts, loc l)  
  = { error("Expression should have string type", l) | any(t <- ts, t != string()) }; 

set[Message] checkEq(list[QLType] ts, loc l) 
  = { error("Incomparable types", l) | ts[0] != ts[1] }; 

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

default set[Message] tc(Expr _, Refs r) = {};

