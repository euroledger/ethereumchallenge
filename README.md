# ETHEREUM CODING ASSIGNMENT

This challenge consists of three parts

1. Simple Proof of Work
Write a simple CLI script, that when given a 64-byte string, it finds a suitable 4-byte prefix so that, a
SHA256 hash of the prefix combined with the original string of bytes, has two last bytes as 0xca, 0xfe.
Script should expect the original string to be passed in hexadecimal format and should return two lines,
first being the SHA256 string found and second 4-byte prefix used (in hexadecimal format).

For example:
./simple-pow
129df964b701d0b8e72fe7224cc71643cf8e000d122e72f742747708f5e3bb6294c619604e52dcd8f54
46da7e9ff7459d1d3cefbcc231dd4c02730a22af9880c

Should return:
6681edd1d36af256c615bf6dcfcda03c282c3e0871bd75564458d77c529dcafe
00003997

You can use any programming language you are comfortable with.

To run the solution cd to 1_simple_proof_of_work, then run:

`npm install` 

Then 

`node simple_pow.js 794339D3F1F0E8F600261E500824A02343F594E7A8F42429EC9D37C81C4C4F44`

This gives output:

`68a9e2e72e9d910e0d7b3bc49fefd5f60f4dedc8693bbe30d6d83f209b8dcafe
00008ce5`

2. Simple Stake
Imagine you are a developer working on adding staking functionality to some ERC20 token. Some of
the work has already been done, but few methods are still missing and assigned to you to implement.
Please use repository https://github.com/wealthpal-ltd/dlt-recruitment/tree/master/tests/simple-pos
to download the smart contract from and fill in the missing code, to enable staking for that custom
ERC20 implementation.

Note #1: staking should allow any token holder to temporarily lock-in their funds in the contract by
calling method “stake”. To withdraw staked tokens, their owner should be able to use “unstake” method
to do so. To receive reward for staking, the method “reward” should be used. Annual interest rate is
hardcoded and set to 10%.

Note #2: fix all the bugs found as well.

Note #3: all interfaces used in the contract are the default ones taken from open source library
OpenZeppelin https://github.com/OpenZeppelin/openzeppelin-contracts-ethereum-package

Solution tested in Remix