module diff::Annotate

import diff::Diff;
import diff::Parse;
import ParseTree;
import IO;
import Node;
import util::IDE;

anno rel[loc,loc] Tree@hyperlinks;

start[Diff] installHyperlinks(Tree t, str project) {
  if (Diff d := t.top) {
   tpath = targetPath(d);
   spath = sourcePath(d);
   rel[loc, loc] hyperlinks = {};
   
   d = visit (d) {
     case Edit e: {
       if (e has source) {
         l = area2loc(project, spath, e.source);
         hyperlinks += {<e.source@\loc, l>};
         //println("Source: <l>");
         //e.source = e.source[@link=l]; 
       }
       if (e has target) {
         l = area2loc(project, tpath, e.target);
         hyperlinks += {<e.target@\loc, l>};
         println("Target: <l>");
         //e.target = e.target[@link=l];
       }
     }
     //case Fragment f: hyperlinks += { <f@\loc, f.content@\loc>};
   }
   return t[top=d][@hyperlinks=hyperlinks];
  }
  throw "Not a diff";
}



node(Tree t) outlinerer(str project) {
  return node (Tree t) {
    list[node] rs = [];
    list[node] ds = [];
    list[node] is = []; 
 
      if (Diff d := t.top) {
       tpath = targetPath(d);
       spath = sourcePath(d);
     
       top-down visit (t) {
         case Edit e: {
           if (e is replace) {
             rs += ["replace"(
                      ["src"()[@label="from: <spath> <e.source>"][@\loc=area2loc(project, spath, e.source)],
                       "trg"()[@label="to: <tpath> <e.target>"][@\loc=area2loc(project, tpath, e.target)]])
                         [@label="<e.name>: <e.fragment.content>"][@\loc=e@\loc]];
                         
           }
           if (e is \insert) {
             is += ["insert"(
                      ["trg"()[@label="element <tpath> <e.target>"][@\loc=area2loc(project, tpath, e.target)],
                       "src"()[@label="at <e.position> in: <spath> <e.source>"][@\loc=area2loc(project, spath, e.source)]
                       ])
                         [@label="<e.name>: <e.fragment.content>"][@\loc=e@\loc]];
           }
           if (e is delete) {
             ds += ["delete"(
                      ["src"()[@label="at <e.position> in: <spath> <e.source>"][@\loc=area2loc(project, spath, e.source)]
                       ])
                         [@label="<e.name>"][@\loc=e@\loc]];
           }
         }
       }
    
       return "outline"(
        "replaces"(rs)[@label="Replace (<size(rs)>)"],
        "inserts"(is)[@label="Insert (<size(is)>)"],
        "deletes"(ds)[@label="Delete (<size(ds)>)"]
       );
      }
      throw "Error";
    };
}
