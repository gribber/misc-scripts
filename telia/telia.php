#!/usr/bin/php -q
<?php
include("curl.php");
//$url = 'http://192.168.1.1/dsl_ajax.lp';
//$data = file_get_contents($url);
$data = $remotePage;

list($status, $uptime, $type, $rateup, $ratedown, $noiseup, $noisedown, $attup, $attdown, $powerup, $powerdown) = explode(",", $data);

list($rateup, $d) = explode(' ', $rateup);
list($ratedown, $d) = explode(' ', $ratedown);
list($noiseup, $d) = explode(' ', $noiseup);
list($noisedown, $d) = explode(' ', $noisedown);
list($attup, $d) = explode(' ', $attup);
list($attdown, $d) = explode(' ', $attdown);
list($powerup, $d) = explode(' ', $powerup);
list($powerdown, $d) = explode(' ', $powerdown);
$type = trim($type);
//echo("noise up: $noiseup, down: $noisedown, attenuation up $attup, down: $attdown, power up: $powerup, down: $powerdown\n");

$cmd = "isp,name=\"telia\" dslstatus=\"$status\",dsltype=\"$type\",dsluptime=$uptime,linerateup=$rateup,lineratedown=$ratedown,noisemarginup=$noiseup,noisemargindown=$noisedown,attenuationup=$attup,attenuationdown=$attdown,powerup=$powerup,powerdown=$powerdown";
//echo($cmd . "\n");
shell_exec("influx -execute 'INSERT " . $cmd . "' -database=telia");


?>
