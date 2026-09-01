---
name: devflow-docs
description: Da invocare esplicitamente quando un lavoro condotto con devflow è concluso e sta per arrivare su main. Trigger: "/devflow-docs", "aggiorna documentazione", "update docs", "scrivi il changelog". Registra la voce di changelog e la versione; non tocca il codice né i documenti del lavoro.
---

# Devflow Docs

Registra su `docs/change-log.md` un lavoro concluso, prima che arrivi su `main`.

## Cosa questa skill NON fa

Elenco vincolante: se ti viene voglia di fare una di queste cose, non farla.

| Non fa | Perché | Dove sta invece |
|---|---|---|
| Non tocca `docs/lavori/` | `STATO.md` e `slices.md` li chiude `devflow` durante il lavoro | Nel ciclo per slice |
| Non crea file in `docs/decisions-log/` | Una decisione si scrive quando la si prende, non quando si riepiloga | `devflow`, alla chiusura di ogni passo |
| Non descrive migrazioni, backfill, segreti | Il changelog racconta cosa è cambiato, non cosa fare in produzione | Nel piano della slice e in `STATO.md` |
| Non pubblica nulla verso l'esterno | Landing, note di rilascio pubbliche, post: li decide l'utente | Fuori dal repo |
| Non propone mai una versione major | La generazione di prodotto è una decisione umana | Passo 2 |
| Non usa `git add -A` né `git add .` | Nel working tree può esserci lavoro estraneo | Passo 6 |

## Quando parte

Solo su invocazione esplicita. Se a fine sessione il lavoro sembra concluso, ricordalo in una riga e fermati: è l'utente a sapere se è finito o se domani continua.

> "Il lavoro sembra concluso: vuoi che aggiorni il changelog? (`/devflow-docs`)"

## Convenzioni

| Cosa | Dove | Se manca |
|---|---|---|
| Changelog | `docs/change-log.md` | Si crea, con un blocco introduttivo di due righe e la prima voce |
| Versione | campo `version` di `package.json` | Si cerca un file `VERSION` o un gemspec; se non c'è niente, si chiede dove vive o si salta il bump dichiarandolo |
| Regola di collocazione del codice | `docs/project-structure.md` | Si ignora |
| Decisioni | `docs/decisions-log/` | Il bullet "Decisione" si omette |

Un `.devflow.yml` alla radice con le chiavi `changelog` e `versione` sovrascrive le prime due. Si legge se c'è, non si crea.

**Lingua**: quella delle voci già presenti nel changelog. Se il changelog è nuovo, quella del resto di `docs/`.

---

## Passo 1 — Capire cosa è stato fatto

```bash
git log main..HEAD --format="%h %ad %s" --date=short
git diff main..HEAD --stat
git status --short
```

Leggi `docs/change-log.md`: le voci esistenti definiscono tono e livello di dettaglio, e la prima in cima porta l'ultima versione assegnata. Leggi `STATO.md` e `slices.md` del lavoro in `docs/lavori/`: le sezioni "V<n> — fatta il" dicono cosa è successo davvero.

Se il branch contiene lavori scollegati fra loro, non forzarli in una voce sola: chiedi se sono uno o due rilasci. Se non è chiaro cosa documentare, chiedi: *"Quale lavoro devo registrare?"*

## Passo 2 — Calcolare la versione

Non è una trattativa: è una regola. Applicala e dichiara il risultato.

| Livello | Criterio |
|---|---|
| **MAJOR** `X.0.0` | Generazione di prodotto. Non proporla mai. Se il lavoro sembra da major, chiedi conferma e fermati |
| **MINOR** `x.Y.0` | L'utente **può fare qualcosa che prima non poteva**: nuova vista, nuovo campo, nuovo filtro, nuovo comando, comportamento visibile diverso |
| **PATCH** `x.y.Z` | Tutto il resto: bug fix, sicurezza, refactor, upgrade di stack, performance, infrastruttura, documentazione |

Il criterio è **cosa cambia per chi usa il prodotto**, non quanto codice è stato toccato: un refactor che muove cinquanta file è un patch; un filtro nuovo che ne muove sei è un minor. Sotto la 1.0 vale la stessa regola.

Dichiara così, senza chiedere il permesso ma lasciando spazio all'obiezione:

> "Registro come **patch** → 1.10.1: il lavoro chiude tre difetti ma non cambia cosa l'utente può fare. Dimmi se lo vedi diversamente."

## Passo 3 — Scrivere la voce

In cima a `docs/change-log.md`, dopo il blocco introduttivo e prima del primo `## v`.

### Formato

```markdown
## vX.Y.Z — YYYY-MM-DD — Titolo breve

Una o due frasi: cosa cambia e perché è stato fatto.

- **Etichetta**: frase in linguaggio piano.
- **Etichetta**: frase in linguaggio piano.
- **Lavoro**: `<slug>`
- **Decisione**: [slug leggibile](decisions-log/YYYY-MM-DD-slug.md)
- **Rilascio**: merge `a1b2c3d`

---
```

### Regole

- **Data**: quella del merge, formato `YYYY-MM-DD`, non quella in cui il lavoro è iniziato.
- **Titolo**: dice cosa è cambiato per chi legge, non il nome del branch. *"Il calendario non va più in crash"*, non *"fix/calendar-null-technician"*.
- **Bullet**: etichetta in grassetto che nomina il concetto, poi una frase piana. Nessun elenco di commit: se il lavoro ne ha quaranta, i bullet restano quattro.
- **Lavoro**: lo slug del lavoro in `docs/lavori/`. È l'aggancio che sopravvive all'archiviazione: `rg "<slug>" docs/change-log.md` deve ritrovare la voce.
- **Decisione**: link ai file di `docs/decisions-log/` che spiegano il perché. Verifica che il file esista prima di linkarlo. Se il lavoro ha preso decisioni che nessun file racconta, segnalalo nel report finale: manca una decisione, ma non è questa skill a scriverla. Ometti il bullet se il repo non ha `decisions-log/`.
- **Rilascio**: lo sha del merge o dei commit diretti. Serve a ritrovare il changeset, niente di più.
- **Nessuna sezione "file cambiati"**: questo è un registro, non un diff.
- **Nessuna istruzione operativa**: migrazioni, backfill e segreti non entrano qui.
- **Niente emoji**, salvo che la feature stessa ne usi una.

## Passo 4 — Aggiornare la versione

Porta il campo `version` (o il file equivalente) al numero calcolato al Passo 2. È l'unico posto dove la versione vive.

## Passo 5 — `project-structure.md`, solo se serve

Se `docs/project-structure.md` esiste, è la regola di collocazione del codice: dove va cosa, e con quale criterio si sceglie fra due directory entrambe plausibili. Aggiornalo solo se il lavoro:

- ha creato o eliminato una directory-pattern (un posto nuovo dove mettere una categoria di codice);
- ha cambiato il criterio con cui si sceglie fra due posti esistenti;
- ha introdotto o rimosso un'area applicativa o un servizio esterno.

Un file nuovo dentro una directory che già esiste non è un motivo per toccarlo. Nella maggior parte dei lavori questo passo è un no-op: dichiaralo e vai avanti.

## Passo 6 — Committare

```bash
git status --short                          # mostralo all'utente prima di procedere
git add docs/change-log.md package.json     # SOLO i file toccati, esplicitamente
git commit -m "Record vX.Y.Z in the changelog"
```

- Mai `git add -A` o `git add .`.
- Mai `--amend`: se il commit fosse già stato pushato, riscriverlo fa più danni di quanti ne eviti.
- Messaggio all'imperativo, nella lingua che la storia del repo già usa.
- Il commit va nel branch del lavoro, prima del merge: documentazione e codice arrivano su `main` nello stesso changeset.

## Passo 7 — Report finale

In forma breve:

- versione assegnata e perché quel livello;
- titolo della voce scritta;
- se `project-structure.md` è stato toccato (e se no, il no-op dichiarato);
- decisioni mancanti: scelte fatte durante il lavoro che nessun file spiega;
- cosa resta da fare a mano dopo il merge, se il piano lo prevede (backfill, segreti, migrazioni), come promemoria nel report e mai nel changelog;
- il promemoria che `STATO.md` del lavoro deve dire `stato: chiuso`, e che dopo il merge si può archiviare con `/devflow-archive`.

## Rapporto con l'archiviazione

La voce di changelog è ciò che sopravvive all'archiviazione: quando `/devflow-archive` sposta un lavoro in `docs/lavori/__Archived/`, il suo contenuto diventa illeggibile in sessione e restano solo il changelog e le decisioni. Scrivi la voce pensando a chi la leggerà quando il resto non sarà più consultabile: deve reggersi da sola.
