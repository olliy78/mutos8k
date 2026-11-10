cat <<'MARK'
--- split -3 s.txt pre; ls pre*; cat preaa preab preac
MARK
split -3 s.txt pre; ls pre*; cat preaa preab preac
cat <<'MARK'
--- cat s.txt | split -2 - q; ls q*; cat qad
MARK
cat s.txt | split -2 - q; ls q*; cat qad
cat <<'MARK'
--- split s.txt; ls x*; cat xaa
MARK
split s.txt; ls x*; cat xaa
