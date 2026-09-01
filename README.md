# Devflow

Tre skill per [Claude Code](https://claude.com/claude-code) che conducono un lavoro di sviluppo dall'idea al codice, una slice alla volta, in qualunque repo e senza toccarne il `CLAUDE.md`.

Il piano ad alto livello è la definizione delle slice, che nasce dallo shaping. Il piano di dettaglio di ogni slice si scrive subito prima di eseguirla, dopo che la precedente è chiusa: eseguire la slice N insegna cose che il piano di N+1 deve contenere.

## Il ciclo

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

Lo stato vive su disco, in `docs/lavori/<data>-<slug>/STATO.md`: `fase`, `slice`, `passo`. Un lavoro interrotto riparte da lì.

## Le skill

| Skill | Ruolo |
|---|---|
| **`devflow`** | Il conduttore: apre la casa del lavoro, sceglie le fasi, invoca gli attrezzi dicendo loro dove salvare, fa verificare i piani da subagent, esegue slice per slice e si ferma fra un passo e l'altro. Le lenti d'impatto per stack stanno in `devflow/lenti.md` |
| **`devflow-docs`** | Changelog e versione quando un lavoro è concluso e sta per arrivare su `main` |
| **`devflow-archive`** | Sposta un lavoro chiuso in `docs/lavori/__Archived/`, murata da un `deny` in `.claude/settings.json`, e ripara i link |

## Convenzioni, non configurazione

I lavori vivono in `docs/lavori/`. Lo stack si rileva dal repo (`Gemfile`, `astro.config.*`, `package.json`). `CLAUDE.md`, `docs/dev-standards.md`, `docs/decisions-log/` si leggono se esistono e si ignorano se no. Un `.devflow.yml` alla radice del progetto, con le chiavi `lavori`, `stack`, `changelog`, `versione`, sovrascrive i default: lo scrive l'utente, mai le skill.

## Installazione

```bash
git clone git@github.com:spleenteo/devflow.git ~/Sites/me/devflow
~/Sites/me/devflow/install.sh
```

Lo script crea un symlink per ogni skill in `~/.claude/skills/` e controlla le dipendenze. Ogni skill deve essere figlia diretta di quella cartella per essere scoperta; i symlink la tengono aggiornata con `git pull`.

## Dipendenze

Attrezzi che `devflow` prende in mano quando servono, tutti a livello utente:

| Skill | Da dove |
|---|---|
| `shaping`, `breadboarding`, `framing-doc` | [rjs/shaping-skills](https://github.com/rjs/shaping-skills) |
| `grill-me` | `~/.agents/skills/grill-me` |
| `brainstorming`, `writing-plans`, `subagent-driven-development` | plugin [superpowers](https://github.com/obra/superpowers) |

## Origine

Deriva da `gestart-dev`, `gestart-docs` e `gestart-archive`, scritte per Gestart nell'agosto 2026. Quel conduttore si fermava ai piani verificati, perché lì i piani erano il deliverable da consegnare a chi eseguiva. La regola del piano just-in-time viene invece dai lavori su Slacky (refactor di `AppContext`, nove slice) e su Alpha Community, dove ogni piano scritto subito prima della sua slice ha fatto emergere scostamenti che un piano anticipato avrebbe ignorato.
