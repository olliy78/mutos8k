define(`yes', `1')dnl
ifdef(`yes', `defined', `undefined') ifdef(`nope', `defined', `undefined') ifdef(`nope', `defined')
ifelse(a, a, `eq', `ne') ifelse(a, b, `eq', `ne') ifelse(a, b, `eq')
ifelse(a, b, 1, c, c, 2, 3) ifelse(a, b, 1, c, d, 2, 3) ifelse(a, b, 1, c, d, 2)
define(`n', `0')dnl
define(`inc', `define(`n', incr(n))')dnl
inc inc inc n
len(`hello world') len()
index(`hello', `l') index(`hello', `lo') index(`hello', `z')
substr(`hello', 1, 3) substr(`hello', 2) substr(`hello', 0, 1) substr(`hello', 9)
translit(`hello', `el', `ip') translit(`hello', `l') translit(abc, abc, ABC)
incr(41) incr(-1) incr(99)
changequote([, ])dnl
[quoted `text' here] define([x], [y])x
changequote
`back'
