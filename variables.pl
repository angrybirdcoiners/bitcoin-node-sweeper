########################################################################
### Node Variables
########################################################################
$rpcpassword="passwordstring";
$rpcuser="bitcoin";
$rpcconnect="node.local";  ## IP/hostname of the Bitcoin node
$rpccookiefile="/data/bitcoin/.cookie";
$rpcport="8332";
$rpc_cli = "bitcoin-cli --rpccookiefile=$rpccookiefile --rpcuser=$rpcuser --rpcconnect=$rpcconnect --rpcport=$rpcport -rpcpassword=\"$rpcpassword\"  -rpcclienttimeout=3600 ";

########################################################################
##### Recipient Address
########################################################################
$recipient="3APKi7vek4D7GunkVmc6b8q2kP8jeXBxsj";

########################################################################
## Manually Add Wallets - Provide a list of wallets that are not already
##      loaded into bitcoind.
##      Add wallets by adding comma-separated wallet strings
##      ex.  @manual_wallets = ("wallet1", "wallet2", "wallet3")
########################################################################
@manual_wallets = ("" "" "");

########################################################################
##### Target Confirmations
########################################################################
$confirmations = 3;

########################################################################
##### Max UTXOs Per Wallet to Check
########################################################################
$max_utxos = 100;

########################################################################
##### DO NOT MODIFY BELOW
##### Required for the 'require' command
########################################################################
1;
