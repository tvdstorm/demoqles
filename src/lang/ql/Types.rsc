module lang::ql::Types

import lang::ql::QL;
import Node;

data QLType
  = integer()
  | boolean()
  | money()
  | string()
  | error()
  ;
  
QLType qlType((Type)`boolean`) = boolean();
QLType qlType((Type)`string`) = string();
QLType qlType((Type)`integer`) = integer();
QLType qlType((Type)`money`) = money();
  
str type2str(QLType t) = getName(t);

QLType combine(money(), QLType::integer()) = money();
QLType combine(QLType::integer(), money()) = money();
QLType combine(QLType t1, QLType t2) = t1 when t1 == t2;
default QLType combine(QLType t1, QLType t2) = error();
