echo '--- split -3 s.txt pre; ls pre*; cat preaa; echo ==; cat preab; echo ==; cat preac'
split -3 s.txt pre; ls pre*; cat preaa; echo ==; cat preab; echo ==; cat preac
echo '--- rm pre*; cat s.txt | split -2 - q; ls q*; cat qad'
rm pre*; cat s.txt | split -2 - q; ls q*; cat qad
echo '--- rm q*; split s.txt; ls x*; cat xaa | wc -l'
rm q*; split s.txt; ls x*; cat xaa | wc -l
