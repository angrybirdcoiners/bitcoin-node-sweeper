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

License
-------

Bitcoin Node Sweeper is released under the terms of the MIT license. See https://opensource.org/licenses/MIT for more
information.

Usage 
-------------------
## 1. Modify [variables.pl](variables.pl) to fill in your node's RPC information, final payout address, and the number of target confirmations. You can also add any other wallets that may not be loaded into Bitcoind.  If bitcoind needs to scan/update those wallets, the behavior could be indeterminate.  
## 2. Execute bitcoin-node-sweeper:

```
$ perl bitcoin-node-sweeper.pl
```

Known Limitations
-------
1. It currently only handles wallets with numbers, letters, hypnens (-), and underscores (_).  Character class:  [\w\-\_]
2. Only tested up to 75 total UTXOs.
3. Only tested with wallets that were loaded on startup out of bitcoin.conf.
