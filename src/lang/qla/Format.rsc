module lang::qla::Format

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


