const buildTableFromJSON = (elementId, data) => {
  let col = [];
  for (let i = 0; i < data.length; i++) {
    for (let key in data[i]) {
      if (key !== "id" && col.indexOf(key) === -1) {
        col.push(key);
      }
    }
  }

  let table = document.createElement("table");

  let tr = table.insertRow(-1);

  for (let i = 0; i < col.length; i++) {
    const th = document.createElement("th");
    th.className = "loot-col-header";
    th.innerHTML = col[i];
    tr.appendChild(th);
  }

  for (let i = 0; i < data.length; i++) {
    tr = table.insertRow(-1);

    const itemId = data[i].id;
    const link = `https://classic.wowhead.com/item=${itemId}`;

    for (let j = 0; j < col.length; j++) {
      const tabCell = tr.insertCell(-1);
      tabCell.innerHTML = `<a class="loot-table-link" href="${link}">${
        data[i][col[j]]
      }</a>`;
    }
  }

  const divContainer = document.getElementById(elementId);
  divContainer.appendChild(table);
};

const parseLoot = (data) => {
  return data.map((item) => ({
    id: item.id,
    name: item.name,
    role: item.role || "MS > OS",
    dkp: item.dkp || "5",
    note: item.note || "",
  }));
};

const buildBWLLootTable = async () => {
  const response = await fetch(
    "https://raw.githubusercontent.com/raptiq/SociallyUndead/master/bwl_loot.json"
  );

  const data = await response.json();

  const parsedData = parseLoot(data);
  buildTableFromJSON("bwl-loot", parsedData);
};

const buildZGLootTable = async () => {
  const response = await fetch(
    "https://raw.githubusercontent.com/raptiq/SociallyUndead/master/zg_loot.json"
  );

  const data = await response.json();

  const parsedData = parseLoot(data);

  buildTableFromJSON("zg-loot", parsedData);
};

const buildAQ40LootTable = async () => {
  const response = await fetch(
    "https://raw.githubusercontent.com/raptiq/SociallyUndead/master/aq_loot.json"
  );

  const data = await response.json();

  const parsedData = parseLoot(data);

  buildTableFromJSON("aq40-loot", parsedData);
};

const init = () => {
  buildBWLLootTable();
  buildZGLootTable();
  buildAQ40LootTable();
};

init();
