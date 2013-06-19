module lang::muql::qls::QLS

extend lang::muql::ql::Lexical;

start syntax Stylesheet
  = stylesheet: "stylesheet" Id name "{" Rule* rules "}";

syntax Rule
  = page: "page" String title Rule rule
  | section: "section" String title Rule rule
  | question: "question" Var name
  | styledQuestion: "question" Var name Style style
  | defaultStyle: "default" Type type Style style
  | @Foldable group: "{" Rule* rules "}"
  ;

syntax Style
  = style: Id property ":" Value val
  | widget: "widget" Widget widget
  | group: "{" Style* styles "}"
  ;
  
syntax Widget
  = "checkbox"
  | "textbox"
  | "slider" "(" Integer "," Integer "," Integer ")"
  | "spinbox"
  | "radio" "(" String "," String ")" 
  ;

syntax Value
  = integer: Integer
  | money: Money
  | string: String
  | symbol: Id
  | color: Color
  ;
  
lexical Color
  = @category="Constant" [#][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F];
  