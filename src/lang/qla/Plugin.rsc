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

private str QLA ="QL";

anno rel[loc,loc, str] Tree@hyperlinks;

public void setupQL() {
  registerLanguage(QLA, "dql", Tree(str src, loc l) {
    return parseQL(src, l);
  });
  
  
  contribs = {
    outliner(node(Tree pt) {
      return outline(implodeQL(pt));
    }),
    
    annotator(Tree(Tree pt) {
      ast = implodeQL(pt);
      msgs = checkForm(ast, resolve(ast));
      return pt[@messages=msgs]; //[@hyperlinks=computeXRef(r)];
    }),
    
    builder(set[Message] (Tree pt) {
      ast = implodeQL(pt);
      msgs = checkForm(ast, resolve(ast));
      if (msgs == {}) {
        js = pt@\loc[extension="js"];
        writeFile(js, form2js(ast));
        html = pt@\loc[extension="html"];
        writeFile(html, form2html(ast, js));
      }
      return msgs;
    })
  };
  
  registerContributions(QLA, contribs);
}

