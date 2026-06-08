Minimal feature todo

# Excavating

- générer des excavating
- N tresor
- X coups max
- faire une UI (coup max, changer outils)
- renvoyer le set des trucs trouvé après X coup


- Clé/porte
- Shape verouillé par d'autre shape
- Shape: tile point faible (si détruit supprime la shape)
- Shape: s'étend/virus
- Shape: metal absorbe

# Mining

- Inventaire / faire une UI pour la liste des tresors trouvé
- Sprite du perso (4 dir?)
- Shop

# Outils

- Pioche
.1.
121
.1.

- Marteau
121
222
121


    
Shape: pv per tile

```rs
struct Shape
{
    tiled_type : enum { Rock, Grass, Sand ...}
}

struct TileData
{
    hp_max : int,
    hp: int 
}
```

Terre, Pierre, 

Terre 1
Pierre 2

```rs
bitset/enum Category

enum
{
    Dirty = 1,
    Rock = 2
}

struct TileDigStat
{
    damage: int
}


func dig(at: Vector2i, tiles: Tiles<TileDigStat>)


Tiles<T>
```