cat <<'MARK'
--- ls -l /bin /usr/bin /usr/lib
MARK
ls -l /bin /usr/bin /usr/lib
cat <<'MARK'
--- find /bin -print
MARK
find /bin -print
cat <<'MARK'
--- find /bin -name s* -print
MARK
find /bin -name 's*' -print
cat <<'MARK'
--- find /usr -type f -name c* -print
MARK
find /usr -type f -name 'c*' -print
cat <<'MARK'
--- find /usr/lib -size +50 -print
MARK
find /usr/lib -size +50 -print
cat <<'MARK'
--- find /usr/lib -size 1 -print
MARK
find /usr/lib -size 1 -print
cat <<'MARK'
--- find /usr/lib -perm 751 -print
MARK
find /usr/lib -perm 751 -print
cat <<'MARK'
--- find /bin -perm -020 -print
MARK
find /bin -perm -020 -print
cat <<'MARK'
--- find /bin ( -name cat -o -name ls ) -print
MARK
find /bin \( -name cat -o -name ls \) -print
cat <<'MARK'
--- find /bin ! -name s* -print
MARK
find /bin ! -name 's*' -print
cat <<'MARK'
--- find /bin /usr/bin -name ?? -print
MARK
find /bin /usr/bin -name '??' -print
cat <<'MARK'
--- find /bin -type d -print
MARK
find /bin -type d -print
cat <<'MARK'
--- find /bin -mtime -1 -print
MARK
find /bin -mtime -1 -print
cat <<'MARK'
--- find /bin -mtime +30 -name d* -print
MARK
find /bin -mtime +30 -name 'd*' -print
cat <<'MARK'
--- find /bin -name sync -exec ls -l {} ;
MARK
find /bin -name sync -exec ls -l {} \;
cat <<'MARK'
--- find /usr/lib -name c? -a -size +40 -print
MARK
find /usr/lib -name 'c?' -a -size +40 -print
