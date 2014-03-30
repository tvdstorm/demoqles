module lang::ql::Types

import lang::ql::QL;
import Node;

data QLType
  = integer()
  | boolean()
  | money()
  | string()
  | numeric()
  | error()
  ;
  
QLType qlType((Type)`boolean`) = boolean();
QLType qlType((Type)`string`)  = string();
QLType qlType((Type)`integer`) = integer();
QLType qlType((Type)`money`)   = money();
  
str type2str(QLType t) = getName(t);

QLType lub(money(), QLType::integer()) = numeric();
QLType lub(QLType::integer(), money()) = numeric();
QLType lub(QLType t1, QLType t2) = t1 when t1 == t2;
default QLType lub(QLType t1, QLType t2) = error();

bool compatible(QLType t1, QLType t2) = true when t1 == t2;
bool compatible(QLType::integer(), money()) = true;
bool compatible(money(), QLType::integer()) = true;
bool compatible(QLType::integer(), numeric()) = true;
bool compatible(numeric(), QLType::integer()) = true;
bool compatible(money(), numeric()) = true;
bool compatible(numeric(), money()) = true;
default bool compatible(QLType t1, QLType t2) = false;
