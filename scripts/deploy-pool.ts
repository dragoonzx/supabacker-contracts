// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import SupabackerDefiPoolV1Artifacts from "../artifacts/contracts/SupabackerDefiPoolV1.sol/SupabackerDefiPoolV1.json";
import {
  AccountBalanceQuery,
  AccountId,
  PrivateKey,
  Client,
  FileCreateTransaction,
  ContractCreateTransaction,
  FileAppendTransaction,
} from "@hashgraph/sdk";
import { assert } from "console";

async function main() {
  assert(process.env.PRIVATE_KEY != null);
  const operatorId = AccountId.fromString(
    process.env.OPERATOR_ID == null ? "" : process.env.OPERATOR_ID
  );
  const operatorKey = PrivateKey.fromString(
    process.env.PRIVATE_KEY == null ? "" : process.env.PRIVATE_KEY
  );

  const client = Client.forTestnet().setOperator(operatorId, operatorKey);

  const fileCreateTx = new FileCreateTransaction()
    .setKeys([operatorKey])
    .freezeWith(client);

  const fileCreateSign = await fileCreateTx.sign(operatorKey);
  const fileCreateSubmit = await fileCreateSign.execute(client);
  const fileCreateRx = await fileCreateSubmit.getReceipt(client);
  const bytecodeFileId = fileCreateRx.fileId ? fileCreateRx.fileId : "";
  console.log(`- The bytecode file ID is: ${bytecodeFileId} \n`);

  const query = new AccountBalanceQuery().setAccountId(
    process.env.OPERATOR_ID == null ? "" : process.env.OPERATOR_ID
  );

  // Submit the query to a Hedera network
  const accountBalance = await query.execute(client);

  // Print the balance of hbars
  console.log(
    "The hbar account balance for this account is " + accountBalance.hbars
  );

  const fileAppendTx = new FileAppendTransaction()
    .setFileId(fileCreateRx.fileId ? fileCreateRx.fileId : "")
    .setContents(SupabackerDefiPoolV1Artifacts.bytecode)
    .setMaxChunks(40);

  const fileAppendSubmit = await fileAppendTx.execute(client);
  const fileAppendRx = await fileAppendSubmit.getReceipt(client);

  console.log("Content added " + fileAppendRx.status);

  const contractInstantiateTx = new ContractCreateTransaction()
    .setBytecodeFileId(bytecodeFileId)
    .setGas(3000000);

  const contractInstantiateSubmit = await contractInstantiateTx.execute(client);
  const contractInstantiateRx = await contractInstantiateSubmit.getReceipt(
    client
  );
  const contractId = contractInstantiateRx.contractId;
  const contractAddress = contractId?.toSolidityAddress();

  console.log("Contract deployed to " + contractAddress);
  console.log("With id " + contractId);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  // process.exitCode = 1;
});
