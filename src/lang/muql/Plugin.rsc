module lang::muql::Plugin

import lang::muql::qls::Check;
import lang::muql::ql::Bind;
import lang::muql::ql::Check;
import lang::muql::ql::Outline;


import ParseTree;
import util::IDE;

private str MU_QL ="MuQL";

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
    })
    //
    //popup(
    //  menu(getQLLangName(),[
    //    action(actionBuild, (Tree tree, loc source) {
    //      build(implode(tree), source);
    //    }),
    //    action(actionFormat, (Tree tree, loc source) {
    //      format(implode(tree), source);
    //    }),
    //    action(actionVisualize, (Tree tree, loc source) {
    //      render(form2figure(implode(tree)));
    //    })
    //  ])
    //), 
    //
    //builder(set[Message] (Tree input) {
    //  messages = buildAndReturnMessages(implode(input), getCompileTarget());
    //  return messages;
    //})
  };
  
  registerContributions(MU_QL, contribs);
}