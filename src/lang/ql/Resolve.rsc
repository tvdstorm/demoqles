module lang::ql::Resolve

import lang::ql::QL;
import lang::ql::Types;
import Message;
import IO;
import ParseTree;
import List;
import Set;

// TODO: for the tutorial use relations, not maps.

// Locations of labels
// rel[Label, loc]
alias Labels = map[Label, set[loc]];

// The (possibly multiple) declarations of a variable use
// rel[loc use, loc def]  
alias Use = map[loc use, set[loc] defs];

// The declarations of variables
// rel[loc def, Type typ]
// rel[loc, Id] names
alias Def = map[Id name, rel[loc def, QLType typ] decl];

alias Refs = tuple[Use use, Def def, Labels labels];

map[loc, str] computeDocs(Refs r) {
  // link uses to labels
  docs = { <k, "<l>"> | k <- r.use, d <- r.use[k], l <- r.labels, d in r.labels[l] };
  return ( k: intercalate("\n", toList(docs[k])) | k <- docs<0> );
}

rel[loc,loc, str] computeXRef(Refs r) 
  = { <l1, l2, "<l>"> | l1 <- r.use, l2 <- r.use[l1], l <- r.labels, l2 in r.labels[l] }; 

Refs resolve(Form f) {

  // Lazy because of declare after use.
  map[loc, set[loc]()] use = ();
  Def def = ();
  Labels labels = ();	
  
  // Return a function that looks up declaration of `n` in defs when called.
  set[loc]() lookup(Id n) 
    = set[loc]() { return (def[n]?) ? def[n]<0> : {}; };


  void addUse(loc l, Id name) {
    use[l] = lookup(name);
  }
  
  void addLabel(Label label, loc l) {
    if (!labels[label]?) labels[label] = {};
    labels[label] += {l};
  }
  
  void addDef(Id n, loc q, Type t) {
    if (!def[n]?) def[n] = {};
    def[n] += {<q, qlType(t)>};
  }
  
  visit (f) {
    case Expr e:(Expr)`<Id name>`:
      addUse(e@\loc, name); 
    
    case q:(Question)`<Label l> <Id x>: <Type t>`: {
      addLabel(l, q@\loc);
      addDef(x, q@\loc, t);
    }
      
    case q:(Question)`<Label l> <Id x>: <Type t> = <Expr e>`: {
      addLabel(l, q@\loc); 
      addDef(x, q@\loc, t);
    }
  }
  
  // Force the closures in `use` to resolve references.
  return <( u: use[u]() | u <- use ), def, labels>;
}
