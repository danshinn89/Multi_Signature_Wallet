const { expectRevert } = require('@openzeppelin/test-helpers');
const { web3 } = require('@openzeppelin/test-helpers/src/setup');
const MultiSig = artifacts.require('MultiSig');

contract('MultiSig', (accounts) => {
    let multisig = null;
    before(async () => {
        multisig = await MultiSig.deployed();
    });


    it('Should create transfer', async () => {
        await multisig.createTransfer(100, accounts[5], { from: accounts[0] });
        const transfer = await multisig.transfers(0);
        assert(transfer.id.toNumber() === 0);
        assert(transfer.amount.toNumber() === 100);

    });

    it('Should Not create transfer', async () => {
        await expectRevert(
            multisig.createTransfer(100, accounts[5], { from: accounts[6] }
            ),
            'only approver allowed'
        );
    });

    it('Should NOT send transfer if quorum not reached', async () => {
        const balanceBefore = await web3.eth.getBalance(accounts[6])
        await multisig.createTransfer(100, accounts[6], { from: accounts[0] });
        await multisig.sendTransfer(0, { from: accounts[1] });
        const balanceAfter = await web3.eth.getBalance(accounts[6])
        assert(balanceAfter.sub(balanceBefore).isZero());

    });
});

