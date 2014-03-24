module lang::demoqles::qls::Outline

import lang::demoqles::qls::QLS;
import util::IDE;
import ParseTree;
import List;

node outline(Stylesheet s) {
 ps = []; qs = []; ss = []; ys = []; ws = []; ds = [];
 
 top-down visit (s) {
   case x:(Page)`page <Id n> <Rule r>`:
    ps += ["page"()[@label="<n>"][@\loc=x@\loc]];
 
   case x:(Rule)`section <String s> <Rule r>`: {
    l = "<s>"[1..-1];
    ss += ["section"()[@label="<l>"][@\loc=x@\loc]];
   }

   case x:(Rule)`question <Var n>`:
    qs += ["question"()[@label="<n>"][@\loc=x@\loc]];
   
   case x:(Rule)`question <Var n> <Style y>`: 
    qs += ["question"()[@label="<n>"][@\loc=x@\loc]];

   case x:(Rule)`default <Type t> <Style _>`:
    ds += ["default"()[@label="<t>"][@\loc=x@\loc]];

   case x:(Style)`<Id n>: <Value v>`:
    ys += ["style"()[@label="<n>: <v>"][@\loc=x@\loc]];

   case x:(Style)`widget <WidgetType w>`:
    ws += ["widget"()[@label="<w>"][@\loc=x@\loc]];

 }
 
 return "outline"(
  "pages"(ps)[@label="Pages (<size(ps)>)"],
  "sections"(ss)[@label="Sections (<size(ss)>)"],
  "questions"(qs)[@label="Questions (<size(qs)>)"],
  "styles"(ys)[@label="Styles (<size(ys)>)"],
  "widgets"(ws)[@label="Widgets (<size(ws)>)"],
  "defaults"(ds)[@label="Defaults (<size(ds)>)"]
 )[@label="QLS"];
}


