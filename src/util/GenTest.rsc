module util::GenTest

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
import ValueIO;
import util::Math;

private int MAXQ = 10;
private int STEP = 10;

void mergeCSVs() {
  parsing = readTextValueFile(#lrel[int,num], |project://QL-LWC14/output/parse.csv|);
  binding = readTextValueFile(#lrel[int,num], |project://QL-LWC14/output/bind.csv|);
  checking = readTextValueFile(#lrel[int,num], |project://QL-LWC14/output/typecheck.csv|);
  compiling = readTextValueFile(#lrel[int,num], |project://QL-LWC14/output/compile.csv|);
  csv = [];
  
  num toS(num ns) = toReal(ns) / 1000000000.0;
  println(size(parsing));
  for (i <- [0..size(parsing)]) {
    csv += [<parsing[i][0], 
             toS(parsing[i][1]), 
             toS(binding[i][1]), 
             toS(checking[i][1]), 
             toS(compiling[i][1])>]; 
  }
  myWriteCSV(csv, |project://QL-LWC14/output/benchmarks.csv|); 
}

void myWriteCSV(lrel[num, num, num, num, num] csv, loc out) {
  bool first = true;
  for (<a, b, c, d, e> <- csv) {
    line = "<a>,<b>,<c>,<d>,<e>\n";
    if (first) {
      writeFile(out, line);
      first = false;
    }
    else {
      appendToFile(out, line);
    }
  }
}


void main(list[value] args) {
  benchmarkAll();
}

void benchmarkAll() {
  // trigger pgen
  parseQL("form bla {}");


  // Parse
  benchmarkIt(|project://QL-LWC14/output/parse.csv|,
    str(str src) { return src; },
    void(str src) {
      // bug in type checker? Assign does not work.
      parseQL(src);
    });

  benchmarkBind();
  benchmarkCheck();
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
  for (i <- [0,STEP..MAXQ]) {
    println("i = <i>");
    src = binForm(1, i);
    &T t = pre(src);
    bm[size(src)] = cpuTime(() { doIt(t); });
  }

  csv = [ <k, bm[k]> | k <- sort(toList(bm<0>))];
  writeTextValueFile(out, csv);
  return bm;
}



str binForm(int min, int max) 
  = "form binary {
    '  <binFormRec(min, max)>
   '}"; 

str binFormRec(int min, int max) 
  = "\"The answer is\" answer_<min>_<max>: integer = (<min>)"
  when max - min <= 1;

default str binFormRec(int min, int max)
  = "\"Is the number between <min> and <half>\" x_<min>_<half>: boolean
    'if (x_<min>_<half>) { 
    '  <binFormRec(min, half)>
    '}
    'else { 
    '  <binFormRec(half, max)>
    '}"
  when half := min + ((max - min) / 2);
