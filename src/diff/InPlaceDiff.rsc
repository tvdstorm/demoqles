module diff::InPlaceDiff

import ParseTree;
import diff::DiffAST;

data Tree
 = deleteTree(Tree t)
 | insertTree(Tree t)
 | replaceTree(Tree old, Tree new)
 ;


// Factor out in utils module.
// todo: make robust against non-sort things.
str getSortName(appl(prod(label(_, sort(str n)), _, _), _)) = n;
str getSortName(appl(prod(sort(str n), _, _), _)) = n;
str getSortName(appl(prod(lex(str n), _, _), _)) = n;
default str getSortName(Tree t) = {throw "No sort for <t.prod>";};


Tree makeInPlaceDiff(Tree original, Diff diff) {

}

Tree inplace(replace(srt, oldLoc, new), Tree t)
  = replaceTree(t, new)
  when /*getSortName(t) == srt,*/ oldLoc == t@\loc; 

Tree inplaceIter(\insert(srt, cont, pos, elt), list[Symbol] seps, Tree t) {
  if (cont != t@\loc) {
    return t;
  }
  if (getSortName(t) != srt) {
    return t;
  }
  skip = size(seps);
  while (i < size(t.args)) {
    
    i += skip + 1;
  }
  
}

str unparseDiffTree(deleteTree(t))
  = "-[[<t>]]";
 
str unparseDiffTree(insertTree(t))
  = "+[[<t>]]";

str unparseDiffTree(replaceTree(old, new))
  = "[[<old>]] =\> [[<new>]]";

str unparseDiffTree(appl(_, [as]))
  = ( "" | it + unparseDiffTree(a) | a <- as );
  
default str unparsDiffTree(Tree t)
  = "<t>";
  
      