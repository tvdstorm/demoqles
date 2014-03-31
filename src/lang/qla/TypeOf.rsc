module lang::qla::TypeOf

import lang::qla::AST;
import lang::qla::Resolve;

// Extend with numeric and error
data Type = numeric() | error();
  
str type2str(Type t) = getName(t);

Type lub(Type::money(), Type::integer()) = numeric();
Type lub(Type::integer(), Type::money()) = numeric();
Type lub(Type t1, Type t2) = t1 when t1 == t2;
default Type lub(Type t1, Type t2) = error();

bool compatible(Type t1, Type t2) = true when t1 == t2;
bool compatible(Type::integer(), Type::money()) = true;
bool compatible(Type::money(), Type::integer()) = true;
bool compatible(Type::integer(), Type::numeric()) = true;
bool compatible(Type::numeric(), Type::integer()) = true;
bool compatible(Type::money(), Type::numeric()) = true;
bool compatible(Type::numeric(), Type::money()) = true;
default bool compatible(Type t1, Type t2) = false;


Type numeric(Expr lhs, Expr rhs, Info i)
  = lub(typeOf(lhs, i), typeOf(rhs, i));

Type typeOf(var(x), Info i) = t 
  when
    d <- i.refs.use[x@location], t <- i.refs.def[d];  
   
Type typeOf(Expr::integer(_), Info i) = integer();
Type typeOf(\true(), Info i) = boolean();
Type typeOf(\false(), Info i) = boolean();
Type typeOf(Expr::\string(_), Info i) = string();
Type typeOf(not(_), Info i) = boolean();

Type typeOf(mul(lhs, rhs), Info i) = numeric(lhs, rhs, i);
Type typeOf(div(lhs, rhs), Info i) = numeric(lhs, rhs, i);
Type typeOf(add(lhs, rhs), Info i) = numeric(lhs, rhs, i);
Type typeOf(sub(lhs, rhs), Info i) = numeric(lhs, rhs, i);
  
Type typeOf(gt(_, _), Info i)  = boolean();
Type typeOf(lt(_, _), Info i)  = boolean();
Type typeOf(leq(_, _), Info i) = boolean();
Type typeOf(geq(_, _), Info i) = boolean();
Type typeOf(eq(_, _), Info i)  = boolean();
Type typeOf(neq(_, _), Info i) = boolean();
Type typeOf(and(_, _), Info i) = boolean();
Type typeOf(or(_, _), Info i)  = boolean();

default Type typeOf(Expr _, Info i) = error();
