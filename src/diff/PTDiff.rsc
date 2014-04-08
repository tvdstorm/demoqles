module diff::PTDiff

import ParseTree;
import List;
import IO;
import util::Math;
import Node;

import diff::DiffAST;

// TODO items:
// - let getDiff return edits immediately (maybe)
// - have edits contain layout and separators (No -> heuristic)
// - abstract keyness/equalModuloKey using function parameters
//   so that more complex keys can be defined (e.g. name + arity)
// - define a (parameterized?) grammar for Edits to that
//   we can parse them in an editor (No -> use dynamic one).
// - implement patch to apply a diff to a tree
// - implement 3-way merge to combine diffs


//void testMissGrant() {
//  pt1 = parse(|project://string-origins/src/input/missgrant.ctl|);
//  pt2 = parse(|project://string-origins/src/input/missgrant-diff.ctl|);
//  d = ptDiff(pt1.top, pt2.top, "lang::missgrant::base::Syntax");
//  dsrc = ppDiff(d);
//  writeFile(|project://string-origins/src/input/missgrant.difftax|, dsrc);
//  println(dsrc);
//
//  pt2 = parse(|project://string-origins/src/input/misterjones.ctl|);
//  d = ptDiff(pt1.top, pt2.top, "lang::missgrant::base::Syntax");
//  dsrc = ppDiff(d);
//  writeFile(|project://string-origins/src/input/missgrant-jones.difftax|, dsrc);
//
//
//}


Diff ptDiff(Tree t1, Tree t2, str syntaxModule) {
  d = diff([source(t1@\loc.path),
            target(t2@\loc.path),
            \syntax(syntaxModule)], []);
  d.edits = treeDiff(t1, t2);
  return d;          
}


// todo: make robust against non-sort things.
str getSortName(appl(prod(label(_, x), _, _), _)) = getSortName(x);
str getSortName(appl(prod(sort(str n), _, _), _)) = n;
str getSortName(appl(prod(lex(str n), _, _), _)) = n;
default str getSortName(Tree t) = "<t.prod.def>"; 
//{throw "No sort for <t.prod>";};


str getSortName(Symbol::label(_, x)) = getSortName(x);
str getSortName(Symbol::sort(str n)) = n;
str getSortName(Symbol::lex(str n)) = n;
default str getSortName(Symbol s) = "<s>"; 

// We assume t1 and t2 are of the same type (i.e. non-terminal).
// And for now, we ignore layout.
list[Edit] treeDiff(Tree t1, Tree t2) {
  //rprintln(t1);
  //rprintln(t2);
  //???? assert t1 is appl && t2 is appl; 
  
  
  if (t1.prod != t2.prod) {
    //println("replace because prod non-equal");
    return [replace(getSortName(t1), t1@\loc, t2)];
  }
  
  if (t1.prod.def is lex) {
    //println("lexical");
    return replaceIfNonEqual(t1, t2);
  }
  
  edits = [];
  p = t1.prod;
  for (i <- [0,2..size(p.symbols)]) {
    //println("args1[<i>] = <t1.args[i]>");
    //println("args2[<i>] = <t2.args[i]>");
    //println("Symbol <i> = <p.symbols[i]>");
    edits += symDiff(p.symbols[i], t1.args[i], t2.args[i]);
  }
  return edits;
}

list[Edit] symDiff(\label(_, Symbol s), Tree t1, Tree t2)
  = symDiff(s, t1, t2);
  
list[Edit] symDiff(\conditional(Symbol s, _), Tree t1, Tree t2)
  = symDiff(s, t1, t2);

list[Edit] symDiff(\lex(_), Tree t1, Tree t2) = replaceIfNonEqual(t1, t2);
list[Edit] symDiff(\char-class(_), Tree t1, Tree t2) = replaceIfNonEqual(t1, t2);

list[Edit] replaceIfNonEqual(Tree t1, Tree t2) {
  if (t1 == t2) {
    return [];
  }
  return [replace(getSortName(t1), t1@\loc, t2)];
}



list[Edit] symDiff(Symbol::\sort(_), Tree t1, Tree t2) 
  = treeDiff(t1, t2);


list[Edit] symDiff(lit(_), Tree t1, Tree t2) = [];
list[Edit] symDiff(cilit(_), Tree t1, Tree t2) = [];
list[Edit] symDiff(empty(), Tree t1, Tree t2) = [];

list[Edit] symDiff(\opt(_), Tree t1, Tree t2) {
  // t1 and t2 are both appl(regular(opt(_)), ...)
  args1 = t1.args;
  args2 = t2.args;
  if (size(args1) == size(args2)) {
    return ( [] | it + treeDiff(a1, a2) | <a1, a2> <- zip(args1, args2) ); 
  }
  n = getSortName(size(args1) != 0 ? args1[0] : args2[0]);
  return [replace(n, t1@\loc, t2)];
    //return [\insert(t1@\loc, 0, args2[0])];
}

// we never see iter-star because it's in lexicals only. 

list[Edit] symDiff(\iter-star-seps(Symbol s, seps), Tree t1, Tree t2)
  = iterDiff(s, seps, t1, t2); 

list[Edit] symDiff(\iter-seps(Symbol s, seps), Tree t1, Tree t2)
  = iterDiff(s, seps, t1, t2); 

list[Edit] iterDiff(Symbol s, list[Symbol] seps, Tree t1, Tree t2) {

  bool ptLCSEquals(Tree t1, Tree t2) {
    if (appl(p1, _) := t1, appl(p2, _) := t2, p1 == p2) {
      k1 = keyOf(t1);
      k2 = keyOf(t2);
      if (k1 != "", k1 == k2) {
        return true;
      }
    }
    //println("Returning t1 == t2: <t1 == t2>");
    return t1 := t2;
  }
  
  skip = size(seps);
  //println("skip = <skip>");
  l1 = t1.args == [] ? [] : t1.args[0,skip+1..];
  l2 = t2.args == [] ? [] : t2.args[0,skip+1..];
  
  map[str, tuple[Tree sub,int pos]] mapping = ();
  if ((l1 != [] && keyOf(l1[0]) != "") ||
      (l2 != [] && keyOf(l2[0]) != "")) {
    // for the unordered case (i.e. if keys are present?)
    // (NB: breaks "rename" detection.
    // TODO: use Maybe for keyOf
    mapping = 
       ( keyOf(t): <t, i> | i <- [0..size(l2)], Tree t := l2[i] );
    done = [];
    l2 = for (Tree sub <- l1) {
      k = keyOf(sub);
      if (k != "", k in mapping) {
        done += [k];
        append mapping[k].sub;
      }
      else if (str k <- mapping, equalModuloKey(mapping[k].sub, sub)) {
        done += [k];
        append mapping[k].sub;
      }
    }
    l2 += [ mapping[k].sub | k <- mapping, k notin done ];
  }

  //println("l1 prods");
  //for (x <- l1) { println(x.prod); }
  //println("l2 prods");
  //for (x <- l2) { println(x.prod); }

  m = lcsMatrix(l1, l2, ptLCSEquals);

  
  edits = [];
  diffs = getDiff(m, l1, l2, size(l1), size(l2), ptLCSEquals);
  for (d <- diffs) {
    //println("Diff = <getName(d)>");
    if (same(x, y) := d) {
      edits += treeDiff(x, y);
    }
    else if (add(x, i) := d) {
      k = keyOf(x);
      edits += [\insert(getSortName(x), t1@\loc, 
                                 k in mapping  
                                 ? mapping[k].pos
                                 : 
                                 i,
                                  x)];
    }
    else if (remove(x, i) := d) {
      edits += [\delete(getSortName(x), t1@\loc, i)];
    }
    else {
      throw "Should not happen";
    }
  }
  return edits;
}



data Diff
  = same(&T t1, &T t2)
  | add(&T t, int pos)
  | remove(&T t, int pos)
  ;
  
  
  /*
  function printDiff(C[0..m,0..n], X[1..m], Y[1..n], i, j)
    if i > 0 and j > 0 and X[i] = Y[j]
        printDiff(C, X, Y, i-1, j-1)
        print "  " + X[i]
    else if j > 0 and (i = 0 or C[i,j-1] � C[i-1,j])
        printDiff(C, X, Y, i, j-1)
        print "+ " + Y[j]
    else if i > 0 and (j = 0 or C[i,j-1] < C[i-1,j])
        printDiff(C, X, Y, i-1, j)
        print "- " + X[i]
    else
        print ""
        */

list[Diff] getDiff(map[int,map[int,int]] c, list[&T] x, list[&T] y, int i, int j,
   bool(&T, &T) equals) {
  if (i > 0, j > 0,  equals(x[i-1], y[j-1])) {
    //println("============= Returning same(<i-1>, <j-1>)");
    //println(x[i-1]);
    //println(y[j-1]);
    return getDiff(c, x, y, i - 1, j - 1, equals) + [same(x[i-1], y[j-1])];
  }
  if (j > 0, (i == 0 || c[i][j-1] >= c[i-1][j])) {
    //println("+++++++++++++ Returning add(<j-1>)");
    //println(y[j-1]);
    return getDiff(c, x, y, i, j-1, equals) + [add(y[j-1], j-1)];
  }
  if (i > 0, (j == 0 || c[i][j-1] < c[i-1][j])) {
    //println("------------- Returning remove(<i-1>)");
    //println(x[i-1]);
    return getDiff(c, x, y, i-1, j, equals) + [remove(x[i-1], i-1)];
  }
  return [];
}
/*
function LCSLength(X[1..m], Y[1..n])
    C = array(0..m, 0..n)
    for i := 0..m
       C[i,0] = 0
    for j := 0..n
       C[0,j] = 0
    for i := 1..m
        for j := 1..n
            if X[i] = Y[j]
                C[i,j] := C[i-1,j-1] + 1
            else
                C[i,j] := max(C[i,j-1], C[i-1,j])
    return C[m,n]
 */


map[int,map[int,int]] lcsMatrix(list[&T] x, list[&T] y, bool (&T,&T) equals) {
  map[int,map[int,int]] c = ();
  
  m = size(x);
  n = size(y);
  
  for (int i <- [0..m + 1]) {
    c[i] = ();
    c[i][0] = 0;
  }
  
  for (int j <- [0..n + 1]) {
    c[0][j] = 0;
  }
  
  for (int i <- [1..m + 1], int j <- [1.. n + 1]) {
    if (equals(x[i - 1], y[j - 1])) {
      c[i][j] = c[i-1][j-1] + 1;
    }
    else {
      c[i][j] = max(c[i][j-1], c[i-1][j]);
    }
  }
  
  return c;  
}


bool equalModuloKey(Tree t1, Tree t2) {
  syms = t1.prod.symbols;
  len = size(syms);
  for (i <- [0..len]) {
    if (label("name", _) := syms[i]) {
      t1.args[i] = t2.args[i];
    }
  }  
  return t1 == t2;
}

str keyOf(Tree t) {
  syms = t.prod.symbols;
  len = size(syms);
  for (i <- [0..len]) {
    if (label("name", _) := syms[i]) {
      println("Found the name: <unparse(t.args[i])>");
      return unparse(t.args[i]);
    }
  }
  return "";
}


/*
data Symbol
     = \empty() 
     | \opt(Symbol symbol)  
     | \iter(Symbol symbol)   
     | \iter-star(Symbol symbol)   
     | \iter-seps(Symbol symbol, list[Symbol] separators)   
     | \iter-star-seps(Symbol symbol, list[Symbol] separators) 
     | \alt(set[Symbol] alternatives)
     | \seq(list[Symbol] symbols)
     ;
  

data Symbol = \conditional(Symbol symbol, set[Condition] conditions) ;
*/

void testIt() {
  l1 = ["X", "M", "J", "Y", "A", "U", "Z"];
  l2 = ["M", "Z", "J", "A", "W", "X", "U"];
  
  m = lcsMatrix(l1, l2);
  //iprintln(m);
  
  //iprintln(getDiff(m, l1, l2, size(l1), size(l2)));
}


list[Edit] iterDiff__(Symbol s, list[Symbol] seps, Tree t1, Tree t2) {
  // t1 and t2 are both appl(regular(iter-star(_)), ...)
  args1 = t1.args;
  args2 = t2.args;
  l1 = size(args1);
  l2 = size(args2);
  k = min(l1, l2);
  
  edits = [];
  // we now there's layout because we don't descend on lexicals
  // so the only distinction is whether there are other seps.
  if (size(seps) == 1) { // just layout
    for (i <- [0,2..k]) {
      edits += symDiff(s, args1[i], args2[i]); 
    }
  }
  else { // layout + separator
    for (i <- [0,5..k]) {
      edits += treeDiff(args1[i], args2[i]);
    }
  }
  if (l1 > l2) {
    for (i <- [k..l1]) {
      edits += [\delete(t1@\loc, l1 - (i - k) - 1)];
    }
    //if (size(seps) == 1) { // just layout
    //  for (i <- [k,k+2..l1]) {
    //    edits += [delete(args1[i]@\loc)];
    //  }
    //}
    //else {// layout + separator
    //  for (i <- [k,k+5..l1]) {
    //    edits += [delete(args1[i]@\loc)];
    //  }
    //}
  }
  else if (l1 < l2) {
    for (i <- [k..l2]) {
      edits += [\insert(t1@\loc, i, args2[i])];
    }  
    //if (size(seps) == 1) { // just layout
    //  edits += [\insert(t1@\loc, k, args2[k])];
    //  for (i <- [k+1,k+3..l2]) { // k itself is the separator layout
    //    edits += [\insert(t1@\loc, i - 1, args2[i])];
    //  }
    //}
    //else {// layout + separator
    //  edits += [\insert(t1@\loc, k, args2[k])];
    //  edits += [\insert(t1@\loc, k + 1, args2[k + 1])];
    //  edits += [\insert(t1@\loc, k + 2, args2[k + 2])];
    //  
    //  for (i <- [k+3,k+8..l2]) { 
    //    edits += [\insert(t1@\loc, i - 1, args2[i])];
    //  }
    //}
  }
    
  return edits;  
}
