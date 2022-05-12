import { ethers } from "hardhat";
import { SupabackerMarketplaceV1 } from "../typechain";

describe("Supabacker Marketplace test", function () {
  let marketplaceV1: SupabackerMarketplaceV1;

  beforeEach(async function () {
    const MarketplaceV1 = await ethers.getContractFactory(
      "SupabackerMarketplaceV1"
    );
    marketplaceV1 = await MarketplaceV1.deploy();
  });

  it("Should create project, donate & withdraw funds", async function () {
    await marketplaceV1.createProject("134n1jc1d1");
    await marketplaceV1.donateToProject(0, { value: 10000 });
    console.log("balance: " + (await marketplaceV1.getProjectBalance(0)));
    console.log("count: " + (await marketplaceV1.getProjectsCount()));
    await marketplaceV1.withdrawFunds(0);
    console.log("balance: " + (await marketplaceV1.getProjectBalance(0)));
  });
});
