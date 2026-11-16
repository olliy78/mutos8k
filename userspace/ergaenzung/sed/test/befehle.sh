cat <<'MARK'
--- s/foo/FOO/ b.txt
MARK
sed 's/foo/FOO/' b.txt
cat <<'MARK'
--- s/o/0/g
MARK
sed 's/o/0/g' b.txt
cat <<'MARK'
--- s/x/y/ nth-less: first only
MARK
sed 's/a/A/' b.txt
cat <<'MARK'
--- -n 3,5p
MARK
sed -n '3,5p' a.txt
cat <<'MARK'
--- -n $p
MARK
sed -n '$p' a.txt
cat <<'MARK'
--- 2,4d
MARK
sed '2,4d' a.txt
cat <<'MARK'
--- regex range /^f/,/^s/d
MARK
sed '/^f/,/^s/d' a.txt
cat <<'MARK'
--- -n /e$/p
MARK
sed -n '/e$/p' a.txt
cat <<'MARK'
--- 3!d
MARK
sed '3!d' a.txt
cat <<'MARK'
--- 2q
MARK
sed '2q' a.txt
cat <<'MARK'
--- -n /three/,$p
MARK
sed -n '/three/,$p' a.txt
cat <<'MARK'
--- y/abc/xyz/
MARK
sed 'y/abc/xyz/' b.txt
cat <<'MARK'
--- backrefs
MARK
sed 's/\(a\)\(b\)/\2\1/g' b.txt
cat <<'MARK'
--- & in replacement
MARK
sed 's/[aeiou]/(&)/g' b.txt
cat <<'MARK'
--- star
MARK
sed 's/ab*c*/<&>/g' b.txt
cat <<'MARK'
--- anchors and dot
MARK
sed 's/^.../[&]/;s/...$/[&]/' b.txt
cat <<'MARK'
--- -e twice
MARK
sed -e 's/one/1/' -e 's/two/2/' a.txt
cat <<'MARK'
--- -n with p flag
MARK
sed -n 's/e/E/gp' a.txt
cat <<'MARK'
--- a text
MARK
sed '3a\
after three' a.txt
cat <<'MARK'
--- i text
MARK
sed '1i\
HEAD' a.txt
cat <<'MARK'
--- c text
MARK
sed '/five/c\
CHANGED' a.txt
cat <<'MARK'
--- c on range
MARK
sed '2,4c\
RANGE' a.txt
cat <<'MARK'
--- a multi-line text
MARK
sed '$a\
line1\
line2' a.txt
cat <<'MARK'
--- = line numbers
MARK
sed -n '$=' a.txt b.txt
cat <<'MARK'
--- = with p
MARK
sed -n '/five/{=;p;}' a.txt
cat <<'MARK'
--- N join
MARK
sed 'N;s/\n/+/' a.txt
cat <<'MARK'
--- $!N;P;D
MARK
sed '$!N;P;D' a.txt
cat <<'MARK'
--- G double space
MARK
sed G b.txt
cat <<'MARK'
--- tac
MARK
sed -n '1!G;h;$p' a.txt
cat <<'MARK'
--- H x
MARK
sed -n 'H;${x;s/\n/,/g;p;}' a.txt
cat <<'MARK'
--- hold g
MARK
sed -n '2h;4{g;p;}' a.txt
cat <<'MARK'
--- n
MARK
sed -n 'n;p' a.txt
cat <<'MARK'
--- branch b label
MARK
sed ':a
$!{N;ba
}
s/\n/ /g' a.txt
cat <<'MARK'
--- t loop
MARK
sed ':l
s/aa/a/
tl' b.txt
cat <<'MARK'
--- t with s flag
MARK
sed 's/one/1/;ta
y/t/T/
:a' a.txt
cat <<'MARK'
--- b to end
MARK
sed '/t/b
s/$/ !/' a.txt
cat <<'MARK'
--- two files, line numbers continue
MARK
sed -n '8,12p' a.txt b.txt
cat <<'MARK'
--- two files $
MARK
sed -n '$p' a.txt b.txt
cat <<'MARK'
--- stdin
MARK
cat a.txt | sed -n '2p;9p'
cat <<'MARK'
--- -f script
MARK
sed -f s1.sed b.txt
cat <<'MARK'
--- -f and -e accumulate
MARK
sed -e 's/alpha/ALPHA/' -f s1.sed b.txt
cat <<'MARK'
--- r file
MARK
sed '/three/r r.txt' a.txt
cat <<'MARK'
--- w file
MARK
sed -n '/e/w out1.txt' a.txt
cat out1.txt
cat <<'MARK'
--- s///w
MARK
sed 's/t/T/w out2.txt' a.txt >/dev/null
cat out2.txt
cat <<'MARK'
--- { } group with !
MARK
sed -n '2,4!{/e/p;}' a.txt
cat <<'MARK'
--- # n first line
MARK
sed -f n.sed a.txt
cat <<'MARK'
--- different delimiter
MARK
sed 's,e,<&>,;s|t|T|' a.txt
cat <<'MARK'
--- P and \n in RE
MARK
sed -n '/two/{N;/two\nthree/P;}' a.txt
cat <<'MARK'
--- empty regex = last
MARK
sed -n '/th/s//TH/p' a.txt
cat <<'MARK'
--- special: \. and [.]
MARK
sed 's/\./!/;s/[.]/?/' b.txt
cat <<'MARK'
--- class range
MARK
sed 's/[a-c]/#/g' b.txt
cat <<'MARK'
--- neg class
MARK
sed 's/[^a-z]/_/g' b.txt
cat <<'MARK'
--- no match: unchanged
MARK
sed 's/zzz/y/' a.txt | sed -n '$p'
cat <<'MARK'
--- exit codes: q
MARK
sed 3q a.txt >/dev/null
cat <<R
rc=$?
R
cat <<'MARK'
--- l command
MARK
sed -n 'l' t.txt
