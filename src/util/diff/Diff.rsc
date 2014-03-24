module util::diff::Diff

extend lang::std::Layout;

start syntax Diff
  = diff: "diff" "{" Config* config Edit* edits "}"
  ;
  
syntax Config
  = source: "source" "=" Path path
  | target: "target" "=" Path path
  | \syntax: "syntax" "=" Module module
  ;
  
syntax Edit
  = replace: "replace" Id name Area source  "with"  Fragment fragment Area target
  | \insert: "insert" Id name Fragment fragment Area target "at" Nat position "in" Area source 
  | delete: "delete" Id name Nat position "in" Area source
  ;
  
syntax Area
  = Area: "(" Nat offset "," Nat length "," LineCol begin "," LineCol end ")"
  ;
   
syntax LineCol
  = "\<" Nat line "," Nat column "\>"
  ;
    
lexical Id
  = [_a-zA-Z][_a-zA-Z0-9]* !>> [_a-zA-Z0-9]
  ; 
    
lexical Path
  = [a-zA-Z_\-0-9/.]+ !>> [a-zA-Z_\-0-9/.]
  ;
  
lexical Nat
  = [0]
  | [1-9][0-9]* !>> [0-9]
  ;
  
lexical Module
  = {Id "::"}+
  ;

lexical Fragment
  = "[[" Content content "]]"
  ;
  

lexical Content
  = FragElt*
  ;  

lexical FragElt
  = ![\[\]]
  | [\[] !>> [\[]
  | [\]] !>> [\]]
  | Fragment
  ;