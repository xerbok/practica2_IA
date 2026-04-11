# Pràctica MagaBot (PDDL)

Aquest paquet inclou una proposta completa de modelització per a la pràctica **Operació MagaBot**:
- domini simple
- domini simple amb dispensació ordenada
- domini avançat
- domini avançat amb dispensació ordenada
- tots els problemes demanats a l’enunciat

## Fitxers inclosos

### Dominis
- `domain_simple.pddl`
- `domain_simple_ordered.pddl`
- `domain_advanced.pddl`
- `domain_advanced_ordered.pddl`

### Problemes
- `pb_simplea.pddl`
- `pb_simpleb.pddl`
- `pb_simplec.pddl`
- `pb_avancat1a.pddl`
- `pb_avancat1b.pddl`
- `pb_avancat1c.pddl`
- `pb_avancat2a.pddl`
- `pb_avancat2b.pddl`

## Idea del model

### 1. Representació de la graella
Només s’han declarat com a objectes de tipus `cell` les caselles transitables.
Les relacions `(adjacent c1 c2)` defineixen els moviments possibles entre passadissos.

### 2. Robots
Un robot està en una casella amb:
- `(robot-at r c)`

I l’ocupació del passadís es controla amb:
- `(free c)`

Això garanteix que **només hi ha un robot per casella**.

### 3. Estanteries i piles
Les estanteries no són transitables. Un robot hi opera des d’una casella adjacent amb:
- `(near-shelf c e)`

Les piles es representen així:
- `(on-shelf p e)` → el paquet `p` és el de sota de tot de l’estanteria `e`
- `(on p q)` → `p` està directament damunt de `q`
- `(top-shelf e p)` → `p` és el paquet del capdamunt de l’estanteria `e`

Això permet agafar només el paquet superior.

### 4. Pila transportada pel robot
La pila del robot es modela igual:
- `(on-robot p r)` → `p` és el paquet de la base de la pila del robot
- `(on p q)` → `p` damunt de `q`
- `(top-robot r p)` → `p` és el paquet superior del robot

### 5. Dispensador
El dispensador tampoc és transitable. La proximitat es dona amb:
- `(near-disp c d)`

Quan un paquet es dispensa, queda marcat amb:
- `(dispensed p)`

I només es poden dispensar paquets marcats com:
- `(required p)`

Això evita dispensar paquets no demanats.

### 6. Ordre de dispensació
Als dominis ordenats s’ha afegit:
- `(current-required p)` → paquet que toca dispensar ara
- `(next-required p q)` → després de `p` toca `q`
- `(last-required p)` → últim paquet de la seqüència

Així, les accions `dispense-*` només poden executar-se si el paquet és l’esperat en aquell moment.

### 7. Nivell avançat
Als dominis avançats s’hi han afegit funcions numèriques:
- `(weight p)`
- `(load r)`
- `(max-load r)`
- `(energy r)`
- `(max-energy r)`
- `(total-cost)`

#### Moviment
Hi ha dues accions de moviment:
- `move-light` → costa 2 unitats
- `move-heavy` → costa 3 unitats

### Assumpció important
L’enunciat diu:
- 2 unitats si carrega **menys de 5 kg**
- 3 unitats si carrega **més de 5 kg**

No especifica què passa exactament amb **5 kg**. En aquesta proposta s’ha assumit:
- **si carrega 5 kg exactes, el cost és 2**

#### Càrrega i descàrrega
Les accions de recollida comproven:
- que el robot tingui energia
- que no superi la seva càrrega màxima

Les accions de descàrrega i dispensació actualitzen el pes carregat.

#### Recarrega
S’han modelat dues accions:
- `recharge-20`
- `recharge-to-max`

Això evita passar del màxim de bateria.

## Assumptions / decisions de modelatge

### 1. Posició de R2 a `pb_avancat1*`
Al text parsejat del PDF, `R2` apareix a `(6,2)`, però aquesta casella coincideix amb el carregador.
Per això, en els fitxers `pb_avancat1a/b/c` s’ha pres la **posició que surt al dibuix**, que és `(4,2)`.

### 2. Posició d’E2 a `pb_avancat2*`
El text del PDF té una part ambigua a la descripció d’E2.
S’ha pres la interpretació natural del mapa:
- `E2` és a `(5,6)`
- contingut inicial: `pkg5` a baix i `pkg6` a dalt

### 3. Robot sense energia
L’enunciat diu que si el robot es queda sense energia no pot fer cap acció.
Per coherència, també s’ha exigit energia positiva per recollir, descarregar, dispensar i recarregar.

## Com executar-ho amb ENHSP

## 1. Compilar ENHSP
Des de l’arrel del projecte d’ENHSP:
```bash
./compile
```

Això genera el fitxer JAR a `enhsp-dist/enhsp.jar`.

## 2. Executar un problema
Sintaxi general:
```bash
java -jar enhsp-dist/enhsp.jar -o <domini> -f <problema>
```

## 3. Exemples concrets

### Nivell simple
```bash
java -jar enhsp-dist/enhsp.jar -o domain_simple.pddl -f pb_simplea.pddl
```

### Nivell simple ordenat
```bash
java -jar enhsp-dist/enhsp.jar -o domain_simple_ordered.pddl -f pb_simpleb.pddl
```

### Nivell avançat
```bash
java -jar enhsp-dist/enhsp.jar -o domain_advanced.pddl -f pb_avancat1a.pddl
```

### Nivell avançat ordenat
```bash
java -jar enhsp-dist/enhsp.jar -o domain_advanced_ordered.pddl -f pb_avancat2b.pddl
```

## 4. Si tens problemes amb accents o codificació
En alguns entorns Java cal definir:
```bash
export JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8
```

I després tornar a executar el planner.

## Recomanació pràctica
Per l’informe, et recomano:
- provar diversos problemes amb el domini corresponent
- guardar el pla que et retorni ENHSP
- anotar temps, longitud del pla i mètrica quan n’hi hagi
- comentar les decisions de modelatge i les ambigüitats resoltes

## Nota final
Aquest paquet et dona la part de **modelització PDDL** i els **problemes instanciats**.
No s’han inclòs plans resolts dins del paquet perquè això depèn del planner que facis servir i de la configuració de cerca que triïs.