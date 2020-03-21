# SociallyUndead

Addon for the Socially Undead Classic World of Warcraft guild

An easier to read view of the BWL loot list is available at: https://raptiq.github.io/SociallyUndead/

## Developing

### Clone the Repository

Clone the SociallyUndead repository anywhere, using any Git app with the URL https://github.com/raptiq/SociallyUndead.git, or use this command in your favorite CLI:

`git clone https://github.com/raptiq/SociallyUndead.git`

Note: don't clone the repository anywhere in the World of Warcraft folder directly. See below for directions on how to load your dev environment in World of Warcraft.

### Libraries

Dependent libraries and vendored in the repository and don't have to be manually installed

### Symlink to Wow Addons Directory

Windows:

```
> mklink /d "path\to\World of Warcraft\_classic_\Interface\Addons\SociallyUndead" "path\to\repository\SociallyUndead"
symbolic link created for SociallyUndead <<===>> path\to\repository\SociallyUndead
```

MacOS

```
> ln -s "path/to/repository/SociallyUndead" "path/to/World of Warcraft/_classic_/Interface/Addons/SociallyUndead"
```

### Development environment

You can use any development setup you want but Visual Studio Code and the [vscode-lua extension](https://marketplace.visualstudio.com/items?itemName=trixnz.vscode-lua) are solid and require little setup

### Contributing

[See basic git overview here](https://gist.github.com/jedmao/5053440)

Expected process:

- Create a new branch off `master`
- Commit your changes to that branch
- Push to remote (Github)
- Open a Pull Request

## Editing Loot Config

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
