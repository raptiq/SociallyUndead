// EXTRACT VALUE FOR HTML HEADER.
// ('Book ID', 'Book Name', 'Category' and 'Price')

const buildTableFromJSON = (elementId, data) => {
  let col = [];
  for (let i = 0; i < data.length; i++) {
    for (let key in data[i]) {
      if (col.indexOf(key) === -1) {
        col.push(key);
      }
    }
  }

  let table = document.createElement("table");

  let tr = table.insertRow(-1);

  for (let i = 0; i < col.length; i++) {
    let th = document.createElement("th", { align: "center" });
    th.innerHTML = col[i];
    tr.appendChild(th);
  }

  for (let i = 0; i < data.length; i++) {
    tr = table.insertRow(-1);

    for (let j = 0; j < col.length; j++) {
      let tabCell = tr.insertCell(-1);
      tabCell.innerHTML = data[i][col[j]];
    }
  }

  let divContainer = document.getElementById(elementId);
  divContainer.innerHTML = "";
  divContainer.appendChild(table);
};

const buildBWLLootTable = async () => {
  const response = await fetch(
    "https://raw.githubusercontent.com/raptiq/SociallyUndead/master/bwl_loot.json"
  );

  const data = await response.json();

  console.log(data);

  buildTableFromJSON("bwl-loot", data);
};

const init = () => {
  buildBWLLootTable();
};

init();
