module lang::ql::TypeOf

import lang::ql::Types;
import lang::ql::QL;
import lang::ql::Resolve;
import ParseTree;

QLType numeric(Expr lhs, Expr rhs, Info i)
  = lub(qlTypeOf(lhs, i), qlTypeOf(rhs, i));

QLType qlTypeOf(e:(Expr)`<Id x>`, Info i) = t 
  when
    d <- i.refs.use[x@\loc], 
    t <- i.refs.def[d];  
   
QLType qlTypeOf((Expr)`(<Expr e>)`, Info i) = qlTypeOf(e, i);
QLType qlTypeOf((Expr)`<Integer _>`, Info i) = integer();
QLType qlTypeOf((Expr)`true`, Info i) = boolean();
QLType qlTypeOf((Expr)`false`, Info i) = boolean();
QLType qlTypeOf((Expr)`<String _>`, Info i) = string();
QLType qlTypeOf(n:(Expr)`!<Expr e>`, Info i) = boolean();

QLType qlTypeOf(e:(Expr)`<Expr lhs> * <Expr rhs>`, Info i) = numeric(lhs, ihs, i);
QLType qlTypeOf(e:(Expr)`<Expr lhs> / <Expr rhs>`, Info i) = numeric(lhs, ihs, i);
QLType qlTypeOf(e:(Expr)`<Expr lhs> + <Expr rhs>`, Info i) = numeric(lhs, ihs, i);
QLType qlTypeOf(e:(Expr)`<Expr lhs> - <Expr rhs>`, Info i) = numeric(lhs, ihs, i);
  
QLType qlTypeOf(e:(Expr)`<Expr lhs> \> <Expr rhs>`, Info i)  = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> \>= <Expr rhs>`, Info i) = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> \< <Expr rhs>`, Info i)  = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> \<= <Expr rhs>`, Info i) = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> == <Expr rhs>`, Info i)  = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> != <Expr rhs>`, Info i)  = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> && <Expr rhs>`, Info i)  = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> || <Expr rhs>`, Info i)  = boolean();

default QLType qlTypeOf(Expr _, Info i) = QLType::error();
