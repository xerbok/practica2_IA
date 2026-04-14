# Operació MagaBot — versió unificada

Aquest paquet està preparat perquè puguis entregar **un sol domini simple** i **un sol domini avançat**:

- `domain_simple.pddl` serveix per `pb_simplea`, `pb_simpleb` i `pb_simplec`
- `domain_advanced.pddl` serveix per `pb_avancat1a`, `pb_avancat1b` i `pb_avancat1c`

## Idea clau del modelatge

En lloc de tenir un domini “ordered” separat, cada domini incorpora **dos modes**:

- `(mode-no-ordenat)` per als problemes sense restricció d'ordre
- `(mode-ordenat)` per als problemes amb ordre obligatori

Als problemes sense ordre només s'activen les accions de dispensació no ordenada.
Als problemes ordenats s'activen les accions que consulten:

- `requerit-actual`
- `seguent-requerit`
- `ultim-requerit`

Això permet reutilitzar **el mateix domini** per a totes les variants del nivell.

## Fitxers inclosos

### Domini simple
- `domain_simple.pddl`
- `pb_simplea.pddl`
- `pb_simpleb.pddl`
- `pb_simplec.pddl`

### Domini avançat I
- `domain_advanced.pddl`
- `pb_avancat1a.pddl`
- `pb_avancat1b.pddl`
- `pb_avancat1c.pddl`

## Com executar-ho amb ENHSP

### 1. Compilar ENHSP

Després de descarregar ENHSP, a la carpeta del planner:

```bash
./compile
```

Això genera el fitxer `enhsp-dist/enhsp.jar`.

### 2. Executar un problema del nivell simple

```bash
java -jar enhsp-dist/enhsp.jar -o domain_simple.pddl -f pb_simplea.pddl
```

Per exemple:

```bash
java -jar enhsp-dist/enhsp.jar -o domain_simple.pddl -f pb_simpleb.pddl
java -jar enhsp-dist/enhsp.jar -o domain_simple.pddl -f pb_simplec.pddl
```

### 3. Executar un problema del nivell avançat

```bash
java -jar enhsp-dist/enhsp.jar -o domain_advanced.pddl -f pb_avancat1a.pddl
```

Per exemple:

```bash
java -jar enhsp-dist/enhsp.jar -o domain_advanced.pddl -f pb_avancat1b.pddl
java -jar enhsp-dist/enhsp.jar -o domain_advanced.pddl -f pb_avancat1c.pddl
```

## Què fa cada domini

### `domain_simple.pddl`
Modela:
- moviment en la graella
- agafar paquets des d'estanteries adjacents
- deixar paquets a estanteries adjacents
- dispensar paquets al dispensador
- control opcional de l'ordre de dispensació

No modela ni pes ni bateria.

### `domain_advanced.pddl`
Afegeix al model simple:
- pes dels paquets
- càrrega actual del robot
- càrrega màxima del robot
- energia actual
- energia màxima
- accions de recàrrega
- cost energètic total amb mètrica de minimització

El moviment costa:
- `2` si el robot transporta `<= 5 kg`
- `3` si transporta `> 5 kg`

## Observacions importants

### Posició de `R2` a `pb_avancat1*`

He mantingut la decisió de modelatge següent:

- al text parsejat del PDF apareix `R2` a `(6,2)`
- però al dibuix de la pàgina del problema `R2` es veu a `(4,2)`
- `(6,2)` coincideix amb el carregador

Per coherència espacial, els problemes `pb_avancat1a`, `pb_avancat1b` i `pb_avancat1c` deixen `R2` a `(4,2)`.

### Sobre els paquets requerits

Només es poden dispensar paquets marcats amb `(requerit ...)`, tal com demana l'enunciat.
Això és especialment important a `pb_simplec`, on `pkg1` existeix però **no** es pot dispensar.
