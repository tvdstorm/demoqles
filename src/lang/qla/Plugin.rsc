module lang::qla::Plugin

import lang::qla::Load;
import lang::qla::Parse;
import lang::qla::Resolve;
import lang::qla::Check;
import lang::qla::Outline;
import lang::qla::Compile;


import ParseTree;
import util::IDE;
import Message;
import IO;

private str DEMO_QL ="DemoQL";
private str DEMO_QLS ="DemoQLS";

anno rel[loc,loc, str] Tree@hyperlinks;

public void setupQL() {
  registerLanguage(DEMO_QL, "dql", Tree(str src, loc l) {
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
        r = resolve(f);
        msgs = checkForm(f, r);
        pt.args[1] = f;
        //[@docStrings=computeDocs(r)]
        return pt[@messages=msgs][@hyperlinks=computeXRef(r)];
      }
      return pt[@messages={error("BUG: not a form", pt@\loc)}];
    }),
    
    builder(set[Message] (Tree pt) {
      if (Form f := pt.args[1]) {
        r = resolve(f);
        msgs = checkForm(f, r);
        if (msgs == {}) {
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

