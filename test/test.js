const { expect } = require("chai");
const { ethers } = require("hardhat");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");

describe("Multi Sig Wallet Contract", () => {
  beforeEach(async () => {
    [owner, signer2, signer3, signer4] = await ethers.getSigners();
    let allSigners = [
      owner.address,
      signer2.address,
      signer3.address,
      signer4.address,
    ];
    MultiSig = await ethers.getContractFactory("MultiSigWallet", owner);
    multiSigWallet = await MultiSig.deploy(allSigners);
  });

  describe("initiateTransaction", () => {
    it("Creates a new transaction that will need to be signed by the signers", async () => {
      let initialSingerAddress = signer2.address;
      let amountSend = "100000000000000000";
      let initialTransaction = await multiSigWallet.initiateTransaction(
        initialSingerAddress,
        amountSend,
        "0x"
      );
    });
  });
});
