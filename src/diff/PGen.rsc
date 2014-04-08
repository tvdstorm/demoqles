module diff::PGen

import Grammar;
import ParseTree;

@javaClass{diff.PGen}
@reflect{Uses Evaluator generate parsers}
java Tree parse(Grammar grammar, str sort, str src, loc org); 