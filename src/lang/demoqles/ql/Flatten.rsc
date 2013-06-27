module lang::demoqles::ql::Flatten

import lang::demoqles::ql::QL;
import ParseTree; // apparently needed
import IO;

//Form normalize((Form)`form <Id n> { <Question* body> }`) {
//  f = (Form)`form <Id n> { if (true) { <Question* body> } }`; 
//  println("Normalizing");
//  bprintln(f);
//  solve (f) {
//   f = top-down visit (f) {
//    case x:(Question)`if (<Expr c>) {<Question q> <Question* qs>}` 
//      => (Question)`{if (<Expr c>) <Question q> if (<Expr c>) {<Question* qs>}}`
//      when bprintln("Dist if"), bprintln(x)
//      
//    case x:(Question)`if (<Expr c>) {}`
//      => (Question)`{}`
//      when bprintln("Void if"), bprintln(x)
//
//    case x:(Question)`if (<Expr c>) <Question q1> else <Question q2>`
//      => (Question)`{if (<Expr c>) <Question q1> if (!<Expr c>) <Question q2>}`
//      when bprintln("Remove else"), bprintln(x)
//
//    case x:(Question)`if (<Expr c1>) if (<Expr c2>) <Question q>` 
//      => (Question)`if (<Expr c1> && <Expr c2>) <Question q>`
//      when bprintln("Unnest if"), bprintln(x)
//      
//    case (Question)`{<Question* qs1> {<Question* qs>} <Question* qs2>}`
//      => (Question)`{<Question* qs1> <Question* qs> <Question* qs2>}`
//      
//      
//    case x:(Form)`form <Id n> {<Question* qs1> {<Question* qs>} <Question* qs2>}`
//      => (Form)`form <Id n> {<Question* qs1> <Question* qs> <Question* qs2>}`
//   }
//  }
//  println("Normalized");
//  bprintln(f);
//  return f;
//} 


list[Question] flatten(Form f) 
  = ( [] | it + flatten(q, (Expr)`true`) | q <- f.questions );

list[Question] flatten((Question)`if (<Expr c1>) <Question q>`, Expr c2)
  = flatten(q, (Expr)`<Expr c2> && <Expr c1>`);

list[Question] flatten((Question)`if (<Expr c1>) <Question q1> else <Question q2>`, Expr c2)
  = flatten(q1, (Expr)`<Expr c2> && <Expr c1>`)
  + flatten(q2, (Expr)`<Expr c2> && !(<Expr c1>)`);

list[Question] flatten((Question)`{<Question* qs>}`, Expr c)
  = ( [] | it + flatten(q, c) | q <- qs );

list[Question] flatten(q:(Question)`<Label l> <Var v>: <Type t>`, Expr c)
  = [(Question)`if (<Expr c>) <Question q>`];

list[Question] flatten(q:(Question)`<Label l> <Var v>: <Type t> = <Expr e>`, Expr c)
  = [(Question)`if (<Expr c>) <Question q>`];

