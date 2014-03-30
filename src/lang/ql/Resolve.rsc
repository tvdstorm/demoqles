module lang::ql::Resolve

import lang::ql::QL;
import lang::ql::Types;
import lang::ql::RefGraph;
import Message;
import IO;
import ParseTree;
import List;
import Set;

alias Labels = rel[Label label, loc question];
alias Info = tuple[Refs refs, Labels labels];

Info resolve(Form f) {
  // Lazy because of declare after use.
  map[loc, set[loc]()] useLazy = ();
  Def def = {};
  Labels labels = {};
  
  rel[Id, loc] env = {};	
  
  // Return a function that looks up declaration of `n` in defs when called.
  set[loc]() lookup(Id n) 
    = set[loc]() { return env[n]; };


  void addUse(loc l, Id name) {
    useLazy[l] = lookup(name);
  }
  
  void addLabel(Label label, loc l) {
    labels += {<label, l>};
  }
  
  void addDef(Id n, loc q, Type t) {
    env += {<n, q>};
    def += {<q, qlType(t)>};
  }
  
  visit (f) {
    case Expr e:(Expr)`<Id x>`:
      addUse(x@\loc, x); 
    
    case q:(Question)`<Label l> <Id x>: <Type t>`: {
      addLabel(l, x@\loc);
      addDef(x, x@\loc, t);
    }
      
    case q:(Question)`<Label l> <Id x>: <Type t> = <Expr e>`: {
      addLabel(l, x@\loc); 
      addDef(x, x@\loc, t);
    }
  }
  
  // Force the closures in `use` to resolve references.
  use = { <u, d> | u <- useLazy, d <- useLazy[u]() };
  
  return <<use, def>, labels>;
}

rel[loc,loc,str] computeXRef(Info i) 
  = { <l1, l2, "<l>"> | <u, d> <- i.refs.use, <l, d> <- i.labels }; 

map[loc, str] computeDocs(Info i) {
  docs = { <u, "<l>"> | <u, d>  <- i.refs.use, <l, d> <- i.labels };
  return ( k: intercalate("\n", toList(docs[k])) | k <- docs<0> );
}
  