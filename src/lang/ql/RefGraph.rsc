module lang::ql::RefGraph

import lang::ql::Types;

alias Use = rel[loc use, loc def];
alias Def = rel[loc def, QLType typ];

alias Refs = tuple[Use use, Def def];

