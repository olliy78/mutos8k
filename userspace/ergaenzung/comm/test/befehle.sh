cat <<'MARK'
--- comm a.txt b.txt
MARK
comm a.txt b.txt
cat <<'MARK'
--- comm -12 a.txt b.txt
MARK
comm -12 a.txt b.txt
cat <<'MARK'
--- comm -3 a.txt b.txt
MARK
comm -3 a.txt b.txt
cat <<'MARK'
--- comm -23 a.txt b.txt
MARK
comm -23 a.txt b.txt
cat <<'MARK'
--- comm -13 a.txt b.txt
MARK
comm -13 a.txt b.txt
cat <<'MARK'
--- comm -123 a.txt b.txt
MARK
comm -123 a.txt b.txt
cat <<'MARK'
--- cat b.txt | comm a.txt -
MARK
cat b.txt | comm a.txt -
