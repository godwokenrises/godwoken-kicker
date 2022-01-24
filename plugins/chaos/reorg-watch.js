const {
  RequestManager,
  HTTPTransport,
  Client,
} = require("@open-rpc/client-js");
const { asyncSleep } = require("./helper");

const transport = new HTTPTransport("http://127.0.0.1:8114/");
const client = new Client(new RequestManager([transport]));

const miner_1 = "0x43d509d97f26007a285f39241cffcd411157196c";
const miner_2 = "0xc48a45e11c66b2c8b5c61f6036486ad4d9d2fd29";
const miner_3 = "0xb33248c08c55ed636d2f00d065d223ec1a0d333a";

async function send(method, param) {
  const result = await client.request({ method: method, params: param });
  return result;
}

const getMinerNameFromBlock = (block) => {
  const firstTransaction = block.transactions[0];
  if (!firstTransaction || !firstTransaction.outputs[0]) {
    // no transaction / no outputs in the first couple blocks
    return getMinerName(undefined);
  }

  const args = firstTransaction.outputs[0].lock.args;
  return getMinerName(args);
};

const getMinerName = (args) => {
  switch (args) {
    case miner_1:
      return "Alice";

    case miner_2:
      return "Bob";

    case miner_3:
      return "Susan";

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

  const lastBlockProducer = getMinerNameFromBlock(lastBlock);

  const date = new Date();
  console.log(`${date.toString()}`);
  console.log(
    `lastTip   : ${parseInt(
      lastTip
    )}, lastTipBlockHash: ${lastTipBlockHash}, lastBlockProducer: ${lastBlockProducer}`
  );
  let waitTimeSeconds = 0;
  while (true) {
    await asyncSleep(100); // 0.1 seconds
    waitTimeSeconds++;

    const blockNumber2 = (await send("get_tip_header", [])).number;
    if (parseInt(blockNumber2) >= parseInt(blockNumber) + 1) {
      const lastBlockHash = (await send("get_header_by_number", [lastTip]))
        .hash;
      const currentBlockHash = (
        await send("get_header_by_number", [blockNumber2])
      ).hash;
      const block = await send("get_block", [currentBlockHash]);
      const currentBlockProducer = getMinerNameFromBlock(block);
      console.log(
        `currentTip: ${parseInt(
          blockNumber2
        )}, lastTipBlockHash: ${lastBlockHash}, currentBlockProducer: ${currentBlockProducer}, currentBlockHash: ${currentBlockHash}`
      );
      if (lastBlockHash !== lastTipBlockHash) {
        console.log(
          `chain reorgs! => ${parseInt(
            lastTip
          )}, rollback: ${lastBlockHash}, origin: ${lastTipBlockHash}`
        );
      }
      console.log(`block time: ${waitTimeSeconds / 10}s`);
      break;
    }
  }

  console.log("");
  await run();
};

run();
