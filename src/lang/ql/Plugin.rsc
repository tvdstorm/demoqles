module lang::ql::Plugin

import lang::ql::QL;
import lang::ql::Bind;
import lang::ql::Check;
import lang::ql::Outline;
import lang::ql::Compile;


import ParseTree;
import util::IDE;
import Message;
import IO;

private str DEMO_QL ="DemoQL";
private str DEMO_QLS ="DemoQLS";

public void setupQL() {
  registerLanguage(DEMO_QL, "dql", Tree(str src, loc l) {
    return parse(#start[Form], src, l);
  });
  
  lastMessages = {};
  
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
        msgs = checkForm(f);
        pt.args[1] = f;
        lastMessages = msgs;
        return pt[@messages=msgs];
      }
      return pt[@messages={error("BUG: not a form", pt@\loc)}];
    }),
    
    builder(set[Message] (Tree pt) {
      if (Form f := pt.args[1]) {
        //f_and_defs = definitions(f);
        //f = bind(f_and_defs[0], f_and_defs[1]);
        //msgs = checkForm(f);
        if (lastMessages == {}) {
          js = pt@\loc[extension="js"];
          writeFile(js, form2js(f));
          html = pt@\loc[extension="html"];
          writeFile(html, form2html(f, js));
        }
        return msgs;
      }
      return {error("BUG: Not a form", pt@\loc)};
    })
  };
  
  registerContributions(DEMO_QL, contribs);
}

