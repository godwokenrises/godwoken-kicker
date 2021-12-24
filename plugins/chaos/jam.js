const fetch = require("cross-fetch");
const { asyncSleep } = require("./helper");

const waitIntervalMilsec = 1000;
const URL = "http://localhost:6101";

const jamMethod = "jam_ckb_network";
const jamTotal = 1000;
const jamParams = `total=${jamTotal}`;

const run = async () => {
  let i = 0;
  
  while (true) {
    i++;

    await fetch(`${URL}/${jamMethod}?${jamParams}`);
    console.log(`start ${i}th jam ckb node..`);
    await asyncSleep(waitIntervalMilsec);
  }
};

run();
