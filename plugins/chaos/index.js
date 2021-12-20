const child_process = require("child_process");
const fetch = require("cross-fetch");
const { asyncSleep } = require("./helper");

const waitIntervalMilsec = 60 * 1000 * 2; // 120s
const URL = "http://localhost:6101";

const jamMethod = "jam_ckb_network";
const jamTotal = 1000;
const jamParams = `total=${jamTotal}`;

const depositMethod = "prepare_jam_accounts";
const depositTotal = 1000;
const depositParams = `total=${depositTotal}`;

const delayCmd =
  "pumba netem --duration 50s --tc-image gaiadocker/iproute2 delay --time 3000 docker_ckb3_1 & pumba netem --duration 50s --tc-image gaiadocker/iproute2 delay --time 3000 docker_ckb2_1";

const callJam = async () => {
  console.log("call jam ckb network..");
  await fetch(`${URL}/${jamMethod}?${jamParams}`);
};

const callPrepareAccounts = async () => {
  console.log("call prepare accounts..");
  await fetch(`${URL}/${depositMethod}?${depositParams}`);
};

const callDelayCkbNetwork = () => {
  console.log("delay ckb network..");
  child_process.exec(delayCmd);
};

const run = async () => {
  let counter = 0;
  while (true) {
    console.log(`start ${counter}th chaos..`);
    if ((counter >= 3 || counter === 0) && counter % 3 === 0) {
      // deposit accounts every 3th loop
      await callPrepareAccounts();
    }
    callJam();
    callDelayCkbNetwork();

    counter++;
    await asyncSleep(waitIntervalMilsec);
  }
};

run();
