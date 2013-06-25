module lang::demoqles::ql::Outline

import lang::demoqles::ql::QL;
import util::IDE;
import ParseTree;

node outline(Form f) {
 qs = [];
 
 void addQuestion(Question q) {
   qs += ["question"(["label"()[@label="<q.label>"]])[@label="<q.var>: <q.\type>"][@\loc=q@\loc]];
 }
 
 visit (f) {
   case q:(Question)`<Label l> <Var x>: <Type t>`: addQuestion(q);
   case q:(Question)`<Label l> <Var x>: <Type t> = <Expr e>`: addQuestion(q);
 }

 return "outline"(qs)[@label="Questions"];
}
