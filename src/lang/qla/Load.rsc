module lang::qla::Load

import lang::qla::Parse;
import lang::qla::AST;
import lang::qla::QL;
import ParseTree;

lang::qla::AST::Form load(loc l) = implodeQL(parseQL(l).top);
lang::qla::AST::Form load(str src) = implodeQL(parseQL(src).top);


lang::qla::AST::Form implodeQL(lang::qla::QL::Form f) 
  = implode(#lang::qla::AST::Form, f);