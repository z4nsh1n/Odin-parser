package parser

import "../lexer/"
import "core:fmt"

Ast :: struct {
	left:  ^Ast,
	right: ^Ast,
	token: lexer.Token,
}

// TokenType :: enum {
//   Program,
//   I32,
//   Op,
// }

Parser :: struct {
	lexer_tokens: ^[dynamic]lexer.Token,
	pos:          int,
	ast:          [dynamic]^Ast,
}
eval_int :: proc(ast: ^Ast) -> int {
	return ast.token.data.(int)
}

eval_op :: proc(ast: ^Ast) -> int {
	return 1
}

eval :: proc(ast: ^Ast) -> int {
	#partial switch ast.token.type {
	case lexer.TokenType.I32:
		{
			return eval_int(ast)
		}
	case lexer.TokenType.Op:
		{
			switch ast.token.data.(rune) {
			case '+':
				{
					left := eval(ast.left)
					right := eval(ast.right)
					return left + right
				}
			case '*':
				{
					left := eval(ast.left)
					right := eval(ast.right)
					return left * right
				}
			}
		}
	}
	return -1000
}
ast_print :: proc(ast: ^Ast) {
	fmt.print("(")
	switch v in ast.token.data {
	case bool:
		// fmt.printf("%v %v", ast.token.type, ast.token.data.(bool))
		fmt.printf("%v", ast.token.data.(bool))
	case int:
		fmt.printf("%v", ast.token.data.(int))
	case f32:
		fmt.printf("%v", ast.token.data.(f32))
	case string:
		fmt.printf("%v", ast.token.data.(string))
	case rune:
		fmt.printf("%v", ast.token.data.(rune))
	}
	if ast.left != nil {
		ast_print(ast.left)
	} else {
		fmt.print("")
	}
	if ast.right != nil {
		ast_print(ast.right)
	} else {
		fmt.print("")
	}
	fmt.print(")")
}
parser_is_eof :: proc(self: ^Parser) -> bool {
	return parse_peek(self).type == lexer.TokenType.EOF
}

parse_peek :: proc(self: ^Parser) -> lexer.Token {
	return self.lexer_tokens[self.pos]
}

parse_take :: proc(self: ^Parser) -> lexer.Token {
	token := self.lexer_tokens[self.pos]
	self.pos += 1
	return token
}

parse_int :: proc(self: ^Parser) -> ^Ast {
	left := parse_take(self)
	if left.type != lexer.TokenType.I32 {
		panic("Expected a number")
	}
	ast := new(Ast)
	ast.token = left
	return ast
}
parse_expr :: proc(self: ^Parser) -> ^Ast {
	left := parse_int(self)
	peek := parse_peek(self)
	if peek.type != lexer.TokenType.EOF {
		// ast := new(Ast);
		ast := left
		astr: ^Ast = nil
		if peek.type != lexer.TokenType.Op {
			panic("Expected an operator (* or /)")
		}
		switch peek.data.(rune) {
		case '*':
			{
				op := parse_take(self)

				ast = new(Ast)
				ast.left = left
				ast.token = op
				astr = new(Ast)
				astr = parse_expr(self)
			}
		case '/':
			panic("TODO")
		}
		ast.right = astr
		return ast
	}
	return left
}

parse_term :: proc(self: ^Parser) -> ^Ast {
	left := parse_expr(self)
	peek := parse_peek(self)
	if peek.type != lexer.TokenType.EOF {
		// ast := new(Ast);
		ast := left
		astr: ^Ast = nil
		if peek.type != lexer.TokenType.Op {
			panic("Expected an operator (+ or -)")
		}
		switch peek.data.(rune) {
		case '+':
			{
				op := parse_take(self)

				ast = new(Ast)
				ast.left = left
				ast.token = op
				astr = new(Ast)
				astr = parse_term(self)
			}
		case '-':
			{
				panic("TODO -")
			}
		}
		ast.right = astr
		return ast
	}
	return left
}

parse :: proc(lt: ^[dynamic]lexer.Token) -> [dynamic]^Ast {
	tokens: [dynamic]^Ast
	parser := Parser {
		lexer_tokens = lt,
		ast          = tokens,
	}
	for !parser_is_eof(&parser) {
		append(&parser.ast, parse_term(&parser))
	}
	return parser.ast
}
