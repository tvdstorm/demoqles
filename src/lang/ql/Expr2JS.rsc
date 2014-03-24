module lang::ql::Expr2JS

import lang::ql::QL;

alias WrapVar = str(Expr var);

str expr2js(e:(Expr)`<Id x>`, WrapVar wrap) = wrap(e); 
str expr2js((Expr)`(<Expr e>)`, WrapVar wrap) = "(<expr2js(e, wrap)>)";
str expr2js((Expr)`<Integer x>`, WrapVar wrap) = "<x>";
str expr2js((Expr)`true`, WrapVar wrap) = "true";
str expr2js((Expr)`false`, WrapVar wrap) = "false";
str expr2js((Expr)`<String x>`, WrapVar wrap) = "<x>";
str expr2js((Expr)`!<Expr e>`, WrapVar wrap) = "!(<expr2js(e, wrap)>)";
str expr2js((Expr)`<Expr lhs> * <Expr rhs>`, WrapVar wrap) = "<expr2js(lhs, wrap)> * <expr2js(rhs, wrap)>";
str expr2js((Expr)`<Expr lhs> / <Expr rhs>`, WrapVar wrap) = "<expr2js(lhs, wrap)> / <expr2js(rhs, wrap)>";
str expr2js((Expr)`<Expr lhs> + <Expr rhs>`, WrapVar wrap) = "<expr2js(lhs, wrap)> + <expr2js(rhs, wrap)>";
str expr2js((Expr)`<Expr lhs> - <Expr rhs>`, WrapVar wrap) = "<expr2js(lhs, wrap)> - <expr2js(rhs, wrap)>";
str expr2js((Expr)`<Expr lhs> \> <Expr rhs>`, WrapVar wrap) = "<expr2js(lhs, wrap)> \> <expr2js(rhs, wrap)>";
str expr2js((Expr)`<Expr lhs> \>= <Expr rhs>`, WrapVar wrap) = "<expr2js(lhs, wrap)> \>= <expr2js(rhs, wrap)>";
str expr2js((Expr)`<Expr lhs> \< <Expr rhs>`, WrapVar wrap) = "<expr2js(lhs, wrap)> \< <expr2js(rhs, wrap)>";
str expr2js((Expr)`<Expr lhs> \<= <Expr rhs>`, WrapVar wrap) = "<expr2js(lhs, wrap)> \>= <expr2js(rhs, wrap)>";
str expr2js((Expr)`<Expr lhs> == <Expr rhs>`, WrapVar wrap) = "<expr2js(lhs, wrap)> === <expr2js(rhs, wrap)>";
str expr2js((Expr)`<Expr lhs> != <Expr rhs>`, WrapVar wrap) = "<expr2js(lhs, wrap)> !== <expr2js(rhs, wrap)>";
str expr2js((Expr)`<Expr lhs> && <Expr rhs>`, WrapVar wrap) = "<expr2js(lhs, wrap)> && <expr2js(rhs, wrap)>";
str expr2js((Expr)`<Expr lhs> || <Expr rhs>`, WrapVar wrap) = "<expr2js(lhs, wrap)> || <expr2js(rhs, wrap)>";