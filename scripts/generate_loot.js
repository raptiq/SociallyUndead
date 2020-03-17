const fs = require("fs");
const BWL_LOOT = require("../bwl_loot.json");
const MC_LOOT = require("../mc_loot.json");

const buildDefaultMCLua = id => {
  return `\t[${id}]={["dkp"]="5",["role"]="MS > OS"},\n`;
};

const buildItemLua = item => {
  return `\t[${item["id"]}]={["name"]="${item["name"]}",["dkp"]="${
    item["dkp"]
  }",["note"]="${item["note"] || ""}",["role"]="${item["role"]}"},\n`;
};

const file = fs.createWriteStream(
  "./SociallyUndead/generated/GeneratedLoot.lua",
  {}
);

file.on("open", () => {
  file.write("local addonName, addonData = ...\n");
  file.write("addonData.lootDb = {\n");

  for (let item of BWL_LOOT) {
    file.write(buildItemLua(item));
  }

  for (let item of MC_LOOT) {
    if (typeof item === "object") {
      file.write(buildItemLua(item));
    } else {
      file.write(buildDefaultMCLua(item));
    }
  }

  file.write("}\n");
  file.end();
});
