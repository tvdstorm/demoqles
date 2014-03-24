module lang::ql::GenTest

import IO;
import lang::ql::QL;
import ParseTree;
import util::Benchmark;
import Set;
import List;
import String;
import lang::csv::IO;

map[str,num] benchmarkBinSearch() {
  cases = ();
  
  // trigger pgen;
  pt = parse(#start[Form], "form bla {}");
  
  void() make(str src) = () { parse(#start[Form], src); };
  
  sizes = ();
  
  for (i <- [0,10..1001]) {
    src = binForm(1, i);
    sizes["<i>"] = size(src);
    cases["<i>"] = make(src);
  }

  b = benchmark(cases, cpuTime);
  csv = [];
  for (k <- sort(toList(b<0>))) {
    println("<k>: <b[k]>");
    csv += [<sizes[k], b[k]>];
  } 
  writeCSV(csv, |project://QL-LWC14/output/parsing.csv|);
  return b;
}

str binForm(int min, int max) {
  return "form binary {
         '  <recBin(min, max)>
         '}"; 
}

str recBin(int min, int max) {
  println("min = <min>, max = <max>");

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