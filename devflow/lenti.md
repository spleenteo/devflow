# Lenti d'impatto

Ogni lente è un subagent, lanciato in parallelo agli altri, con `ultrathink` nel prompt. Ogni subagent legge `slices.md` per intero, `shaping.md` e `breadboard.md` se ci sono, e il codice che le slice toccano. Riferisce una voce per problema, ordinata per gravità: cosa · dove (`file:riga`) · perché · correzione proposta. Se non trova nulla, lo dice.

Si usano sempre le tre lenti comuni. Quelle di stack si aggiungono in base a quanto rilevato; su un lavoro piccolo se ne sceglie una o due, dicendo quali si saltano e perché.

## Comuni, per ogni stack

| Lente | Cosa cerca |
|---|---|
| **Esistenza** | I file, i modelli, le funzioni, le rotte e le tabelle che le slice nominano esistono ancora davvero, con quel nome e quella firma? È la verifica che più costa quando manca. Prima di dichiarare qualcosa inutilizzato o morto: grep su tutto il codice sorgente, il valore e il suo setter, e nel report dire dove si è cercato |
| **Flusso core e feature vicine** | Quale percorso principale dell'utente viene attraversato o alterato? Chi altro legge o scrive gli stessi dati? Quali impostazioni o flag cambiano il comportamento di ciò che si sta per costruire? Quali permessi o ruoli ne risentono? |
| **Memoria e debito** | C'è in `docs/decisions-log/`, in `CLAUDE.md` o in `docs/` una decisione che il lavoro contraddice o rende obsoleta? Quali documenti diventeranno falsi a lavoro finito? Servono migrazioni di dati sul contenuto già esistente? |

## `rails`

| Lente | Cosa cerca |
|---|---|
| **Transazioni, callback e job** | Effetti collaterali dentro `after_save` che dovrebbero stare in `after_commit`; job accodati prima del commit; job schedulati (`sidekiq-cron`, `whenever`) che leggono le tabelle toccate; scritture verso schema o database diversi dal principale |
| **Tempo e locale** | `Time.now` o `Date.today` al posto di `Time.zone`; formati di data nelle viste e negli export; fusi orari nei job notturni |
| **Migrazioni e dati** | Reversibilità; migrazioni che devono girare per ogni tenant o schema; backfill su record esistenti; indici mancanti sulle colonne che le nuove query filtrano; N+1 nelle viste che le slice toccano |
| **Autorizzazione** | `ability.rb`, policy Pundit o equivalenti: chi può fare la cosa nuova, e chi non deve; le aree applicative separate (admin, portale, API) che condividono i modelli toccati |
| **Allegati e servizi esterni** | ActiveStorage e CDN di immagini; mailer e provider di posta; PDF; webhook in ingresso e in uscita |

## `astro`

| Lente | Cosa cerca |
|---|---|
| **Prerender e runtime** | Quali rotte sono statiche e quali SSR; cosa cambia se un dato che oggi si legge a build time deve leggersi a richiesta; variabili d'ambiente disponibili solo a build |
| **Sorgenti di contenuto** | Query verso il CMS: campi nullable attraversati su record non tradotti (una query che solleva restituisce 200 con corpo vuoto e niente nei log); ambienti e draft mode; cache e revalidazione |
| **Isole e navigazione** | Componenti con `client:*` e cosa ne resta dopo una view transition: lo stato appoggiato a un elemento che Astro sostituisce a ogni navigazione si perde; script inline che si riattaccano o no |
| **Lingue e direzione** | Rotte per locale e 404 per locale; `lang` e `dir` sulla radice; proprietà CSS fisiche contro logiche; font che coprono gli alfabeti serviti; `hreflang` e sitemap |
| **Peso e piattaforma** | Limiti dell'hosting (dimensione del bundle, tempo di build, numero di rotte); font e immagini self-hosted; `robots.txt` e output per i crawler |

## `react`

| Lente | Cosa cerca |
|---|---|
| **Context e consumatori** | Per ogni chiave che si sposta, si rinomina o cambia significato tenendo il nome: l'elenco completo dei chiamanti scritto prima di toccare il codice, valore e setter; il compilatore non protegge una firma uguale con comportamento diverso |
| **Stato e re-render** | Chi si iscrive a cosa; provider divisi per frequenza di cambiamento; componenti non memoizzati che ri-renderizzano a ogni cambio di un context che non li riguarda |
| **Copertura dei test** | Cosa coprono davvero i test esistenti (spesso solo `utils/` e `lib/`); dove serve una checklist di regressione manuale perché nessun test vede componenti, hook e context; etichette ambigue nelle fixture |
| **Dati e backend** | Query, mutation e policy di accesso (RLS, regole di sicurezza) sulle tabelle toccate; ottimismo e invalidazione della cache; cosa succede offline |
| **Tipi** | `switch` esaustivi che il compilatore può controllare; unioni discriminate al posto di flag booleani; `tsc --noEmit` come parte del gate |

## `node`

| Lente | Cosa cerca |
|---|---|
| **Punti d'ingresso** | Script in `package.json`, CLI, handler e cron che invocano il codice toccato; chi importa i moduli che cambiano firma |
| **Ambiente e segreti** | Variabili d'ambiente lette a runtime, valori di default, differenze fra locale e produzione |
| **Dati** | Migrazioni, formati di file scritti e letti, compatibilità con dati già esistenti |

## `generic`

Le tre lenti comuni bastano. Se il repo ha uno stack riconoscibile che questa tabella non copre, si dichiara e si scrivono due o tre lenti ad hoc nel prompt, con lo stesso formato.
