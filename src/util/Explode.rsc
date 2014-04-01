module util::Explode

import ParseTree;
import Node;
import lang::rascal::grammar::definition::Priorities;
import Grammar;
import String;
import List;

default str useAsLayout() = " ";


&T<:Tree explode(type[&T <: Tree] sort, node ast) {
  if (&T t := value2tree(sort.symbol, ast, sort.definitions)) {
    return t;
  }
  assert false: "Wrong type returned by value2tree.";
}

Tree value2tree(Symbol x, value v, map[Symbol, Production] defs) {
  if (x is label) {
    x = x.symbol;
  }
  if (node ast := v) {
    alts = defs[x].alternatives;
    for (/p:prod(label(n, _), _, _) <- alts) {
      //println("p = <p>");
      if (n == getName(ast)) {
        return value2tree(p, ast, defs); 
      }
    }
    throw "Could not find production for <x> <ast>";
  }
  if (str s := v) {
    return appl(prod(x, [], {}), charsOf(s));
  }
  if (int i := v) {
    return appl(prod(x, [], {}), charsOf("<i>"));
  }
  if (list[value] l := v) {
    return list2regular(x, l, defs); 
  }
  //println("x = <x>, value = <v>");
}


Tree list2regular(iter:\iter-star-seps(s, seps), list[value] vs, map[Symbol, Production] defs) {
  first = true;
  as = args: for (v <- vs) {
     if (!first) {
       for (Symbol sep <- seps) {
         //println("ADDDING SEP ------------ <sep>");
         append args: sym2default(sep);
       }
     }
     append value2tree(s, v, defs);
     first = false;
  }
  return appl(regular(iter), as);
}

Tree value2tree(Production p, node ast, map[Symbol, Production] defs) 
  = appl(p, zipIt(p.symbols, getChildren(ast), defs));


list[Tree] zipIt(list[Symbol] syms, list[value] args, map[Symbol, Production] defs) {
  ////println("ARGS = <args>");
  ////println("SYMS = <syms>");
  i = 0;
  ts = for (s <- syms) {
    //println("sym = <s>");
    if (isASTsymbol(s)) {
      ////println("it\'s ast");
      append value2tree(s, args[i], defs);
      i += 1;
    }
    else {
      ////println("it\'s not");
      append sym2default(s);
    }
  }
  return ts;
}

// todo; make charclasses for syms in prod
Tree sym2default(x:\layouts(l)) = appl(prod(x, [], {}), charsOf(useAsLayout()));
Tree sym2default(x:\lit(s)) = appl(prod(x, [], {}), charsOf(s));
Tree sym2default(x:\cilit(s)) = appl(prod(x, [], {}), charsOf(s));
Tree sym2default(conditional(Symbol x, _)) = sym2default(x);
Tree sym2default(x:empty()) = appl(prod(x, [], {}), []);


list[Tree] charsOf(str x) = [ char(c) | c <- chars(x) ];

bool isASTsymbol(\layouts(_)) = false; 
bool isASTsymbol(\keywords(str name)) = false;
bool isASTsymbol(\lit(str string)) = false;
bool isASTsymbol(\cilit(str string)) = false;
bool isASTsymbol(\conditional(Symbol s, _)) = isASTsymbol(s);
bool isASTsymbol(\empty()) = false;
default bool isASTsymbol(Symbol _) = true;

//prod(Symbol def, list[Symbol] symbols, set[Attr] attributes) /*3*/ 