const fetch = require("cross-fetch");
const { asyncSleep } = require("./helper");

const waitIntervalMilsec = 3000; // every 3 seconds
const URL = "http://localhost:6101";

const depositMethod = "prepare_jam_accounts"
const depositTotal = 1000;
const depositParams = `total=${depositTotal}`; 

const run = async () => {
  let i = 0;
  
  while (true) {
    i++;
    await fetch(`${URL}/${depositMethod}?${depositParams}`);
    console.log(`deposit ${i}th for total ${depositTotal} accounts...`);
    await asyncSleep(waitIntervalMilsec);
  }
};

run();
