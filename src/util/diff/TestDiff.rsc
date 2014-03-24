module util::diff::TestDiff

import util::diff::PTDiff;
import util::diff::DiffAST;
import lang::ql::QL;
import ParseTree;
import IO;


void testTax() {
  pt1 = parse(#start[Form], |project://QL-LWC14/input/tax.dql|);
  pt2 = parse(#start[Form], |project://QL-LWC14/input/tax2.dql|);
  d = ptDiff(pt1.top, pt2.top, "lang::missgrant::base::Syntax");
  dsrc = ppDiff(d);
  writeFile(|project://QL-LWC14/input/tax.diff|, dsrc);
  println(dsrc);
}