const {
  RequestManager,
  HTTPTransport,
  Client,
} = require("@open-rpc/client-js");
const transport = new HTTPTransport("http://127.0.0.1:8114/");
const client = new Client(new RequestManager([transport]));

const miner_1 = "0x43d509d97f26007a285f39241cffcd411157196c";
const miner_2 = "0xc48a45e11c66b2c8b5c61f6036486ad4d9d2fd29";

async function send(method, param) {
  const result = await client.request({ method: method, params: param });
  return result;
}

const asyncSleep = (ms = 0) => {
  return new Promise((r) => setTimeout(r, ms));
};

const getMinerName = (args) => {
  switch (args) {
    case miner_1:
      return "Alice";

    case miner_2:
      return "Bob";

    default:
      return "unknown miner";
  }
};

let lastTip;
let lastTipBlockHash;

const run = async () => {
  const blockNumber = (await send("get_tip_header", [])).number;

  lastTip = blockNumber;
  const header = await send("get_header_by_number", [lastTip]);
  const hash = header.hash;
  lastTipBlockHash = hash;

  const lastBlock = await send("get_block", [hash]);
  const lastBlockProducer = getMinerName(
    lastBlock.transactions[0].outputs[0].lock.args
  );

  console.log(
    `lastTip   : ${parseInt(
      lastTip
    )}, lastTipBlockHash: ${lastTipBlockHash}, lastBlockProducer: ${lastBlockProducer}`
  );
  let waitTimeSeconds = 0;
  while (true) {
    await asyncSleep(1000); // 1 seconds
    waitTimeSeconds++;

    const blockNumber2 = (await send("get_tip_header", [])).number;
    if (parseInt(blockNumber2) === parseInt(blockNumber) + 1) {
      const lastBlockHash = (await send("get_header_by_number", [lastTip]))
        .hash;
      const currentBlockHash = (
        await send("get_header_by_number", [blockNumber2])
      ).hash;
      const block = await send("get_block", [currentBlockHash]);
      const currentBlockProducer = getMinerName(
        block.transactions[0].outputs[0].lock.args
      );
      console.log(
        `currentTip: ${parseInt(
          blockNumber2
        )}, lastTipBlockHash: ${lastBlockHash}, currentBlockProducer: ${currentBlockProducer}, currentBlockHash: ${currentBlockHash}`
      );
      if (lastBlockHash !== lastTipBlockHash) {
        console.log(
          `chain reorgs! =>${lastTip}, ${lastBlockHash}, ${lastTipBlockHash}`
        );
      }
      console.log(`block time: ${waitTimeSeconds}s`);
      break;
    }
  }

  console.log("");
  await run();
};

run();
