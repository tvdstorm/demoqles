module diff::Parse

import diff::Diff;
import diff::PGen;
import ParseTree;
import Grammar;
import String;
import IO;

loc area2loc(str project, str path, Area a)
  = |project://<project><path>|(
       toInt("<a.offset>"), 
       toInt("<a.length>"), 
       <toInt("<a.begin.line>"), toInt("<a.begin.column>")>,
       <toInt("<a.end.line>"), toInt("<a.end.column>")>);

str sourcePath(Diff d) 
  = [ "<c.path>" | c <- d.config, c is source ][0];

str targetPath(Diff d) 
  = [ "<c.path>" | c <- d.config, c is target ][0];

start[Diff] parseDiff(str src, loc l)
  = parse(#start[Diff], src, l);

start[Diff] parseDiff(str src, loc l, Grammar theGrammar, str project) {
  pt = parseDiff(src, l);
  pt.top = parseFragments(pt.top, theGrammar, project); 
  return pt;
} 

Diff parseFragments(Diff d, Grammar theGrammar, str project) {
  return visit (d) {
    case Edit e: {
       if (e has fragment) {
         f = e.fragment;
         l = area2loc(project, sourcePath(d), e.target);
         println("L = <l>");
         f.content = parse(theGrammar, "<e.name>", "<f.content>", l); 
         e.fragment = f;
         insert e;
       }
    }
  }
}
