# Herkunft von `kernel/c/clock.c` (AP H3)

Stand 2026-10-31.  Quelle: UNIX V7 `usr/sys/sys/clock.c` (`clock`; `timeout` steht in `subr.c`).  Alle Zahlen **gemessen**, sofern nicht als *angenommen* markiert.

## Ergebnis

* **Origin: partial.**  Dateiaehnlichkeit V7 58 % -> 62 %, System III PDP-11 37 % -> 38 %; `clock` 64 % -> 69 % (System III 41 % -> 43 %).
* **Befund entgegen dem alten Dateikopf:** "System-III-Form (WEGA)" ist falsch.  Der Prozessteil ist V7: `p_cpu = (p_cpu & 0377)*SCHMAG + p_nice - NZERO` mit `SCHMAG 8/10`, Obergrenze 255, `setpri` bei `p_pri >= PUSER`, Weckrufe `runin`/`lbolt`.
  System III hat dort `p_cpu >>= 1` und eine andere Prioritaetsformel (`original/sys3/uts/pdp11/os/clock.c`).  Einziger System-III-Anklang: der Signalname `SIGALRM` (V7 `SIGCLK`, beide 14); der Quelltext benutzt jetzt `SIGCLK`.
* Rundlauf: **0 von 1, wie vorher** (210 von 260 Woertern; der Kernel ruft am Anfang ein Hilfsstueck bei 040C auf, `lbolt` laeuft ueber R2 -- Eigenheit des aelteren `c2`, `c_rueckbau.md` K7b).  Der Objekttext hat sich nicht veraendert (520 B, 210/260).
  Der Gesamtbau nimmt `clock` deshalb aus dem Assembler (wie bisher).
* Z8001-Abweichungen (markiert): Unterbrechungseintritt mit Argumenten (Takte `tk>>8`, Prioritaet `ps0&07`, FCW `ps&0x4000`, PC); kein `lks`, kein `display()`, kein `dk_time[]`;
  Zeitzaehlung mit `t` Takten je Aufruf; `proctop`; **eigener Zug:** alle 30 Sekunden (`sflag0 >= 30 && cf_x88a`) `sflag1` erhoehen und `runout` wecken (Scheduler ruft `update()`, siehe `slp.md`) -- weder V7 noch System III, **Fremdzug fuer H6**.
* Rueckfall: keiner (Text nur umgeschrieben, kein Code veraendert).

| Funktion | Kernel | Klasse | Rundlauf |
|---|---|---|---|
| clock | 2842 | veraendert | nahe (210/260, wie vorher) |
