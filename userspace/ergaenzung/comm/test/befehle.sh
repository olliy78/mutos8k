echo '--- comm a.txt b.txt'
comm a.txt b.txt
echo '--- comm -12 a.txt b.txt'
comm -12 a.txt b.txt
echo '--- comm -3 a.txt b.txt'
comm -3 a.txt b.txt
echo '--- comm -23 a.txt b.txt'
comm -23 a.txt b.txt
echo '--- comm -13 a.txt b.txt'
comm -13 a.txt b.txt
echo '--- comm -123 a.txt b.txt'
comm -123 a.txt b.txt
echo '--- cat b.txt | comm a.txt -'
cat b.txt | comm a.txt -
