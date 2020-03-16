# SociallyUndead

Addon for the Socially Undead Classic World of Warcraft guild

An easier to read view of the BWL loot list is available at: https://raptiq.github.io/SociallyUndead/

## Editing Loot

Source of truth for all SU loot priority and DKP info are the `X_loot.json` files in the root of this repo.

Loot items are either

### Default Item

Will use default values for role/dkp

```
[
    ...
    SomeItemID,
    SomeOtherItemID,
    ...
]
```

OR

### Custom Item

```
[
    ...
    {
        "id": 12345,
        "name": "Iron Dagger",
        "dkp": 666,
        "role": "Mage > Priest == Warlock"
    },
    ...
]
```

Most Molten Core loot by default is the same (5DKP minbid, MS > OS), if you want to change the default look in `./scripts/generate_loot.js`. If you want to override the default for a specific item:
In `mc_loot.json`:

1. Find the item id you want to override and delete it
2. Add an object to the list with the above object schema

[See this change for an example](https://github.com/raptiq/SociallyUndead/commit/8a3801fbad8a48a1693add0a070b099f8a3ecc37#diff-58d835338c66e76d9c3f1eb7f88cb96d)

Open a pull request once you've made your changes. Once merged the Addon and site loot lists will be updated.
