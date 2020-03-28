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

const buildBWLLootTable = async () => {
  const response = await fetch(
    "https://raw.githubusercontent.com/raptiq/SociallyUndead/master/bwl_loot.json"
  );

  const data = await response.json();

  buildTableFromJSON("bwl-loot", data);
};

const init = () => {
  buildBWLLootTable();
};

init();
