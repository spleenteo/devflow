# Devflow

Tre skill per [Claude Code](https://claude.com/claude-code) che conducono un lavoro di sviluppo dall'idea al codice, una slice alla volta. Funzionano in qualunque repo e non richiedono nulla nel suo `CLAUDE.md`.

Questa guida è per chi deve installarle e lavorarci. Il dettaglio di cosa fa ogni skill sta nei rispettivi `SKILL.md`, che legge Claude; qui c'è il punto di vista di chi le usa.

## Primi passi

Le skill si installano **una volta sulla macchina**, non nei progetti. Dopo `install.sh` valgono in ogni repo che apri con Claude Code, senza copiare niente dentro il repo.

Per provarla su un progetto, per esempio `~/Sites/dsm/acacia-2026`:

```bash
cd ~/Sites/dsm/acacia-2026
claude
```

e nella sessione:

```
/devflow
```

La skill fa le domande di apertura e crea `docs/lavori/` al primo lavoro. Se `/devflow` non viene riconosciuto, la macchina non ha ancora le skill: vedi [Installazione sulla macchina](#installazione-sulla-macchina).

## L'idea in tre righe

Il piano ad alto livello è la definizione delle slice, che nasce dallo shaping. Il piano di dettaglio di ogni slice si scrive subito prima di eseguirla, dopo che la precedente è chiusa: eseguire la slice N insegna cose che il piano di N+1 deve contenere, e un piano scritto settimane prima le ignora.

```
apertura ─► frame ─► shaping ─► breadboard ─► slicing ─► impatto ─┐
                (le fasi che servono, dichiarate)                  │
                                                                   ▼
             ┌────────── per ogni slice, nell'ordine di slices.md ─────────┐
             │  piano ─► review ─► esecuzione ─► chiusura (lezioni)  ──┐   │
             └─────────────────────────────────────────────────────────┘   │
                                                                   ◄───────┘
conclusa ─► /devflow-docs (changelog, versione) ─► merge ─► /devflow-archive
```

Lo stato vive su disco, in `docs/lavori/<data>-<slug>/STATO.md`, nei campi `fase`, `slice` e `passo`. Un lavoro interrotto riparte da lì, anche giorni dopo, anche in una sessione nuova.

## Le tre skill

| Skill | Ruolo | Quando la invochi |
|---|---|---|
| `devflow` | Il conduttore: apre la casa del lavoro, sceglie le fasi, invoca gli attrezzi dicendo loro dove salvare, fa verificare i piani da subagent, esegue slice per slice e si ferma fra un passo e l'altro | All'inizio di un lavoro, per riprenderlo, per passare alla slice successiva |
| `devflow-docs` | Voce di changelog e numero di versione | A lavoro concluso, prima del merge |
| `devflow-archive` | Sposta un lavoro chiuso in un archivio che Claude non legge più, e ripara i link | Dopo il merge |

Le lenti d'impatto per stack (Rails, Astro, React, Node, generico) stanno in `devflow/lenti.md`.

## Prerequisiti

- Claude Code, CLI o app, con accesso al terminale.
- `git` e `rg` (ripgrep): le skill li usano per cercare lo stato dei lavori e i riferimenti fra documenti.
- Le skill da cui devflow dipende, elencate nella sezione [Dipendenze](#dipendenze). `install.sh` dice quali mancano.

## Installazione sulla macchina

Una volta sola, per tutti i progetti. Le skill si installano a livello utente, in `~/.claude/skills/`, e da lì valgono in ogni repo che apri con Claude Code.

```bash
git clone git@github.com:spleenteo/devflow.git ~/Sites/me/devflow
~/Sites/me/devflow/install.sh
```

Cosa fa lo script:

1. Crea un symlink per ognuna delle tre skill dentro `~/.claude/skills/`. Claude Code scopre solo le cartelle figlie dirette di quella directory, quindi il symlink serve; e siccome punta al clone, un `git pull` aggiorna le skill senza reinstallare.
2. Controlla le dipendenze e stampa `ok` o `MANCA` per ciascuna, con l'indicazione di dove prenderla.

Lo script è idempotente: rilanciarlo non fa danni. Se in `~/.claude/skills/` esiste già una cartella con lo stesso nome che non punta al clone, la lascia stare e lo dice.

Per una destinazione diversa: `CLAUDE_SKILLS_DIR=/percorso ~/Sites/me/devflow/install.sh`.

**Verifica.** Apri Claude Code in una cartella qualsiasi e digita `/devflow`: se la skill risponde con le domande di apertura, è installata. Oppure `ls -la ~/.claude/skills | grep devflow`.

## Installazione in un progetto

Non c'è niente da installare nel progetto. Le skill sono a livello utente e si portano dietro le loro convenzioni. Quello che compare nel repo, e quando:

| Cosa | Dove finisce | Quando |
|---|---|---|
| I lavori | `docs/lavori/<data>-<slug>/` | Al primo `/devflow`, che crea la cartella |
| Il changelog | `docs/change-log.md` | Al primo `/devflow-docs`, se il file non c'è già |
| L'indice degli archiviati | `docs/lavori/archiviati.md` | Al primo `/devflow-archive` |
| Il muro dell'archivio | Due righe `deny` in `.claude/settings.json` | Proposto al primo `/devflow-archive`; si può rifiutare |

Il `CLAUDE.md` del progetto non viene toccato. Se esiste, Claude lo legge come sempre per gli standard del repo, e devflow ci si adegua, come fa con `docs/dev-standards.md` e `docs/decisions-log/` quando ci sono.

Lo stack viene rilevato dal repo (`Gemfile` per Rails, `astro.config.*` per Astro, `package.json` con o senza `react`) e serve a scegliere le lenti d'impatto.

### Se il progetto ha bisogno di deviare

Un file `.devflow.yml` alla radice del repo, facoltativo, che scrivi tu: le skill non lo creano mai. Tutte le chiavi sono opzionali.

```yaml
lavori: docs/work        # cartella dei lavori, default docs/lavori
stack: astro             # forza lo stack se il rilevamento sbaglia
changelog: CHANGELOG.md  # default docs/change-log.md
versione: VERSION        # file con la versione, default package.json
```

### Progetti con una struttura preesistente

Se il repo ha già i suoi documenti di shaping altrove, per esempio in `docs/shaping/`, i lavori vecchi restano dove sono. I nuovi partono in `docs/lavori/`, oppure imposti `lavori:` in `.devflow.yml` per continuare nella cartella esistente.

## Come si usa il flow

### Aprire un lavoro

In Claude Code, dentro il repo:

```
/devflow
```

oppure "apriamo il lavoro menu-mobile". La skill fa cinque domande, una alla volta:

1. Cosa vuoi realizzare, in parole tue.
2. Il nome in codice: uno slug breve, tipo `menu-mobile` o `filtro-commesse`.
3. Se c'è materiale sorgente: trascrizioni di call, thread, appunti. Se sì, il frame parte da lì.
4. Il test dell'esito visibile: sai già dire in una frase cosa cambia per chi usa il prodotto, senza rispondere "dipende"? Se sì è un lavoro tecnico e si salta allo slicing; se no è un lavoro di prodotto e si parte dal frame.
5. Se è di prodotto: il problema è già chiaro? Se sì si salta il frame.

Poi crea `docs/lavori/<data>-<slug>/STATO.md` e dichiara il percorso che intende fare ("salto frame e breadboard, faccio shaping, slicing e impatto"). Puoi correggerlo.

### Le fasi di definizione

Ogni fase produce un documento nella cartella del lavoro, viene committata, e la skill si ferma a chiedere se proseguire.

| Fase | Documento | Cosa succede |
|---|---|---|
| frame | `frame.md` | Il problema da risolvere, in dialogo o a partire dalle trascrizioni |
| shaping | `shaping.md` | Requisiti e opzioni di soluzione, con fit check |
| breadboard | `breadboard.md` | Le parti e i loro collegamenti; anche per l'architettura |
| slicing | `slices.md` | Le slice: cosa entra in ognuna, cosa resta fuori, come si dimostra che è fatta |
| impatto | correzioni in `slices.md` | Subagent in parallelo, uno per lente, leggono le slice e il codice vero e riportano i problemi uno alla volta; tu approvi, scarti o cambi |

`slices.md` è il piano ad alto livello e resta il documento di riferimento per tutto il lavoro.

Se una fase non serve, la skill lo dice e salta. Se un punto resta vago, invoca `grill-me` su quello. Se c'è un'incognita tecnica (come si comporta una libreria, cosa fa davvero un pezzo di codice), fa uno spike in `spike-<tema>.md` prima del piano che ne dipende.

### Il ciclo per slice

Per ogni slice, nell'ordine di `slices.md`:

1. **Piano.** `writing-plans` scrive `V<n>-plan.md` a partire dalla slice, dallo shaping e dalle lezioni delle slice chiuse. Gli scostamenti dal mandato che emergono scrivendolo (un'affordance da spostare, un file che non esiste) vengono annotati in `slices.md`.
2. **Review.** Un subagent verifica il piano contro i documenti: fedeltà al mandato, lezioni ignorate, esistenza dei file e dei simboli che il piano nomina. I problemi arrivano uno alla volta; decidi tu.
3. **Esecuzione.** `subagent-driven-development` esegue il piano: un subagent per task, una revisione indipendente per task, senza fermarsi fra un task e l'altro.
4. **Chiusura.** Verifica del Done della slice (test, typecheck, build; la checklist di regressione se è un refactor), lezioni scritte in `slices.md` nella sezione `V<n> — fatta il <data>`, `STATO.md` aggiornato, commit. Poi la domanda: "V3 chiusa. Scrivo il piano di V4, o ti fermi qui?"

Puoi fermarti in qualunque punto. La prossima volta basta `/devflow`, o "riprendiamo menu-mobile": la skill legge `STATO.md` e propone di ripartire da dove eri.

### Un bugfix

Stessa skill, percorso corto: `slices.md` con la sola V1 e il suo Done, impatto se tocca più di un file, poi il ciclo una volta. Niente frame, shaping, breadboard.

### Chiudere un lavoro

Quando l'ultima slice è chiusa, la skill segna `fase: conclusa` e propone i due passi finali, che invochi tu:

```
/devflow-docs      # prima del merge: voce di changelog e versione
/devflow-archive   # dopo il merge: il lavoro va in docs/lavori/__Archived/
```

`devflow-docs` calcola la versione (patch o minor; una major la propone solo l'utente), scrive la voce in cima a `docs/change-log.md` nella lingua delle voci esistenti, e aggiorna `package.json`.

`devflow-archive` sposta la cartella del lavoro, ripara i link in entrambe le direzioni, aggiunge una riga a `archiviati.md`, e la prima volta propone il `deny` in `.claude/settings.json` che rende l'archivio illeggibile a Claude: i lavori chiusi smettono di pesare sul contesto, e per rileggerne uno basta aprirlo in un editor.

### Cosa resta nel repo

```
docs/
  change-log.md
  lavori/
    archiviati.md
    2026-09-02-menu-mobile/
      STATO.md
      shaping.md
      slices.md
      spike-view-transitions.md
      V1-plan.md
      V2-plan.md
      V3-plan.md
    __Archived/
      2026-08-20-filtro-commesse/
```

Tutto markdown, versionato con il codice.

## Dipendenze

devflow è un conduttore: non fa lo shaping, non scrive i piani, non esegue il codice. Prende in mano altre skill al momento giusto, dicendo loro dove salvare. Queste skill non sono incluse nel repo, perché evolvono per conto loro: si installano una volta a livello utente e `install.sh` verifica che ci siano.

| Skill | Ruolo in devflow | Origine | Installazione |
|---|---|---|---|
| `shaping` | Frame, shaping, slicing | [rjs/shaping-skills](https://github.com/rjs/shaping-skills) | Clone del repo e symlink in `~/.claude/skills/`, come spiega il suo README |
| `breadboarding` | Breadboard e slicing | rjs/shaping-skills | Idem |
| `framing-doc` | Frame da trascrizioni | rjs/shaping-skills | Idem |
| `grill-me` | Stringere un punto vago | [mattpocock/skills](https://github.com/mattpocock/skills) | `npx skills add mattpocock/skills --skill grill-me`, poi symlink da `~/.agents/skills/grill-me` a `~/.claude/skills/grill-me` |
| `brainstorming` | Frame in dialogo | [obra/superpowers](https://github.com/obra/superpowers) | In Claude Code: `/plugin install superpowers@claude-plugins-official` |
| `writing-plans` | Il piano di ogni slice | obra/superpowers | Idem |
| `subagent-driven-development` | L'esecuzione di ogni piano | obra/superpowers | Idem |

Per superpowers va bene anche `npx skills add obra/superpowers`, che mette le skill in `~/.agents/skills/`: in quel caso `install.sh` non le vede e segnala `MANCA`, ma Claude Code le trova lo stesso se sono collegate in `~/.claude/skills/`.

Se una dipendenza manca, devflow non si blocca all'avvio: se ne accorge alla fase che la richiede, lo dice e chiede come procedere. Meglio installarle prima.

**Versioni.** Le skill di shaping-skills sono usate come sono; devflow passa loro solo l'istruzione di percorso. `writing-plans` e `subagent-driven-development` cambiano con le versioni di superpowers: il comportamento descritto qui corrisponde alla 6.3.

## Aggiornare e rimuovere

```bash
cd ~/Sites/me/devflow && git pull                      # i symlink seguono
rm ~/.claude/skills/devflow{,-docs,-archive}           # rimuove le tre skill
```

Rimuovere le skill non tocca i progetti: `docs/lavori/` e i suoi documenti restano, sono markdown normale.

## Origine

Deriva da `gestart-dev`, `gestart-docs` e `gestart-archive`, scritte per Gestart nell'agosto 2026. Quel conduttore si fermava ai piani verificati, perché lì i piani erano il deliverable da consegnare a chi eseguiva. La regola del piano just-in-time viene invece dai lavori su Slacky (refactor di `AppContext`, nove slice) e su Alpha Community, dove ogni piano scritto subito prima della sua slice ha fatto emergere scostamenti che un piano anticipato avrebbe ignorato.
