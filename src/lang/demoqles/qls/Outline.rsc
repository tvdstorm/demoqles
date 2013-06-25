module lang::demoqles::qls::Outline

import lang::demoqles::qls::QLS;
import util::IDE;
import ParseTree;

node outline(Stylesheet s) {
 ps = [];
 qs = [];
 ss = [];
 ys = [];
 ws = [];
 
 top-down visit (s) {
   case x:(Page)`page <Id n> <Rule r>`:
    ps += ["page"()[@label="<n>"][@\loc=x@\loc]];
 
   case x:(Rule)`section <String s> <Rule r>`:
    ss += ["section"()[@label="<s>"][@\loc=x@\loc]];

   case x:(Rule)`question <Var n>`:
    qs += ["question"()[@label="<n>"][@\loc=x@\loc]];
   
   case x:(Rule)`question <Var n> <Style y>`: 
    qs += ["question"()[@label="<n>"][@\loc=x@\loc]];

   case x:(Style)`<Id n>: <Value v>`:
    ys += ["style"()[@label="<n>: <v>"][@\loc=x@\loc]];

   case x:(Style)`widget <WidgetType w>`:
    ws += ["widget"()[@label="<w>"][@\loc=x@\loc]];

 }
 
 return "outline"(
  "pages"(ps)[@label="Pages"],
  "sections"(ss)[@label="Sections"],
  "questions"(qs)[@label="Questions"],
  "styles"(ys)[@label="Styles"],
  "widgets"(ws)[@label="Widgets"]
 )[@label="QLS"];
}


