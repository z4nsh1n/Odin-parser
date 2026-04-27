package main

import "core:strings"
import "core:os"
import "core:fmt"
import "lexer"
import "parser"
import "core:bufio"
import "core:c/libc"

main :: proc() {
 
  for ;true; {

  fmt.print("> ")
  buf: [2048]byte
  n, err := os.read(os.stdin, buf[:])

  if err != nil{
    panic("Could not read a line")
  }
  data := string(buf[:n])
  if strings.compare(data, "/quit") == 0{
    break;
  }

  l := lexer.make(data)
  tokens := lexer.run(&l)
  // fmt.println(tokens)
  ast := parser.parse(&tokens)
  for a in ast {
    parser.ast_print(a)
    fmt.println("")
  }
  fmt.println("---------------------------------------")
  for a in ast {
    fmt.println(parser.eval(a))
  }
}
}
