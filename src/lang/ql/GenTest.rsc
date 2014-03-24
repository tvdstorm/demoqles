module lang::ql::GenTest

import IO;
import lang::ql::QL;
import lang::ql::Bind;
import lang::ql::Check;
import lang::ql::Types;
import lang::ql::Compile;

import ParseTree;
import util::Benchmark;
import Set;
import List;
import String;
import lang::csv::IO;


void benchmarkAll() {
  // Parse
  benchmarkIt(|project://QL-LWC14/output/parse.csv|,
    str(str src) { return src; },
    start[Form](str src) {
      return parse(#start[Form], src);
    });

  // Bind
  benchmarkIt(|project://QL-LWC14/output/bind.csv|,
    Form(str src) {
      return parse(#start[Form], src).top;
    },
    Form(Form f) {
      rel[str, loc, QLType] defs = {};
      <f, defs> = definitions(f);
      return bind(f, defs);
    });

  // Typecheck
  benchmarkIt(|project://QL-LWC14/output/typecheck.csv|,
    Form(str src) {
      Tree pt = parse(#start[Form], src);
      Form f = pt.top;
      rel[str, loc, QLType] defs = {};
      <f, defs> = definitions(f);
      return bind(f, defs);
    }, checkForm);
     

 // Compile
  benchmarkIt(|project://QL-LWC14/output/compile.csv|, 
    Form(str src) {
      return parse(#start[Form], src).top;
    }, form2js);
}

map[int, num] benchmarkIt(loc out, &T(str) pre, value(&T) doIt) {
  bm = ();  
  for (i <- [0,10..1001]) {
    println("i = <i>");
    src = binForm(1, i);
    &T t = pre(src);
    bm[size(src)] = cpuTime(() { doIt(t); });
  }

  csv = [ <k, bm[k]> | k <- sort(toList(bm<0>))];
  writeCSV(csv, out);
  return bm;
}


str binForm(int min, int max) {
  return "form binary {
         '  <recBin(min, max)>
         '}"; 
}

str recBin(int min, int max) {
  //println("min = <min>, max = <max>");

  if (max - min <= 1) {
    return "\"The answer is\" answer_<min>_<max>: integer = (<min>)";
  }

  half = min + ((max - min) / 2);
  
  return "\"Is the number between <min> and <half>\" x_<min>_<half>: boolean
         'if (x_<min>_<half>) { 
         '  <recBin(min, half)>
         '}
         'else { 
         '  <recBin(half, max)>
         '}";
}