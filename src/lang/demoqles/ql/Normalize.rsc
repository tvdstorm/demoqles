module lang::demoqles::ql::Normalize

import lang::demoqles::ql::QL;
import ParseTree; // apparently needed
import IO;

/*

Form normalize((Form)`form <Id n> { <Question* body> }`) {
  f = (Form)`form <Id n> { if (true) { <Question* body> } }`; 
  solve (f) {
   f = visit (f) {
    case (Question)`if (<Expr c>) {<Question q> <Question* qs>}` 
      => (Question)`{if (<Expr c>) <Question q> if (<Expr c>) {<Question* qs>}}`
    case (Question)`if (<Expr c>) {}`
      => (Question)`{}`
    case (Question)`if (<Expr c>) <Question q1> else <Question q2>`
      => (Question)`{if (<Expr c>) <Question q1> if (!<Expr c>) <Question q2>}`
    case (Question)`if (<Expr c1>) if (<Expr c2>) <Question q>` 
      => (Question)`if (<Expr c1> && <Expr c2>) <Question q>`
    case (Question)`{<Question* qs1> {<Question* qs>} <Question* qs2>}`
      => (Question)`{<Question* qs1> <Question* qs> <Question* qs2>}`
    case (Form)`form <Id n> {<Question* qs1> {<Question* qs>} <Question* qs2>}`
      => (Form)`form <Id n> {<Question* qs1> <Question* qs> <Question* qs2>}`
   }
  }
  return f;
} 

*/
