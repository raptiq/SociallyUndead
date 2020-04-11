const fs = require("fs");
const BWL_LOOT = require("../bwl_loot.json");
const MC_LOOT = require("../mc_loot.json");
const ZG_LOOT = require("../zg_loot.json");

const buildDefaultMCLua = (id) => {
  return `\t[${id}]={["dkp"]="5",["role"]="MS > OS"},\n`;
};

const getRole = (item) => {
  return item["role"] || (item["dkp"] === "NA" ? "" : "MS > OS");
};

const buildItemLua = (item) => {
  return `\t[${item["id"]}]={["name"]="${item["name"] || ""}",["dkp"]="${
    item["dkp"] || 5
  }",["role"]="${getRole(item)}",["note"]="${item["note"] || ""}"},\n`;
};

const file = fs.createWriteStream(
  "./SociallyUndead/generated/GeneratedLoot.lua",
  {}
);

file.on("open", () => {
  file.write("local _, core = ...\n");
  file.write("core.lootDb = {\n");

  for (let item of BWL_LOOT) {
    file.write(buildItemLua(item));
  }

  for (let item of MC_LOOT) {
    file.write(buildItemLua(item));
  }

  for (let item of ZG_LOOT) {
    file.write(buildItemLua(item));
  }

  file.write("}\n");
  file.end();
});
