package lexer

import "core:strings"
import "core:unicode"
import "core:strconv"
import "core:fmt"

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


Lexer :: struct {
  data: string,
  pos: int,
}

make :: proc(data: string) -> Lexer {
  return Lexer {
    data = data,
    pos = 0,
  }
}

current :: proc(self:^Lexer) -> u8 {
  return self.data[self.pos]
  // return self.data[self.pos:self.pos+1]
  // self.pos+=1;
  // return result
}
take :: proc(self:^Lexer) -> u8 {
  result := self.data[self.pos]
  self.pos+=1
  return result
}

advance :: proc(self:^Lexer) {
  self.pos+=1
}
peek :: proc(self:^Lexer) -> u8 {
  return self.data[self.pos+1]
}


run :: proc(self:^Lexer) ->  [dynamic]Token {
  tokens :[dynamic]Token
  // append(&tokens, Token{.I32, i32(1001)})

  length := len(self.data)
  for ;self.pos<length; {
    ch := current(self);
    switch {
      case unicode.is_digit(rune(ch)):{
        pos:=self.pos
        for ;self.pos < length-1 && unicode.is_digit(rune(peek(self)));{advance(self) }
        advance(self)
        num, ok := strconv.parse_int(self.data[pos:self.pos],10);
        append(&tokens, Token{.I32, num})
      }
      case rune(ch) == '+':
        append(&tokens, Token{.Op, rune(ch)})
        advance(self)
      case rune(ch) == '*':
        append(&tokens, Token{.Op, rune(ch)})
        advance(self)
      case unicode.is_white_space(rune(ch)):
        advance(self)
      case: 
        error := strings.builder_make_none()
        panic(fmt.sbprintf(&error, "Unknown token: {}\n", rune(ch)))
        // lexer_advance(self)
    }
  }
  append(&tokens, Token{.EOF, true})

  return tokens
  
}
