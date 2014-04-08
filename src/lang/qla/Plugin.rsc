module lang::qla::Plugin

import lang::qla::Load;
import lang::qla::Parse;
import lang::qla::Resolve;
import lang::qla::Check;
import lang::qla::Outline;
import lang::qla::Compile;


import diff::PTDiff;
import diff::DiffAST;
import diff::IDE;
import ParseTree;
import util::IDE;
import Message;
import IO;
import lang::qla::QL;
import util::Prompt;
import util::Editors;

private str QLA ="QL";

anno rel[loc,loc, str] Tree@hyperlinks;

rel[loc,loc,str] computeXRef(Info i) 
  = { <u, d, "<l>"> | u <- i.refs.use, d <- i.refs.use[u], 
                      l <- i.labels, d in i.labels[l] }; 

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
      inf = resolve(ast);
      msgs = checkForm(ast, inf);
      return pt[@messages=msgs][@hyperlinks=computeXRef(inf)];
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
    }),
    
    popup(action("Structure diff...", 
       void (Tree pt1, loc selLoc) {
         loc v1 = pt1@\loc;
         path = prompt("Compare with (project local path):");
         loc v2 = |project://QL-LWC14/<path>|;
         try {
           pt2 = parseQL(v2);
           d = ptDiff(pt1, pt2, "lang::qla::QL");
           diffLoc = v1[file="<v1[extension=""].file>_<v2[extension=""].file>"][extension="gdiff"];
           writeFile(diffLoc, ppDiff(d));
           edit(diffLoc, []);
         }
         catch value error:
           alert("Error: <error>");
       }))
  };
  
  registerContributions(QLA, contribs);
  
  setupDiffIDE(#Form, "QL-LWC14");
}


