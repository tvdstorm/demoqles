module lang::ql::Bind

import lang::ql::QL;
import lang::ql::Types;
import Message;
import IO;
import ParseTree;
import List;

anno set[QLType] Expr@\types;

// should not be needed 
anno bool Question@redecl;

// Bug:
//start[Form] bind(start[Form] f) {
Form bind(Form f, map[str, rel[loc, QLType]] defs) {
  str types2str(set[QLType] ts) = intercalate(", ", [ type2str(t) | t <- ts ]);
  return visit (f) {
    case Expr e:(Expr)`<Id name>`: {
      x = "<e.name>";
      locs = (defs[x]?) ? defs[x]<0> : {};
      types = (defs[x]?) ? defs[x]<1> : {};
      insert e[@links=locs][@types=types][@doc=types2str(types)];
    } 
  }
}

tuple[Form, map[str, rel[loc, QLType]]] definitions(Form f) {
  defs = ();
  
  Question addDef(Question q, Var x, Type t) {
    s = "<x>";
    qt = qlType(t);
    if (s in defs, <_, qt2> <- defs[s], qt2 != qt) {
      q@redecl = true;
    }
    rel[loc, QLType] empty = {};
    defs[s]?empty += {<q@\loc, qt>};
    return q;
  }
  
  f = top-down visit (f) {
    case q:(Question)`<Label l> <Var x>: <Type t>` => addDef(q, x, t)
    case q:(Question)`<Label l> <Var x>: <Type t> = <Expr e>` => addDef(q, x, t)
  }

  return <f, defs>;
}

