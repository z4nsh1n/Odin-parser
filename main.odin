package main

import "core:strconv"
import "core:fmt"
import "core:strings"
import "core:unicode"
import "core:text/match"


TokenType :: enum {
  String,
  I32,
  F32,
  Bool,
  Op,
  EOF,
}

Token :: struct {
  type: TokenType,
  data: union {
    bool,
    int,
    f32,
    string,
    rune,
  }
}

main :: proc() {
  data := "20+50*2"

  l := make_lexer(data)
  tokens := lexer_run(&l)
  fmt.println(tokens)
  // ast := parser_parse(tokens)
  // for ;unicode.is_number(rune(lexer_peek(&l)));{lexer_advance(&l)}
  // fmt.println(string(data[pos:l.pos+1]))

  // t := lexer_current(&l)
  // fmt.println(t)
  // t = lexer_peek(&l)
  // fmt.println(t)
  // lexer_advance(&l)
  // t = lexer_current(&l)
  // fmt.println(t)
  // parse_tree = parse(lex_data)
}

Lexer :: struct {
  data: string,
  pos: int,
}

make_lexer :: proc(data: string) -> Lexer {
  return Lexer {
    data = data,
    pos = 0,
  }
}

lexer_current :: proc(self:^Lexer) -> u8 {
  return self.data[self.pos]
  // return self.data[self.pos:self.pos+1]
  // self.pos+=1;
  // return result
}
lexer_take :: proc(self:^Lexer) -> u8 {
  result := self.data[self.pos]
  self.pos+=1
  return result
}

lexer_advance :: proc(self:^Lexer) {
  self.pos+=1
}
lexer_peek :: proc(self:^Lexer) -> u8 {
  return self.data[self.pos+1]
}


lexer_run :: proc(self:^Lexer) ->  [dynamic]Token {
  tokens :[dynamic]Token
  // append(&tokens, Token{.I32, i32(1001)})

  length := len(self.data)
  for ;self.pos<length; {
    ch := lexer_current(self);
    switch {
      case unicode.is_digit(rune(ch)):{
        pos:=self.pos
        for ;self.pos < length-1 && unicode.is_digit(rune(lexer_peek(self)));{lexer_advance(self) }
        lexer_advance(self)
        num, ok := strconv.parse_int(self.data[pos:self.pos],10);
        append(&tokens, Token{.I32, num})
      }
      case rune(ch) == '+':
        append(&tokens, Token{.Op, rune(ch)})
        lexer_advance(self)
      case rune(ch) == '*':
        append(&tokens, Token{.Op, rune(ch)})
        lexer_advance(self)
      case:
        error := strings.builder_make_none()
        panic(fmt.sbprintf(&error, "Unknown token: {}\n", rune(ch)))
        // lexer_advance(self)
    }
  }
  append(&tokens, Token{.EOF, true})

  return tokens
  
}
