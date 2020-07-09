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

Each of these files contain a list of JSON objects

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

Only the `id` field is required, if dkp or role are not set they will be set to the default (5DKP and MS > OS)

If you want to change those default look in `./scripts/generate_loot.js`

Once you've made all the changes to the json files, you'll need to run a generate script to update the .lua files.

Make sure Node.js is installed then execute `npm run generate-loot`

Open a pull request once you've made your changes.

# Releasing the Addon

Once your change has been merged in it's time to release it!

1. Compress the SociallyUndead/SociallyUndead folder into a .zip
2. Upload to Curseforge
   - Select "Release"
   - Enter changelog
   - Select the latest WoW Classic version
