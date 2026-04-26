package main

import "core:fmt"
import "lexer"


main :: proc() {
  data := "20+50*2"

  l := lexer.make(data)
  tokens := lexer.run(&l)
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
