module lang::qla::Parse

import lang::qla::QL;
import ParseTree;


start[Form] parseQL(loc l) = parse(#start[Form], l);
start[Form] parseQL(str src) = parse(#start[Form], src);