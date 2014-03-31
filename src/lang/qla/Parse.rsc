module lang::qla::Parse

import lang::qla::QL;
import ParseTree;


//start[Form] parseQL(loc l) = parse(#start[Form], l);
//start[Form] parseQL(str src) = parse(#start[Form], src);

Tree parseQL(loc l) = parse(#Form, l);
Tree parseQL(str src) = parse(#Form, src);
