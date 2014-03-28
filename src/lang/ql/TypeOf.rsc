module lang::ql::TypeOf

import lang::ql::Types;
import lang::ql::QL;
import lang::ql::Resolve;

set[QLType] declaredTypes(str x, Refs r) = x in r.def ? r.def[x]<1> : {}; 
 
QLType qlTypeOf(e:(Expr)`<Id x>`, Refs r) = t 
  when {QLType t} := declaredTypes("<x>", r);
   
QLType qlTypeOf((Expr)`(<Expr e>)`, Refs r) = qlTypeOf(e, r);
QLType qlTypeOf((Expr)`<Integer _>`, Refs r) = integer();
QLType qlTypeOf((Expr)`true`, Refs r) = boolean();
QLType qlTypeOf((Expr)`false`, Refs r) = boolean();
QLType qlTypeOf((Expr)`<String _>`, Refs r) = string();
QLType qlTypeOf(n:(Expr)`!<Expr e>`, Refs r) = boolean();

QLType qlTypeOf(e:(Expr)`<Expr lhs> * <Expr rhs>`, Refs r)
  = combine(qlTypeOf(lhs, r), qlTypeOf(rhs, r));

QLType qlTypeOf(e:(Expr)`<Expr lhs> / <Expr rhs>`, Refs r)
  = combine(qlTypeOf(lhs, r), qlTypeOf(rhs, r));

QLType qlTypeOf(e:(Expr)`<Expr lhs> + <Expr rhs>`, Refs r)
  = combine(qlTypeOf(lhs, r), qlTypeOf(rhs, r));
  
QLType qlTypeOf(e:(Expr)`<Expr lhs> - <Expr rhs>`, Refs r)
  = combine(qlTypeOf(lhs, r), qlTypeOf(rhs, r));
  
QLType qlTypeOf(e:(Expr)`<Expr lhs> \> <Expr rhs>`, Refs r)  = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> \>= <Expr rhs>`, Refs r) = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> \< <Expr rhs>`, Refs r)  = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> \<= <Expr rhs>`, Refs r) = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> == <Expr rhs>`, Refs r)  = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> != <Expr rhs>`, Refs r)  = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> && <Expr rhs>`, Refs r)  = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> || <Expr rhs>`, Refs r)  = boolean();

default QLType qlTypeOf(Expr _, Refs r) = QLType::error();
