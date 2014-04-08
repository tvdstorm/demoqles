module diff::IDE

import diff::Parse;
import util::Maybe;
import Grammar;
import lang::qla::QL;
import util::IDE;
import diff::Annotate;

// Be sure not to mix host and diff grammar into same namespace
// this (currently) breaks parser generator because of overlapping
// layouts.

// to be extended
default Maybe[Grammar] objectGrammar() 
  = just(grammar({}, #Form.definitions)); 
 // nothing();

void setupDiffIDE() {
  registerLanguage("DiffSyntax", "difftax", Tree (str src, loc l) {
    if (nothing() := objectGrammar()) {
      return parseDiff(src, l);
    }
    else {
      return parseDiff(src, l, objectGrammar().val, "QL-LWC14");
    }
  });
  
  registerContributions("DiffSyntax", {
    annotator(Tree (Tree input) {
       return installHyperlinks(input, "QL-LWC14");
    }),
    outliner(outlinerer("QL-LwC14"))
  });
  
  // annotator: set hyperlinks to source and target
  // outliner: sort acc. to replace, insert, delete.
}

