module lang::ql::Expr2JS

import lang::ql::QL;

str expr2js(e:(Expr)`<Id x>`) = "<x>"; 
str expr2js((Expr)`(<Expr e>)`) = "(<expr2js(e)>)";
str expr2js((Expr)`<Integer x>`) = "<x>";
str expr2js((Expr)`true`) = "true";
str expr2js((Expr)`false`) = "false";
str expr2js((Expr)`<String x>`) = "<x>";
str expr2js((Expr)`!<Expr e>`) = "!(<expr2js(e)>)";

str expr2js((Expr)`<Expr lhs> * <Expr rhs>`)   = "<expr2js(lhs)> * <expr2js(rhs)>";
str expr2js((Expr)`<Expr lhs> / <Expr rhs>`)   = "<expr2js(lhs)> / <expr2js(rhs)>";
str expr2js((Expr)`<Expr lhs> + <Expr rhs>`)   = "<expr2js(lhs)> + <expr2js(rhs)>";
str expr2js((Expr)`<Expr lhs> - <Expr rhs>`)   = "<expr2js(lhs)> - <expr2js(rhs)>";
str expr2js((Expr)`<Expr lhs> \> <Expr rhs>`)  = "<expr2js(lhs)> \> <expr2js(rhs)>";
str expr2js((Expr)`<Expr lhs> \>= <Expr rhs>`) = "<expr2js(lhs)> \>= <expr2js(rhs)>";
str expr2js((Expr)`<Expr lhs> \< <Expr rhs>`)  = "<expr2js(lhs)> \< <expr2js(rhs)>";
str expr2js((Expr)`<Expr lhs> \<= <Expr rhs>`) = "<expr2js(lhs)> \>= <expr2js(rhs)>";
str expr2js((Expr)`<Expr lhs> == <Expr rhs>`)  = "<expr2js(lhs)> === <expr2js(rhs)>";
str expr2js((Expr)`<Expr lhs> != <Expr rhs>`)  = "<expr2js(lhs)> !== <expr2js(rhs)>";
str expr2js((Expr)`<Expr lhs> && <Expr rhs>`)  = "<expr2js(lhs)> && <expr2js(rhs)>";
str expr2js((Expr)`<Expr lhs> || <Expr rhs>`)  = "<expr2js(lhs)> || <expr2js(rhs)>";