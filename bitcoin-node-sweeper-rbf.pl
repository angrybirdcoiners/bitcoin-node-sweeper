#!/usr/bin/perl
require "./variables.pl";

########################################################################
## Find Wallets - This only works for loaded wallets (e.g they must be in the
##     bitcoin.conf file and set to load at restart, or have been manually loaded
##     in the meantime
########################################################################
$wallet_output = `$rpc_cli listwallets`;
my @wallets = split "\n", $wallet_output;
push @wallets, @manual_wallets;  ## add manual wallets, but check for syntax

while($wallet = shift @wallets){
  if($wallet =~ m/\"([\w\-\_]+)\"/){
    push @allWallets, $1;
  }
}

########################################################################
## First, get all UTXOs from the TX we want to replace
########################################################################
$ARGV[0] =~ m/^(\w{64})$/;
$txid = $1;
if(!$txid){
  print "No TXID specified!\n";
  print "Usage:  bitcoin-node-sweeper-rbf.pl TXID\n";
  exit;
}

$rbf_base_command = "$rpc_cli createpsbt \"[";
$old_tx_utxos = `$rpc_cli getrawtransaction $txid`;
chomp($old_tx_utxos);

for($utxos=0; $utxos < $max_utxos; $utxos++){
  $txid=`$rpc_cli decoderawtransaction $old_tx_utxos | jq -r '.vin[$utxos].txid'`;
  chomp($txid);
  if($txid eq "null"){
    print "No more txid's\n";
    last;
  }
  chomp($txid);
  $vout=`$rpc_cli decoderawtransaction $old_tx_utxos  | jq -r '.vin[$utxos].vout'`;
  chomp($vout);
  ## We actually just need to set sequence number >0, <4294967294
  $rbf_base_command .= "{\\\"txid\\\":\\\"" . $txid ."\\\",\\\"vout\\\":" . $vout . ", \\\"sequence\\\": " . sprintf("%s",1) ."},";
}
################################################################
## Trim last comma between all the UTXO inputs
chop($rbf_base_command);
################################################################

$send_amount=`$rpc_cli decoderawtransaction $old_tx_utxos  | jq -r '.vout[0].value'`;
chomp($send_amount);
$rbf_base_command=$rbf_base_command . "]\" \"[{\\\"" . $recipient . "\\\":" . sprintf("%0.8f",$send_amount*.95) . "}]\" 0 true";
$initial_psbt = `$rbf_base_command`;
chomp($initial_psbt);

################################################################
## Now have each wallet add their inputs.
################################################################
foreach $wallet (@allWallets){
  $new_psbt = `$rpc_cli -rpcwallet=$wallet walletprocesspsbt \"$initial_psbt\" | jq -r .psbt`;
  chomp($new_psbt);
  $initial_psbt = $new_psbt;
}

################################################################
## Now have each wallet fully sign.
################################################################
foreach $wallet (@allWallets){
  $new_psbt = `$rpc_cli -rpcwallet=$wallet walletprocesspsbt \"$initial_psbt\" | jq -r .psbt`;
  chomp($new_psbt);
  $initial_psbt = $new_psbt;
}
################################################################
## Verify All Inputs are Signed
################################################################
print `$rpc_cli analyzepsbt \"$initial_psbt\"` . "\n";
print `$rpc_cli decodepsbt \"$initial_psbt\"` . "\n";

################################################################
## Finalize the PSBT into hex format for broadcast
################################################################
$raw_tx_hex = `$rpc_cli finalizepsbt \"$initial_psbt\" | jq -r .hex`;
chomp($raw_tx_hex);

print "WARNING: VERIFY ALL INPUTS/OUTPUTS BEFORE BROADCASTING THIS TRANSACTION!!\n";
print "         When you are ready, execute the following command to braodcast this transaction\n\n";
print "$rpc_cli sendrawtransaction \"$raw_tx_hex\"\n";


