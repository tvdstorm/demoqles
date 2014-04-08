module diff::DiffAST

// NB: never to be used for implode, just for creating
// Diffs and then unparsing them.

import ParseTree;

data Diff
  = diff(list[Config] config, list[Edit] edits);
  
data Config
  = source(str path)
  | target(str path)
  | \syntax(str \module)
  ;
  
data Edit
  = delete(str sort, loc container, int pos)
  | \insert(str sort, loc container, int pos, Tree elt)
  | replace(str sort, loc old, Tree new)
  ;

str ppDiff(diff(cs, es)) =
  "diff {<for (c <- cs) {>
  '  <ppConf(c)><}>
  '  <for (e <- es) {>
  '  <ppEdit(e)><}>
  '}
  ";

str ppConf(source(str s)) = "source = <s>";
str ppConf(target(str s)) = "target = <s>";
str ppConf(\syntax(str s)) = "syntax = <s>";

str loc2coords(loc l) 
//  = "(<l.offset>,<l.length>,\<<l.begin.line>,<l.begin.column>\>,\<<l.end.line>,<l.end.column>\>)";
  = "(<l.offset>,<l.length>)";

str ppEdit(Edit::delete(s, loc l, p)) 
  = "delete <s> <p> in <loc2coords(l)>";


str ppEdit(\insert(s, l, p, e)) 
  = "insert <s> [[<unparse(e)>]]<loc2coords(e@\loc)> at <p> in <loc2coords(l)>";
  
  
str ppEdit(replace(s, old, new)) 
  = "replace <s> <loc2coords(old)> with [[<unparse(new)>]]<loc2coords(new@\loc)>";

  
