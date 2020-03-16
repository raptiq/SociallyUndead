const fs = require("fs");
const BWL_LOOT_LIST = require("../bwl_loot.json");

const MC_LOOT_IDS = require("../mc_loot_ids.json");

const file = fs.createWriteStream("./src/generated/GeneratedLoot.lua", {});

file.on("open", () => {
  file.write("local addonName, addonData = ...\n");
  file.write("addonData.lootDb = {\n");

  for (let loot of BWL_LOOT_LIST) {
    file.write(
      `\t[${loot["id"]}]={["name"]="${loot["name"]}",["dkp"]="${
        loot["dkp"]
      }",["note"]="${loot["note"] || ""}",["role"]="${loot["role"]}"},\n`
    );
  }

  for (let id of MC_LOOT_IDS) {
    file.write(`\t[${id}]={["dkp"]="5",["role"]="MS > OS"},\n`);
  }

  file.write("}\n");
  file.end();
});
