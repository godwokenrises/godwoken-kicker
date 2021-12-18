const {
  RequestManager,
  HTTPTransport,
  Client,
} = require("@open-rpc/client-js");
const child_process = require("child_process");
const { connect } = require("http2");
const ckbNode1 = new HTTPTransport("http://127.0.0.1:8114/");
const ckbNode2 = new HTTPTransport("http://127.0.0.1:8117/");
const ckbNode3 = new HTTPTransport("http://127.0.0.1:6117/");

const client1 = new Client(new RequestManager([ckbNode1]));
const client2 = new Client(new RequestManager([ckbNode2]));
const client3 = new Client(new RequestManager([ckbNode3]));

async function send1(method, param) {
  const result = await client1.request({ method: method, params: param });
  return result;
}

async function send2(method, param) {
  const result = await client2.request({ method: method, params: param });
  return result;
}

async function send3(method, param) {
  const result = await client3.request({ method: method, params: param });
  return result;
}

async function connectNode2(){
  const nodeInfo = await send2("local_node_info");
  const id = nodeInfo.node_id;

  const containerName = "docker_ckb2_1";
  const getIpCmd = `docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${containerName}`;
  const ip = child_process.execSync(getIpCmd).toString().trim();
  const ipAddress = `/ip4/${ip}/tcp/8118`;

  console.log(id, ipAddress);

  const result = await send1("add_node", [id, ipAddress]);
  console.log(result);
}

async function connectNode3() {
  // node2
  const nodeInfo = await send3("local_node_info");
  const id = nodeInfo.node_id;

  const containerName = "docker_ckb3_1";
  const getIpCmd = `docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${containerName}`;
  const ip = child_process.execSync(getIpCmd).toString().trim();
  const ipAddress = `/ip4/${ip}/tcp/6118`;

  console.log(id, ipAddress);

  const result = await send2("add_node", [id, ipAddress]);
  console.log(result);
}

async function run() {
  await connectNode2();
  await connectNode3();
}

run();
