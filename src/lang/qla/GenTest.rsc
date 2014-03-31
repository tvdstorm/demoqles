module lang::qla::GenTest

import IO;
import lang::qla::AST;
import lang::qla::Load;
import lang::qla::Parse;
import lang::qla::Resolve;
import lang::qla::Check;
import lang::qla::Compile;

import ParseTree;
import util::Benchmark;
import Set;
import List;
import String;
import lang::csv::IO;
import util::Math;

void mergeCSVs() {
  parsing = readCSV(#lrel[int,num], |project://QL-LWC14/output/parse.csv|);
  binding = readCSV(#lrel[int,num], |project://QL-LWC14/output/bind.csv|);
  checking = readCSV(#lrel[int,num], |project://QL-LWC14/output/typecheck.csv|);
  compiling = readCSV(#lrel[int,num], |project://QL-LWC14/output/compile.csv|);
  csv = [];
  
  num toS(num ns) = toReal(ns) / 1000000000.0;
  
  for (i <- [0..size(parsing)]) {
    csv += [<parsing[i][0], 
             toS(parsing[i][1]), 
             toS(binding[i][1]), 
             toS(checking[i][1]), 
             toS(compiling[i][1])>]; 
  }
  writeCSV(csv, |project://QL-LWC14/output/benchmarks.csv|); 
}

void benchmarkAll() {
  // trigger pgen
  parseQL("form bla {}");


  // Parse
  benchmarkIt(|project://QL-LWC14/output/parse.csv|,
    str(str src) { return src; },
    start[Form](str src) {
      return parseQL(src);
    });

  benchmarkBind();
  
  benchmarkCompile();
}

map[int,num] benchmarkCheck() =
  benchmarkIt(|project://QL-LWC14/output/typecheck.csv|,
    tuple[Form, Info](str src) {
      Form f = load(src);
      rs = resolve(f);
      return <f, rs>;
    }, value(tuple[Form, Info] tup) {
        return checkForm(tup[0], tup[1]);
    });

map[int, num] benchmarkBind() = 
  benchmarkIt(|project://QL-LWC14/output/bind.csv|,
    Form(str src) {
      return load(src);
    },
    tuple[Form, Info](Form f) {
      rs = resolve(f);
      return <f, rs>;
    });


map[int, num] benchmarkCompile() =
  benchmarkIt(|project://QL-LWC14/output/compile.csv|, 
    Form(str src) {
      return load(src);
    }, form2js);


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