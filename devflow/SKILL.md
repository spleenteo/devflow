---
name: devflow
description: Da invocare esplicitamente quando si apre un lavoro di sviluppo in un repo, si riprende un lavoro interrotto o si passa alla slice successiva. Trigger: "/devflow", "apriamo il lavoro X", "riprendiamo X", "prossima slice", "dove eravamo con X". Vale per qualunque stack e non richiede nulla nel CLAUDE.md del progetto.
---

# Devflow

Conduce un lavoro di sviluppo dall'idea al codice, una slice alla volta.

Il piano ad alto livello è la definizione delle slice, che nasce dallo shaping. Il piano di dettaglio di ogni slice si scrive subito prima di eseguirla, dopo che la precedente è chiusa: eseguire la slice N insegna cose che il piano di N+1 deve contenere, e un piano scritto settimane prima le ignora.

## Perché esiste

Le skill che fanno il lavoro vero (`shaping`, `breadboarding`, `framing-doc`, `writing-plans`, `subagent-driven-development`) vengono da fuori, non si conoscono fra loro e non conoscono i percorsi del repo: `writing-plans` salverebbe in `docs/superpowers/plans/`, `brainstorming` in `docs/superpowers/specs/`, `shaping` dove capita. Senza un conduttore, a ogni lavoro si torna a decidere a memoria quali fasi servano e dove salvare, lo stato si perde alla chiusura della sessione, e salta il ritorno all'utente fra un passo e l'altro.

Questa skill tiene il filo: apre la casa del lavoro, sceglie il percorso, invoca ogni attrezzo al momento giusto dicendogli dove scrivere, segna su disco a che punto si è arrivati, e fa verificare da qualcun altro prima di eseguire.

## Cosa NON fa

| Non fa | Perché |
|---|---|
| Non scrive tutti i piani in anticipo | Il piano di una slice nasce quando la slice è la prossima. Vedi il ciclo |
| Non decide che un passo è finito | Chiude, committa, si ferma e chiede prima del successivo |
| Non salta passi in silenzio | Se ne salta uno, dice quale e perché |
| Non applica correzioni di sua iniziativa | Le verifiche propongono, una alla volta; decide l'utente |
| Non tocca `CLAUDE.md` né crea file di configurazione | Le convenzioni bastano; l'override esiste ma lo scrive solo l'utente |
| Non registra il changelog né archivia | Sono `devflow-docs` e `devflow-archive` |

**La regola che conta più di tutte**: una sessione lunga in cui la skill tira dritto è peggio di nessuna skill. Fra un passo e l'altro si torna sempre all'utente.

## Convenzioni, senza configurazione

| Cosa | Convenzione | Come si scopre |
|---|---|---|
| Casa dei lavori | `docs/lavori/` | Si crea al primo lavoro |
| Stack | `rails`, `astro`, `react`, `node`, `generic` | `Gemfile` + `config/application.rb` → rails; `astro.config.*` → astro; `package.json` con `react` fra le dipendenze → react; `package.json` senza → node; altrimenti generic |
| Standard di repo | `CLAUDE.md`, `docs/dev-standards.md`, `docs/how-to.md`, `docs/decisions-log/` | Si leggono se esistono, si ignorano se no |
| Lenti d'impatto | per stack, in `lenti.md` accanto a questa skill | Si scelgono in base allo stack rilevato |

Se un progetto ha bisogno di deviare (i lavori in un'altra cartella, uno stack non riconosciuto, la versione in un file diverso da `package.json`), può avere un `.devflow.yml` alla radice con le chiavi `lavori`, `stack`, `changelog`, `versione`. Si legge se c'è. La skill non lo crea mai: lo scrive l'utente, se lo vuole.

## All'avvio: aprire o riprendere

```bash
rg "^fase:" docs/lavori/*/STATO.md 2>/dev/null
```

- Nessun risultato → lavoro nuovo (Passo 1).
- Uno o più lavori con `fase:` diversa da `conclusa` → dillo e chiedi:

> "C'è `2026-09-02-menu-mobile`, alla slice **V3**, passo **esecuzione**. Riprendo da lì, o apri un lavoro nuovo?"

Riprendere significa leggere `STATO.md`, `slices.md` e il piano della slice corrente, tanto basta. Non rileggere le fasi chiuse per intero.

## Passo 1 — Le domande di apertura

Poche, una alla volta, in quest'ordine: ognuna determina la successiva.

1. **Cosa vuoi realizzare?** In parole tue. Diventa la `description` del frontmatter.
2. **Nome in codice?** Slug breve, minuscolo, con trattini. Controlla che non sia già preso, archivio compreso:
   ```bash
   ls -d docs/lavori/*<slug>* 2>/dev/null
   grep -n "<slug>" docs/lavori/archiviati.md 2>/dev/null
   ```
3. **Hai materiale sorgente?** Trascrizioni di call, thread, appunti, messaggi. Se sì, chiedi i percorsi: il frame parte da lì con `framing-doc` invece che dal dialogo.
4. **Il test dell'esito visibile.** *So già dire in una frase cosa cambia per chi usa il prodotto, senza dover rispondere "dipende"?* **Sì** → lavoro tecnico: si salta allo slicing. **No** → lavoro di prodotto: si parte dal frame. Dichiara la tua lettura invece di chiedere a freddo: *"Lo leggo come lavoro di prodotto: descrivendo l'esito mi viene da dire 'dipende da quali pagine devono cambiare'. Se per te è già definito, salto allo slicing."*
5. **Se è di prodotto: il problema è già chiaro?** Sì → si salta il frame e si parte dallo shaping. No → frame con `brainstorming` come tecnica di dialogo.

Se il dubbio è di dominio (cosa fa oggi il codice, quale regola vale), la risposta sta nel repo: leggila prima di chiedere.

## Passo 2 — Creare la casa

```bash
mkdir -p docs/lavori/$(date +%Y-%m-%d)-<slug>
```

Con dentro `STATO.md` già compilato:

```markdown
---
stato: in-corso
fase: <frame | shaping | breadboard | slicing | impatto | slice | conclusa>
slice: null
passo: null
lavoro: <slug>
stack: <rilevato>
updated: YYYY-MM-DD
tags: [lavoro, <slug>]
description: "<la risposta alla domanda 1>"
---

# Stato — <Nome leggibile>

> Aggiornare a **fine di ogni sessione**: cosa fatto, cosa resta, blocchi.

**Ingresso**: <prodotto | tecnico>, deciso il <data> perché <la risposta al test dell'esito visibile>.

## Slice

- [ ] (da definire nello slicing)

## Log

<!-- data — cosa fatto — cosa resta — blocchi -->
```

Il campo `lavoro:` è lo slug puro, senza data: la data sta nel nome della directory. `fase:` dice dove si è nel percorso; quando vale `slice`, `slice:` e `passo:` dicono quale slice e a che punto. Senza questi tre campi un lavoro interrotto si presenta la mattina dopo come concluso, o come mai iniziato.

## Passo 3 — Definire: dal problema alle slice

Per ciascuna fase: invoca l'attrezzo dicendogli dove salvare, poi committa, aggiorna `fase:`, e fermati.

| `fase:` | Serve quando | Attrezzo | Produce |
|---|---|---|---|
| `frame` | Il problema non è ancora definito | `framing-doc` se c'è materiale sorgente, altrimenti `brainstorming` | `frame.md` |
| `shaping` | Ci sono più soluzioni con esiti diversi | `shaping` | `shaping.md` |
| `breadboard` | I pezzi e i loro collegamenti non sono ovvi; vale anche per l'architettura, non solo per l'interfaccia | `breadboarding` | `breadboard.md` |
| `slicing` | Sempre, anche con una slice sola | `shaping` (sezione slicing) o `breadboarding` | `slices.md` |
| `impatto` | Sempre, dopo lo slicing | subagent, una lente ciascuno (vedi sotto) | correzioni in `slices.md` |

**`slices.md` è il piano ad alto livello.** Per ogni slice: cosa entra, cosa resta fuori, come si dimostra (il "Done"), i gotcha noti. È il mandato che ogni piano di dettaglio dovrà rispettare, e il posto dove le slice chiuse lasciano le lezioni per quelle successive. Ogni slice finisce in qualcosa che si può guardare o eseguire: una slice senza esito visibile è uno strato orizzontale, non una slice.

**L'istruzione di percorso è obbligatoria a ogni invocazione.** Senza, l'attrezzo usa il proprio default:

> Salva in `docs/lavori/2026-09-02-menu-mobile/shaping.md`. Non usare percorsi di default.

> Salva il piano in `docs/lavori/2026-09-02-menu-mobile/V2-plan.md`. **Non** in `docs/superpowers/plans/`.

**Se un punto resta vago** (un requisito che nessuno sa decidere, un'alternativa che non si chiude), invoca `grill-me` su quel punto prima di proseguire. È l'attrezzo per stringere, non una fase.

**Se un'incognita è tecnica** (come si comporta una libreria, cosa fa davvero un pezzo di codice, se un limite di piattaforma regge), è uno spike: un file `spike-<tema>.md` con domande ed esiti, fatto prima del piano della slice che ne dipende. Un piano non si scrive sopra un'ipotesi.

**Se una fase non serve**, dillo e salta: *"Le affordance qui sono tre chiamate a un endpoint esistente: salto il breadboard."* Mai in silenzio.

### `fase: impatto`, una volta sola, su `slices.md`

Le slice contro il codice vero, prima di scrivere il primo piano. Subagent in parallelo, uno per lente, ciascuno con la parola `ultrathink` nel prompt che gli passi. Le lenti stanno in `lenti.md`: quelle comuni più quelle dello stack rilevato. Ogni subagent legge `slices.md`, `shaping.md` e `breadboard.md` se ci sono, e il codice che le slice toccano.

Non farla in sessione: chi ha appena condotto lo shaping è la testa peggiore per vedere cosa rompe nel resto dell'applicazione.

Una voce per problema, ordinate per gravità: **cosa** · **dove** (`file:riga`) · **perché è un problema** · **correzione proposta**. Presentate una alla volta, aspettando la risposta. Se una lente non trova nulla, dillo: il silenzio si legge come "non l'ho fatta".

Le correzioni approvate finiscono in `slices.md`. Se una correzione spezza o riordina le slice, si torna a `fase: slicing`.

Su un lavoro da una slice sola l'impatto è spesso la verifica che salva: il fix da venti righe che rompe un'altra pagina. Proponila sempre; l'utente può saltarla.

## Passo 4 — Il ciclo per slice

Da qui `fase: slice`. Per ogni slice, nell'ordine di `slices.md`, quattro passi. `passo:` in `STATO.md` dice quale.

### `passo: piano`

Invoca `writing-plans` passandogli la sezione della slice in `slices.md`, `shaping.md` e `breadboard.md` se ci sono, e **le lezioni lasciate dalle slice chiuse**. Percorso: `V<n>-plan.md` nella casa del lavoro, con l'istruzione di percorso esplicita.

Scrivere il piano fa emergere scostamenti dal mandato: un'affordance che conviene spostare a un'altra slice, un file che non esiste, un meccanismo che la shape non prevedeva. Si dichiarano all'utente e si scrivono in `slices.md`, in una sezione **"Scostamenti emersi scrivendo il piano di V<n>"**. Il documento alto resta vero anche dopo.

### `passo: review`

Il piano contro i documenti, fatto da un subagent con `ultrathink`, mai in sessione: chi ha appena scritto il piano è la testa peggiore per trovarci le contraddizioni. Legge il piano, `slices.md` per intero, `shaping.md` e `breadboard.md`, le lezioni delle slice chiuse, e `docs/decisions-log/` e `docs/dev-standards.md` se esistono.

| Lente | Cosa cerca |
|---|---|
| **Fedeltà al mandato** | il piano fa cose che la slice non prevede; contraddice una scelta dello shaping o del breadboard; i criteri di Done non sono coperti dai task |
| **Lezioni ignorate** | una regola scritta da una slice chiusa che il piano non rispetta; lo stesso errore già fatto e già documentato |
| **Esistenza** | i file, i simboli e i metodi che il piano nomina esistono davvero, e fanno quello che il piano presume |

Con un piano solo le tre lenti stanno in un subagent. Correzioni una alla volta. Sui piani da correggere si riapre `writing-plans` passandogli l'incongruenza e la correzione approvata, e si dichiara in tre righe cosa è cambiato: un piano rigenerato è lungo, e una correzione da tre righe non deve costringere a rileggerlo tutto.

### `passo: esecuzione`

`subagent-driven-development` sul piano. Un subagent per task, una revisione indipendente per task. Quella skill esegue senza fermarsi fra un task e l'altro: è il suo modo di lavorare e qui non si cambia. Il ritorno all'utente sta prima (piano e review) e dopo (chiusura).

Se l'esecuzione scopre che il piano è sbagliato in un punto che il ruling del subagent non può coprire, si ferma, si corregge il piano, si riparte dal task interrotto.

### `passo: chiusura`

1. Verifica il Done della slice come è scritto in `slices.md`, più il gate del repo se esiste (`docs/dev-standards.md`; altrimenti: test verdi, typecheck o lint verdi, build verde). Se la slice è un refactor, il Done è una checklist di regressione scritta prima di iniziare ed eseguita a mano prima del commit: una demo di "guarda che non è cambiato niente" non prova nulla se non è una lista di cose da provare.
2. Scrivi in `slices.md`, sotto la slice, una sezione **"V<n> — fatta il <data>"** con ciò che si è scoperto eseguendo e che vale per le slice successive. Se una scoperta è una regola, formularla come regola: *"prima di dichiarare qualcosa inutilizzato, grep su tutto `src`, il valore e il suo setter, e dire nel report dove si è cercato"*.
3. Spunta la slice in `STATO.md`, porta `slice:` alla successiva e `passo:` a `piano`, aggiungi la riga di Log.
4. Committa, fermati, chiedi: *"V3 chiusa e committata. Scrivo il piano di V4, o ti fermi qui?"*

Una slice chiusa non si riapre. Se una slice successiva scopre che una precedente era sbagliata, la correzione entra nella slice corrente, dichiarata in `slices.md`, oppure diventa una slice nuova in coda.

## Passo 5 — Chiudere ogni passo

Vale per le fasi di definizione e per i quattro passi del ciclo. Quattro gesti, in quest'ordine:

1. **Committa** il documento o il codice appena prodotto. `git add` esplicito sui file toccati, mai `-A` né `.`: nel working tree può esserci lavoro estraneo. Messaggi all'imperativo, nella lingua che il repo già usa.
2. **Aggiorna `STATO.md`**: `fase:`, `slice:`, `passo:`, `updated:`, riga di Log. Dopo una verifica la riga dice l'esito: *"02/09 — impatto su slices.md: 2 problemi, corretti in V2 e V4"*.
3. **Chiedi se una scelta va registrata.** Se il repo ha `docs/decisions-log/`, applica il suo criterio. Se non ce l'ha e la decisione è di quelle che sorprenderanno fra un mese (alternativa reale scartata, problema noto rinviato), proponi di scriverla in `slices.md` sotto una sezione "Decisioni". È il momento giusto: fra due settimane il motivo è sbiadito.
4. **Fermati e chiedi** prima del passo successivo.

## Passo 6 — Uscire

Quando l'ultima slice è chiusa: `fase: conclusa`, `stato: chiuso`. Riferisci in poche righe: dove vive il lavoro, quali fasi sono state fatte e quali saltate (con il perché), quante slice, cosa hanno trovato le verifiche.

Poi proponi, senza eseguire: `/devflow-docs` per changelog e versione prima del merge, e `/devflow-archive` dopo.

## Il percorso corto

**Un bugfix è un lavoro con una slice sola.** Stessa skill: il test dell'esito visibile lo manda dritto allo slicing (`slices.md` con V1 e il suo Done), impatto se tocca più di un file, poi il ciclo una volta. Niente frame, shaping, breadboard.

**Un progetto piccolo non ha bisogno di tutte le fasi.** Dichiara il percorso in apertura: *"Lo leggo come lavoro tecnico da tre slice: salto frame, shaping e breadboard, faccio slicing e impatto, poi il ciclo."*

## Il ciclo di vita, per intero

| Momento | Skill | Di chi è |
|---|---|---|
| Apertura, definizione, ciclo per slice | `devflow` | questo repo |
| Piano di una slice | `writing-plans` | superpowers |
| Esecuzione di un piano | `subagent-driven-development` | superpowers |
| Changelog e versione | `devflow-docs` | questo repo |
| Archiviazione | `devflow-archive` | questo repo |

`shaping`, `breadboarding`, `framing-doc`, `brainstorming`, `grill-me` non compaiono nella tabella perché non sono momenti: sono attrezzi che questa skill prende in mano quando servono.

> Deriva da `gestart-dev` (Gestart, agosto 2026), che si fermava ai piani verificati perché lì i piani erano il deliverable da consegnare. Qui chi definisce esegue anche, e il piano di ogni slice nasce solo quando tocca a lei.
