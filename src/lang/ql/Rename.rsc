module lang::ql::Rename

import lang::ql::QL;
import lang::ql::Resolve;

import util::Prompt;
import ParseTree;

alias Labels = map[Label, set[loc]];

// The (possibly multiple) declarations of a variable use
// rel[loc use, loc def]  
alias Use = map[loc use, set[loc] defs];

// The declarations of variables
// rel[loc def, Type typ]
// rel[loc, Id] names
alias Def = map[Id name, rel[loc def, QLType typ] decl];

alias Refs = tuple[Use use, Def def, Labels labels];

set[loc] allNames(Refs r)
  = r.use<use> + r.def<decl><def>;

set[loc] equivNames(loc x, Refs r)
  = { y, d | d <- r.use[x], y <- r.use, d in r.use[y] }
  when x in r.use; // it's a use site

set[loc] equivNames(loc x, Refs r)
  = {x} + { y | y <- r.use, x in r.use[y] }
  when x in r.def<decl><def>; // it's a def site
  
start[Form] rename(start[Form] f, loc sel, Refs r) {
  // NB: names never overlap, so can use <= on locs
  if (x <- allNames(r), sel <= x) {
    xEquiv = equivNames(x, r);  
    new = parse(#Id, prompt("Enter new name:"));
    return visit (f) {
      case Id old => new when old@\loc in xEquiv
    }
  }
  return f;
}

