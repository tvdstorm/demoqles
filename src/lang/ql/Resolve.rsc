module lang::ql::Resolve

import lang::ql::QL;
import lang::ql::Types;
import Message;
import IO;
import ParseTree;
import List;

alias Use = map[loc, rel[loc, QLType]()];
alias Def = map[str, rel[loc, QLType]];
alias Labels = map[str, set[loc]];  

alias Refs = tuple[Use use, Def def, Labels labels];

Refs resolve(Form f) {
  Use use = ();
  Def def = ();
  Labels labels = ();	
  
  rel[loc, QLType]() lookup(str n) 
    = rel[loc, QLType]() { return (def[n]?) ? def[n] : {}; };
  
  void addDef(str n, loc q, Type t) {
    if (!def[n]?) def[n] = {};
    def[n] += {<q, qlType(t)>};
  }
  
  void addLabel(str label, loc l) {
    if (!labels[label]?) labels[label] = {};
    labels[label] += {l};
  }
  
  visit (f) {
    case Expr e:(Expr)`<Id name>`: 
      use[e@\loc] = lookup("<name>");
    
    case q:(Question)`<Label l> <Var x>: <Type t>`: {
      addLabel("<l>", l@\loc);
      addDef("<x>", q@\loc, t);
    }
      
    case q:(Question)`<Label l> <Var x>: <Type t> = <Expr e>`: {
      addLabel("<l>", l@\loc); 
      addDef("<x>", q@\loc, t);
    }
  }
  
  return <use, def, labels>;
}
