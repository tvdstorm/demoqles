module lang::muql::qls::Sheet2HTML

import lang::muql::qls::Normalize;
extend lang::muql::ql::Form2HTML;

alias Result = tuple[rel[Var, Style], list[Widget]];


/*
 Presupposes normalization which has the questions inlined into 
 the style sheet
 So we can assume
 - there are only questions at the leaves in the sheet
 - all questions have a style 
 - if there's widget it is the first style element.
 
*/     

str sheet2html(Stylesheet s) {
  int n = 0;
  return "<for (p <- s.pages) {>
         ' <page2html(p, n)>
         '<n += 1; }>"; 
}

str page2html((Page)`page <Id n> <Rule r>`, int n) 
  = "\<div id=\"<n>:page\" data-bind=\"visible: ($page === <n>)\"\>
    '  <rule2html(r, 1)>
    '  \<button data-bind=\"click: $prevPage\"\>Previous\</button\>
    '  \<button data-bind=\"click: $nextPage\"\>Next\</button\>
    '\</div\>";

str rule2html((Rule)`{<Rule* rs>}`, int level)
  = ( "" | it + rule2html(r) + "\n" | r <- rs );
  
list[Widget] rule2html((Rule)`section <String t> <Rule r>`)
  = "\<h<level>\><t>\</h<level>\>
    '<rule2html(r, level + 1)>";
  
str rule2html((Rule)`<Question q> {widget <WidgetType w> <Style* ys>}`)
  = p(span((Style)`{<Style* ys>}`, widget2widget(w, q)));  
  
default str rule2html((Rule)`<Question q> <Style y>`)
  = p(span(y, question2html(q)));

str widget2widget((WidgetType)`slider(<Integer a>, <Integer b>, <Integer c>)`, q)
  = "\<input type=\"range\" min=\"<a>\" max=\"<b>\" step=\"<c>\" 
    '   name=\"<qname(q)>\" id=\"<qName(q)>\" /\>";
  
str widget2widget((WidgetType)`spinbox`, q)
  = "\<input type=\"number\" 
    '   name=\"<qname(q)>\" id=\"<qName(q)>\" /\>";
  
str widget2widget((WidgetType)`radio(<String yes>, <String no>)`, q)
  = "\<div\>
    '  \<input type=\"radio\" name=\"<qName(q)>\" id=\"<qName(q)>\" 
    '     value=\"true\" data-bind=\"checked: <qName(q)>\"  /\>
    '    <yes>
    '\</div\>
    '\<div\>
    '  \<input type=\"radio\" name=\"<qName(q)>\" id=\"<qName(q)>\" 
    '     value=\"false\" data-bind=\"checked: <qName(q)>\" /\>
    '    <no>
    '\</div\>";
  
str p(str x) = "\<p\><x>\</p\>"; 
  
str span(Style y, str s) = "\<span style=\"<style2css(y)>\"\><s>\</span\>";

str style2css((Style)`{<Style* ys>}`) = ( "" | it + style2css(y) | y <- ys );
str style2css((Style)`<Id n>: <Value v>`) = "<n>: <v>; ";
// no widgets here.

