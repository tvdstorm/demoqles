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

void setupDiffIDE(type[&T<:Tree] sort, str project) {
  registerLanguage("Generic Diff", "gdiff", Tree (str src, loc l) {
    g = grammar({}, sort.definitions);
    return parseDiff(src, l, g, project);
  });
  
  registerContributions("Generic Diff", {
    annotator(Tree (Tree input) {
       return installHyperlinks(input, project);
    }),
    outliner(outlinerer(project))
  });
  
}

