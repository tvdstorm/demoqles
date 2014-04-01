module lang::qla::Format

import lang::qla::Priorities;
import lang::qla::AST;
import List;
import IO;

str format(f:form(n, qs)) = "form <n> {
                            '  <withComments(2, f@comments, qs)>
                            '}";

str format(question(l, n, t))
  = "<l> <n.name>: <format(t)>";

str format(computed(l, n, t, e))
  = "<l> <n.name>: <format(t)> = (<format(e)>)";
  
str format(ifThen(c, q))
  = "if (<format(c)>) <formatB(q)>";
  

str format(ifThenElse(c, q1, q2))
  = "if (<format(c)>) <formatB(q1)>
    'else <formatB(q2)>";

str format(g:group(qs))  
  = "{ 
    '  <withComments(0, g@comments, qs)>
    '}";

str withComments(int offset, map[int,list[str]] cs, list[Question] qs) {
  result = "";
  println("Comments:");
  iprintln(cs);
  for (i <- [0..size(qs)]) {
    if (i + offset in cs) {
      result += intercalate("\n", cs[i+offset]) + "\n";
    }
    result += format(qs[i]) + "\n";
  }
  return result;
}
  
str formatB(g:group(qs)) = format(g);
default str formatB(Question q) = format(group([q])); 

str format(Expr::integer(n)) = "<n>";
str format(Expr::string(s)) = s;
str format(Expr::money(n)) = "<n>";
str format(\true()) = "true";
str format(\false()) = "false";

str format(var(x)) = x.name;
str format(e:not(x)) = "!<formatP(e,x)>";
str format(e:add(x, y)) = "<formatP(e,x)> + <formatP(e, y)>";
str format(e:sub(x, y)) = "<formatP(e,x)> - <formatP(e, y)>";
str format(e:mul(x, y)) = "<formatP(e,x)> * <formatP(e, y)>";
str format(e:div(x, y)) = "<formatP(e,x)> / <formatP(e, y)>";
str format(e:and(x, y)) = "<formatP(e,x)> && <formatP(e, y)>";
str format(e:or(x, y)) = "<formatP(e,x)> || <formatP(e, y)>";
str format(e:eq(x, y)) = "<formatP(e,x)> == <formatP(e, y)>";
str format(e:neq(x, y)) = "<formatP(e,x)> != <formatP(e, y)>";
str format(e:lt(x, y)) = "<formatP(e,x)> \< <formatP(e, y)>";
str format(e:gt(x, y)) = "<formatP(e,x)> \> <formatP(e, y)>";
str format(e:leq(x, y)) = "<formatP(e,x)> \<= <formatP(e, y)>";
str format(e:geq(x, y)) = "<formatP(e,x)> \>= <formatP(e, y)>";


str format(QType::boolean()) = "boolean";
str format(QType::integer()) = "integer";
str format(QType::money()) = "money";
str format(QType::string()) = "string";

 
str parenizer(str x) = "(<x>)";

str parens(node parent, node kid, str x)
  = parens(qlPriorities(), parent, kid, x, parenizer);

str formatP(Expr parent, Expr kid)
  = parens(parent, kid, format(kid));

 