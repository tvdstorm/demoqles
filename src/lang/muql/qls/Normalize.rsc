module lang::muql::qls::Normalize

extend lang::muql::ql::QL;
extend lang::muql::qls::QLS;
import IO;
import Relation;
import ParseTree;

syntax Rule
  = styledQuestion: Question Style style
  ;
  
void testIt() {
  f = parse(#start[Form], |project://muql/input/tax.mql|);
  s = parse(#start[Stylesheet], |project://muql/input/tax.mqls|);
  s2 = inlineQuestions(s.top, f.top);
  println("INLINED:");
  println(s2);  
  s3 = groupStylesAndRules(s2);
  println("GROUPED STYLES:");
  println(s3);  
  s4 = moveWidgetsToTop(s3);
  println("WIDGETS AT TOP:");
  println(s4);  
  s5 = applyDefaultStyles(s4);
  println("DEFAULTS APPLIED:");
  println(s5);
  s6 = cleanupWidgetsAndDefaults(s5);
  println("CLEANUP:");
  println(s6);
  
}  

Stylesheet normalize(Stylesheet s, Form f) = normalize(inlineQuestions(s, f));
Stylesheet normalize(Stylesheet s) 
  = (cleanupWidgetsAndDefaults
     o applyDefaultStyles
     o moveWidgetsToTop
     o groupStylesAndRules)(s);
  
Stylesheet inlineQuestions(Stylesheet s, Form f) {
  qs = ( q.var: q | /Question q <- f.questions, q has var );
  return visit (s) {
    case (Rule)`question <Var v>` => (Rule)`<Question q> { }`
      when Question q := qs[v]
    case (Rule)`question <Var v> <Style y>` => (Rule)`<Question q> <Style y>`
      when Question q := qs[v]
  }
}

Stylesheet flattenNestedGroups(Stylesheet s) {
  return innermost visit (s) {
    case (Rule)`{ <Rule* rs1> { <Rule* rs2> } <Rule* rs3> }` =>
      (Rule)`{ <Rule* rs1> <Rule* rs2> <Rule* rs3> }`
    case (Style)`{ <Style* rs1> { <Style* rs2> } <Style* rs3> }` =>
      (Style)`{ <Style* rs1> <Style* rs2> <Style* rs3> }`
  }
}

Stylesheet groupStylesAndRules(Stylesheet s) {
  return top-down visit (s) {
    case (Page)`page <Id n> <Rule r>` => (Page)`page <Id n> {<Rule r>}`
      when !(r is group) 
    case (Rule)`<Question q> <Style y>` => (Rule)`<Question q> {<Style y>}`
      when !(y is group) 
    case (Rule)`section <String t> <Rule r>` => (Rule)`section <String t> {<Rule r>}`
      when bprintln("r = <r>"), bprintln("r is group? <r is group>"), !(r is group) 
  }
}

Stylesheet cleanupWidgetsAndDefaults(Stylesheet s) {
  solve (s) {
   s = visit (s) {   //return innermost visit (s) {
    // assumes widget at the top. 
    // BUG: there's something wrong with putting two *-things back in...
    //case (Style)`{widget <WidgetType wt1> <Style* s2> widget <WidgetType wt2> <Style* s3>}`
    //   => (Style)`{widget <WidgetType wt1> <Style* s2> <Style* s3>}`
    case (Rule)`{<Rule* rs1> default <Type t> <Style y> <Rule* rs2>}` 
       => (Rule)`{<Rule* rs1> <Rule* rs2>}`
   }
  }
  return s;
}

Stylesheet moveWidgetsToTop(Stylesheet s) {
  return visit (s) { // NB: don't do innermost
    case (Style)`{<Style* s1> widget <WidgetType wt> <Style* s2>}` =>
      (Style)`{widget <WidgetType wt> <Style* s1> <Style* s2>}`
  }
}

Stylesheet applyDefaultStyles(Stylesheet s) {
  return top-down-break visit (s) {
    case Rule r => applyDefaultStyles(r, ())
  }
}
  //= (Stylesheet)`stylesheet <Id n> <Rule r2>`
  //when r2 := applyDefaultStyles(r, ());

Rule applyDefaultStyles(r:(Rule)`{<Rule* rs>}`, map[Type, Style] env) {
  env += ( t: y | d:(Rule)`default <Type t> <Style y>` <- rs );
  return top-down-break visit (r) {
    case (Rule)`section <String t> <Rule r>` => (Rule)`section <String t> <Rule r2>` 
      when r2 := applyDefaultStyles(r, env)

    case (Rule)`<Question q> <Style y>` => (Rule)`<Question q> <Style d>`
      when q.\type in env, d := merge(y, env[q.\type])
  }
}

Style merge((Style)`{<Style* s1>}`, (Style)`{<Style* s2>}`)
  = (Style)`{<Style* s1> <Style* s2>}`;  
  
Style merge(Style s1, s2:(Style)`{<Style* _>}`) = (Style)`{<Style s1> <Style* s2>}`
  when !(s1 is group);  
    
Style merge((Style)`{<Style* s1>}`, Style s2) = (Style)`{<Style* s1> <Style s2>}`
  when !(s2 is group);  
  
default Style merge(Style s1, Style s2) = (Style)`{<Style s1> <Style s2>}`;
