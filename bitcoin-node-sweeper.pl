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
## Begin building the command line to create the initial PSBT.
########################################################################
$base_command="$rpc_cli createpsbt \"[";

foreach $wallet (@allWallets){
  for($utxos=0; $utxos < $max_utxos; $utxos++){
    $txid=`$rpc_cli -rpcwallet=$wallet listunspent | jq -r '.[$utxos] | .txid'`;
    chomp($txid);
    $vout=`$rpc_cli -rpcwallet=$wallet listunspent | jq -r '.[$utxos] | .vout'`;
    chomp($vout);
    $local_amount=`$rpc_cli -rpcwallet=$wallet listunspent | jq -r '.[$utxos] | .amount'`;
    chomp($local_amount);
    if($local_amount > 0){
      if($local_amount == .00010000){
	print "\n\nWARNING!  Amount looks like an ordinal!  Skipping wallet: $wallet\n\n";
	next;
      }
      $amount+=$local_amount;
      $base_command .= "{\\\"txid\\\":\\\"" . $txid ."\\\",\\\"vout\\\":" . $vout . "},";
      push @utxo_wallets, $wallet;  ## Make sure we don't try to sign with wallets that aren't involved in this transaction
    }
    else{
      if($utxos == 0){
	print "Ignoring wallet $wallet with no UTXOs.\n";
      }
      last;
    }
  }
}

################################################################
## Trim last comma between all the UTXO inputs
chop($base_command);
################################################################

################################################################
## Get current fee rate for target confirmations
################################################################
$estimated_fee_rate = `$rpc_cli estimatesmartfee $confirmations | jq -r .feerate` / 1024;   ## Result is BTC/vkB, so divide by 1024

################################################################
## Get the size of the transaction so we can estimate fees
################################################################
$dummy_fee = "0.00000001";                                                   ## use 1 SAT for dummy fee to minimize failures on creating the PSBT in the first place
$estimate_command=$base_command . "]\" \"[{\\\"" . $recipient . "\\\":" . sprintf("%0.010f",$amount - $dummy_fee) . "}]\"";
$initial_psbt = `$estimate_command`;
chomp($initial_psbt);
$vsize = `$rpc_cli decodepsbt \"$initial_psbt\" | jq -r .tx.vsize`;
chomp($vsize);
$estimated_fees = $vsize * $estimated_fee_rate + 15*scalar(@utxo_wallets);  ## Adding additional vbytes for the signatures that weren't previously included
$estimated_fees = sprintf("%0.8f",$estimated_fees);
printf("The estimated fee rate for $confirmations-block confirmation is %0.2f/vB or %0.8f total BTC. (%0.3f%s of %0.8f)\n\n",$estimated_fee_rate * 100000000,$estimated_fees,$estimated_fees/$amount*100, "%",$amount);

################################################################
## Create actual PSBT 
################################################################
$sweep_amount = $amount - $estimated_fees;
$base_command=$base_command . "]\" \"[{\\\"" . $recipient . "\\\":" . sprintf("%0.010f",$sweep_amount) . "}]\"";
$initial_psbt = `$base_command`;
chomp($initial_psbt);

################################################################
## Now have each wallet add their inputs.
################################################################
foreach $wallet (@utxo_wallets){
  $new_psbt = `$rpc_cli -rpcwallet=$wallet walletprocesspsbt \"$initial_psbt\" | jq -r .psbt`;
  chomp($new_psbt);
  $initial_psbt = $new_psbt;
}

################################################################
## Now have each wallet fully sign.
################################################################
foreach $wallet (@utxo_wallets){
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


