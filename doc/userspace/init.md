# /etc/init -- erste Befunde (Branch userspace-herkunft)

Alles *gemessen*, soweit nicht als Annahme markiert.

## Gewinnung
    k1520disktool get disks/gebaut/a5120_mutos8000_root_mfm.hfe etc/init --to userspace/init/work
    tail -c +17 etc/init > init.raw          # a.out-Kopf (16 B) ab, Textanfang = Adresse 0
    z8kdis --karte userspace/init/k.txt --statistik init.raw    # nichtsegmentiert (Z8002-Modus)
`k.txt` = `seg` + `code 0` + die von `--vorschlaege` gelieferten Einstiege (ein Durchlauf genuegt).
Datei 4978 B, gestrippt (`flag 1`), Code 4350 B (87,7 %), 612 B unerreicht = Texte/Daten ab 1204.

## Vorlage
* **Nicht** `original/unix-v7/.../init.c`: Zeichenketten `/bin/login` und `single user ` fehlen dort.
  Sie stehen im Hippe-Binary `original/hippe-v7/etc/init` (PDP-11, 4810 B); dessen Quelle liegt in
  `hippe-v7/usr/src/cmd` **nicht** vor.  Annahme: MUTOS-`init` ist ein Verwandter der Hippe-Variante.
* Textpool MUTOS (ab 1204): /bin/sh, /etc/getty, /etc/rc, /etc/ttys, /etc/utmp, /usr/adm/wtmp,
  /dev/console, /dev/, /bin/login, "single user ", "null" (Hippe: "(null)").
* Struktur: Startcode 0000 (crt0: argc/argv, `exit`), `main` 0030 mit `setjmp`, `signal(SIGHUP, reset)`
  und **zusaetzlich** `signal(15, 0398)` (V7 hat das nicht), dann Schleife shutdown 0084, single 011C,
  runcom 01BA, ein `open`/`close`-Paar auf `/etc/utmp` (122C), 0398, multiple 0218 -- Reihenfolge
  weicht von V7 (`shutdown single runcom merge multiple`) ab.  Nur 3 Funktionen mit `csv`-Prolog (11E6).
* Libc-Aufrufe (Adressen): signal 10F6, setjmp 0F0E, close 0FD2, open 0FE6, kill/wait 1062/11A8, alarm 0F98.
  Namen aus `libc_signaturen.txt` noch nicht abgeglichen.

## Offen
Gast-Bau von V7-`init.c` (Basislinie) und Anpassung bis zur Bytegleichheit; Hippe-PDP-11-`init`
als Strukturvorlage disassemblieren (kein PDP-11-Disassembler im Repo geprueft).
