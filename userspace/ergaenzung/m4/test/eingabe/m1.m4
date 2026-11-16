define(`greet', `Hello, $1!')dnl
greet(World) greet(`a, b')
define(`pair', `<$1|$2|$3>')dnl
pair(x,y) pair(x) pair( p , q , r )
define(`two', `$1$1')dnl
two(two(ab))
define(`empty')dnl
[empty]
undefine(`greet')dnl
greet(World) greet
define(`ap', `a$1p')dnl
ap(`pp')
# a comment with define(x,y) stays
define(`q', `$1')dnl
q(`(unbalanced')
q((nested (parens)) end)
