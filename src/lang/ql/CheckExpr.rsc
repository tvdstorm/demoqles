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
// and to prevent type-checking if the sub-expressions have errors.
set[Message] tc(Expr e, QLType mgt, Info i, Expr kids...) {
  errs = ( {} | it + tc(k, i) | k <- kids );
  if (errs == {}) {
    return {error("Invalid operand type (expected <type2str(mgt)>)", k@\loc)
               | k <- kids, !compatible(qlTypeOf(k, i), mgt) };
  }
  return errs;
}

set[Message] checkEq(Expr e, Info i, Expr lhs, Expr rhs) {
  errs = ( {} | it + tc(k, i) | k <- kids );
  if (errs == {}, !compatible(qlTypeOf(lhs, i), qlTypeOf(rhs, i))) {
    return {error("Incompatible types", e@\loc)};
  }
  return errs;
}

set[Message] tc(e:(Expr)`<Id x>`, Info i) = {error("Undefined name", e@\loc)}
  when i.refs.use[x@\loc] == {}; 

set[Message] tc(e:(Expr)`<Expr lhs> == <Expr rhs>`, Info i)  = checkEq(e, i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> != <Expr rhs>`, Info i)  = checkEq(e, i, lhs, rhs);

  
set[Message] tc((Expr)`(<Expr e>)`, Info i) = tc(e, i);
set[Message] tc(n:(Expr)`!<Expr e>`, Info i)                 = tc(n, boolean(), i, e);
set[Message] tc(e:(Expr)`<Expr lhs> * <Expr rhs>`, Info i)   = tc(e, numeric(), i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> / <Expr rhs>`, Info i)   = tc(e, numeric(), i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> + <Expr rhs>`, Info i)   = tc(e, numeric(), i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> - <Expr rhs>`, Info i)   = tc(e, numeric(), i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> \> <Expr rhs>`, Info i)  = tc(e, numeric(), i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> \>= <Expr rhs>`, Info i) = tc(e, numeric(), i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> \< <Expr rhs>`, Info i)  = tc(e, numeric(), i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> \<= <Expr rhs>`, Info i) = tc(e, numeric(), i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> && <Expr rhs>`, Info i)  = tc(e, boolean(), i, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> || <Expr rhs>`, Info i)  = tc(e, boolean(), i, lhs, rhs);

default set[Message] tc(Expr _, Info i) = {}; 


