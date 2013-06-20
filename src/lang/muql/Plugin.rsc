module lang::muql::Plugin

//import lang::muql::qls::Check;
import lang::muql::ql::QL;
import lang::muql::ql::Bind;
import lang::muql::ql::Check;
import lang::muql::ql::Outline;
import lang::muql::ql::Form2HTML;
import lang::muql::qls::QLS;
import lang::muql::qls::Check;
import lang::muql::qls::Sheet2HTML;


import ParseTree;
import util::IDE;
import Message;
import IO;

private str MU_QL ="MuQL";
private str MU_QLS ="MuQLS";

public void setupMuQL() {
  registerLanguage(MU_QL, "mql", Tree(str src, loc l) {
    return parse(#start[Form], src, l);
  });
  
  contribs = {
     outliner(node(Tree pt) {
      if (Form f := pt.args[1]) {
        return outline(f);
      }
      throw "Error: not a form";
    }),
    
//    annotator(start[Form](start[Form] pt) {
    annotator(Tree(Tree pt) {
      if (Form f := pt.args[1]) {
        f_and_defs = definitions(f);
        f = bind(f_and_defs[0], f_and_defs[1]);
        msgs = tc(f);
        pt.args[1] = f;
        return pt[@messages=msgs];
      }
      throw "Error: not a form";
    }),
    
    builder(set[Message] (Tree pt) {
      if (Form f := pt.args[1]) {
        f_and_defs = definitions(f);
        f = bind(f_and_defs[0], f_and_defs[1]);
        msgs = tc(f);
        if (msgs == {}) {
          l = pt@\loc;
          l.extension= "html";
          writeFile(l, ql2html(f));
        }
        return msgs;
      }
      throw {error("Not a form")};
    })
  };
  
  registerContributions(MU_QL, contribs);
}


public void setupMuQLS() {
  registerLanguage(MU_QLS, "mqls", Tree(str src, loc l) {
    return parse(#start[Stylesheet], src, l);
  });
  
  contribs = {
    
//    annotator(start[Form](start[Form] pt) {
    annotator(Tree(Tree pt) {
       msgs = doWithSheetAndForm(pt, check);
       return pt[@messages=msgs];
    }),
    
    builder(set[Message] (Tree pt) {
      set[Message] doit(Stylesheet s, Form f) {
        l = pt@\loc;
        l.extension = "html";
        writeFile(l, qls2html(s, f));
        return {};
      }
      return doWithSheetAndForm(pt, doit);
    })
  };
  
  registerContributions(MU_QLS, contribs);
}


set[Message] doWithSheetAndForm(Tree pt, set[Message](Stylesheet, Form) doit) {
  if (Stylesheet s := pt.args[1]) {
    l = s@\loc;
    l.extension = "mql";
    try {
      pt2 = parse(#start[Form], l);
      if (Form f := pt2.args[1]) {
        f_and_defs = definitions(f);
        f = bind(f_and_defs[0], f_and_defs[1]);
        msgs = tc(f);
        if (msgs == {}) {
          return doit(s, f);
        }
        return {error("QL file has errors", s.name@\loc)};
      }
      return {error("BUG: QL file is not valid", s.name@\loc)};
    }
    catch _: 
      return {error("Can\'t parse QL file", s.name@\loc)};
  }
  return {error("BUG: Not a sheet", pt@\loc)};
}