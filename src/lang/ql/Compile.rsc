module lang::ql::Compile

import lang::ql::QL;
import ParseTree;
import Set;

str form2js(Form f) =
  "$(document).ready(function () {
  '  <for (q <- f.questions) {>
  '  <question2decl(q, "form")>
  '  <}>
  '  $(\'#QL-content\').append(form.domElement());
  '  form.activate();
  '  function persist(data) {
  '     localStorage[\'QL-persist\'] = JSON.stringify(data);
  '  }
  '});";

str question2decl(qc:(Question)`if (<Expr e>) <Question q>`, str parent) 
  = "var <nameFor(qc)> = <cond2group(e)>;
    '<question2decl(q, nameFor(qc))>";

str question2decl((Question)`if (<Expr e>) <Question q1> else <Question q2>`, str parent) 
  = question2decl((Question)`if (<Expr e>) <Question q1>`, parent)
  + "\n" 
  + question2decl((Question)`if (!(<Expr e>)) <Question q2>`, parent);


str question2decl((Question)`{<Question* qs>}`, str parent)
  = ( "" | it + "\n" + question2decl(q, parent) | q <- qs );

str question2decl((Question)`<Label l> <Var v>: <Type t>`)
  = question2widget(l, v, t, parent, "");

str question2decl((Question)`<Label l> <Var v>: <Type t> = <Expr e>`)
  = question2widget(l, v, t, parent, exp2lazyValue(e));

str question2widget(Label l, Var v, Type t, str parent, str e)
  = "var <v> = new QLrt.SimpleFormElementWidget({
    '  name: \"<v>\", 
    '  label: \"<l>\",
    '  valueWidget: new QLrt.<type2widget(t)>(<e>) 
    '}).appendTo(<parent>);";

str cond2group(Expr e)
  = "new QLrt.ConditionalGroupWidget(<exp2lazyValue(e)>)";
    
str exp2lazyValue(Expr e) 
  = "new QLrt.LazyValue(
    '  function () { return [<expParams(e)>]; },
    '  function (<expParams(e)>) { return <exp2js(e)>; }
    ')";

str nameFor(Question q) = "q<q@\loc.offset>";

str type2widget((Type)`boolean`) = "BooleanValueWidget";
str type2widget((Type)`money`)   = "MoneyValueWidget";
str type2widget((Type)`string`)  = "StringValueWidget";
str type2widget((Type)`integer`) = "IntegerValueWidget";

list[str] freeVars(Exp e) =  sort({ x | /Id x := e });

str expParams(Exp e) = intercalate(", ", freeVars(e));
  