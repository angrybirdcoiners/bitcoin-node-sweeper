Bitcoin Node Sweeper
=====================================

Bitcoin Node Sweeper is a lightweight Perl script that uses bitcoin-cli via RPC to
sweep all of the UTXOs out of your node's wallets to a single address via a single PSBT.

Why Bitcoin Node Sweeper?
---------------------

As a Bitcoin Ordinal creator, my standard workflow was to use unique wallets for each inscription.  Often times,
I would fund each wallet with more sats than necessary to ensure there were enough funds. Once inscribed,
there would often be dust left in each of the potentially hundreds of individual wallets. Usually, the amount left
over would be too little to send out in it's own transaction.

Hat Tip
-------
Thanks to the BlockchainCommons folks who have done a fantastic job of walking through many of these concepts, which I leaned on heavily.
https://github.com/BlockchainCommons/Learning-Bitcoin-from-the-Command-Line 

License
-------

Bitcoin Node Sweeper is released under the terms of the MIT license. See https://opensource.org/licenses/MIT for more
information.

Usage 
-------------------
### 1. Update Variables
Modify [variables.pl](variables.pl) to fill in your node's RPC information, final payout address, and the number of target confirmations. You can also add any other wallets that may not be loaded into Bitcoind.  If bitcoind needs to scan/update those wallets, the behavior could be indeterminate.  
### 2. Execute
Run bitcoin-node-sweeper:

```
$ perl bitcoin-node-sweeper.pl
```
### 3. Verify
Verify the inputs and outputs that are printed.

### 4. Broadcast Transaction
Copy/paste the command to broadcast the raw transaction.

Sample Output
-------
Sample output from the run that produced this [transaction](https://mempool.space/tx/cb01f1b4a9eb2e090b42f7881780dfe47e5f4f7a7eec3dfaaea3d8b3d9280dea) is at [sample.txt](sample.txt).

Known Limitations
-------
1. It currently only handles wallets with numbers, letters, hypnens (-), and underscores (_).  Character class:  [\w\-\_]
2. Only tested up to 50 total UTXOs.
3. Only tested with wallets that were loaded on startup out of bitcoin.conf.


Bitcoin Node Sweeper - Replace by Fee
=====================================
This version allows you to resend a sweep transaction with replace by fee.

Usage 
-------------------
### 1. Execute
Run bitcoin-node-sweeper-rbf:

```
$ perl bitcoin-node-sweeper-rbf.pl PREVIOUSTXID
```
### 3. Verify
Verify the inputs and outputs that are printed.

### 4. Broadcast Transaction
Copy/paste the command to broadcast the raw RBF transaction.

Sample Output
-------
Sample output from the run that produced this [RBF Transaction](https://mempool.space/tx/a966a43ad8176f6fd2cd1c21f00c1867b5428d4864ef20cc4bda15bd0b84897d) is at [sample-rbf.txt](sample-rbf.txt).

