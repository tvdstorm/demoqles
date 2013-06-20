module lang::muql::Plugin

//import lang::muql::qls::Check;
import lang::muql::ql::QL;
import lang::muql::ql::Bind;
import lang::muql::ql::Check;
import lang::muql::ql::Outline;
import lang::muql::ql::Form2HTML;


import ParseTree;
import util::IDE;
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
      throw "Error: not a form";
      messages = buildAndReturnMessages(implode(input), getCompileTarget());
      return messages;
    })
  };
  
  registerContributions(MU_QL, contribs);
}