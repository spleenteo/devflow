---
name: devflow-archive
description: Da invocare esplicitamente per archiviare un lavoro devflow concluso e già registrato nel changelog. Trigger: "/devflow-archive", "archivia il lavoro X", "metti via X". Non archivia mai di propria iniziativa.
---

# Devflow Archive

Sposta un lavoro concluso in `docs/lavori/__Archived/` e ne ripara i riferimenti.

## Perché esiste

Un lavoro chiuso continua a occupare contesto in ogni sessione che esplora `docs/lavori/`: slice, piani, note di stato che descrivono decisioni già prese e codice già scritto. Il suo esito vive altrove, nel changelog e nelle decisioni, e riletto oggi confonde invece di aiutare.

`docs/lavori/__Archived/` è murata: `.claude/settings.json` del progetto nega `Read` e `Grep` su quel percorso. Non è una convenzione da rispettare, è una porta chiusa. Per riaprirla si toglie il `deny` a mano, di proposito.

## Cosa questa skill NON fa

| Non fa | Perché |
|---|---|
| Non archivia di propria iniziativa | Solo l'utente sa se un lavoro è davvero finito o solo fermo |
| Non archivia un lavoro `in-corso` | Se il frontmatter non dice `chiuso`, si chiede prima |
| Non cancella niente | Archiviare è spostare; la storia resta in git |
| Non tocca `docs/decisions-log/` | Le decisioni sopravvivono al lavoro che le ha prodotte |
| Non legge dentro `__Archived/` | Non può: il `deny` lo impedisce |
| Non tocca `CLAUDE.md` | L'unico file di progetto fuori da `docs/` che tocca è `.claude/settings.json`, e solo con il permesso del Passo 0 |

---

## Passo 0 — La prima volta in un repo: il muro

```bash
grep -n "__Archived" .claude/settings.json 2>/dev/null
```

Se non c'è, proponi di aggiungere il `deny`, e aspetta il sì:

```json
{
  "permissions": {
    "deny": [
      "Read(./docs/lavori/__Archived/**)",
      "Grep(./docs/lavori/__Archived/**)"
    ]
  }
}
```

Se `settings.json` esiste già, si aggiungono le due righe all'array `deny` senza toccare il resto. Se l'utente non vuole il muro, si archivia lo stesso: la cartella resta leggibile e lo si dice nel report. Il muro entra in vigore alla sessione successiva.

Crea anche `docs/lavori/archiviati.md` se manca:

```markdown
---
tags: [lavori, archivio, indice]
description: "Indice dei lavori archiviati in docs/lavori/__Archived/, cartella che Claude non legge. Questo file sta fuori ed è l'unica traccia che quei lavori siano esistiti."
---

# Lavori archiviati

> `docs/lavori/__Archived/` contiene i lavori conclusi. Claude non la legge: `.claude/settings.json` nega `Read` e `Grep` su quel percorso. Questo file sta fuori e dice dove trovare l'esito di ogni lavoro. Si aggiorna con `/devflow-archive`.

| Lavoro | Chiuso | Cosa ha fatto | Dove sta l'esito |
|---|---|---|---|
```

## Passo 1 — Scegliere il lavoro

Se l'utente non l'ha nominato, elenca i candidati:

```bash
for f in docs/lavori/*/STATO.md; do
  printf "%-32s %s  %s\n" "$(basename $(dirname $f))" "$(grep -m1 '^stato:' $f)" "$(grep -m1 '^fase:' $f)"
done
```

Sono candidati solo i lavori con `stato: chiuso` e `fase: conclusa`. Se l'utente ne indica uno diverso, dillo e chiedi conferma: potrebbe essersi dimenticato di aggiornare il frontmatter, oppure il lavoro non è finito. Un lavoro senza `STATO.md` non è archiviabile a occhi chiusi: chiedi cosa contiene.

## Passo 2 — Verificare che l'esito sia documentato altrove

Archiviare è sicuro solo se ciò che serve sapere è già fuori.

- **Nel changelog**: `rg "<slug>" docs/change-log.md`. Se il lavoro non compare, il suo esito non è registrato da nessuna parte: segnalalo e proponi `/devflow-docs` prima.
- **Nelle decisioni**: `rg -l "<slug>" docs/decisions-log/ 2>/dev/null`. Restano fuori dall'archivio e sono la memoria del perché.

Se manca l'una o l'altra, non bloccare: riporta cosa manca e chiedi se archiviare lo stesso.

## Passo 3 — Censire i link entranti

```bash
grep -rn "lavori/<dir>/" --include="*.md" docs README.md .claude 2>/dev/null
```

Ogni link va aggiornato al nuovo percorso: `lavori/<dir>/` diventa `lavori/__Archived/<dir>/`. Restano corretti per un umano che apre il file; è solo Claude a non poterli seguire. Se il numero è alto, dillo prima di procedere.

## Passo 4 — Marcare e spostare

Prima dello spostamento, aggiungi al frontmatter dello `STATO.md`:

```yaml
archiviato: YYYY-MM-DD
```

Va scritto prima: una volta spostato e chiusa la sessione, quel file non è più raggiungibile. Poi:

```bash
mkdir -p docs/lavori/__Archived
git mv docs/lavori/<dir> docs/lavori/__Archived/<dir>
```

Sempre `git mv`, mai `mv`: la rinomina resta leggibile nella storia.

## Passo 5 — Aggiornare i link, in due direzioni

**Entranti.** Riscrivi i riferimenti censiti al Passo 3, poi verifica che non ne restino al vecchio percorso:

```bash
grep -rn "lavori/<dir>/" --include="*.md" docs README.md .claude 2>/dev/null | grep -v "__Archived"
```

Deve restituire zero righe.

**Uscenti, quelli che si dimenticano.** I file archiviati sono scesi di un livello: i loro link relativi verso il resto di `docs/` hanno bisogno di un `../` in più. Non sostituire alla cieca `../` con `../../`: un pattern che contiene l'altro raddoppia anche i livelli già corretti. Per ogni link rotto, prova ad aggiungere un solo livello e applica la modifica solo se così il file esiste davvero.

**Fra due archiviati serve un livello in meno.** Se un lavoro già archiviato puntava a uno che archivi adesso, il suo link aveva un `../` in più per uscire da `__Archived/`: ora va tolto. Stessa regola: prova, verifica che il file esista, poi applica.

## Passo 6 — Aggiornare l'indice

`docs/lavori/archiviati.md` sta fuori dalla cartella murata, quindi resta leggibile. Aggiungi una riga:

```markdown
| `<slug>` | <data di chiusura> | <una frase su cosa ha fatto> | <voci di changelog> · <n> decisioni |
```

Una riga sola: se serve di più, quel "di più" appartiene al changelog o a una decisione.

## Passo 7 — Committare e riferire

```bash
git status --short
git add docs/lavori docs/lavori/archiviati.md <file con i link aggiornati> [.claude/settings.json]
git commit -m "Archive the <slug> work"
```

Nel report finale: quale lavoro, quanti link aggiornati, dove ne resta traccia (voci di changelog e decisioni), se il muro è attivo o no, e l'avvertenza che da adesso quel contenuto non è più leggibile in sessione.

---

## Se serve rileggere un lavoro archiviato

Non chiedere a Claude di aggirare il `deny`: non può, ed è il punto. Le opzioni sono due:

1. **Aprire il file a mano**: l'archivio è normale testo in git, un editor lo apre.
2. **Togliere temporaneamente la regola** da `.claude/settings.json`, riavviare la sessione, fare ciò che serve, rimetterla.

Se un lavoro archiviato torna attivo, la strada è la seconda seguita da `git mv` all'indietro: l'archivio non è una tomba, è uno scaffale alto.
