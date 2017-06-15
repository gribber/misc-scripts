<?php
$loginUrl = 'http://192.168.1.1/login.lp'; //action from the login form
$remotePageUrl = 'http://192.168.1.1/dsl_ajax.lp'; //url of the page you want to save  

$pre = getUrl($loginUrl);
preg_match_all('/name="rn" value="(.+?)"/', $pre, $matches);
//print_r($matches);
$rnd = $matches[1][1];
//echo("rn: " . $rnd . "\n");

preg_match('/nonce = "(.+?)"/', $pre, $n);

$realm = "Technicolor Gateway";
$nonce = $n[1];
$qop = 'auth';
$uri = '/login.lp';
$user = 'Administrator';
$password = 'xxxxxxxxx';

$HA1 = md5($user . ':' . $realm . ':' . $password);
$HA2 = md5('GET:' . $uri);
$hidepw	= md5($HA1 . ':' . $nonce . ':' . '00000001:xyz:' . $qop . ':' . $HA2);

$loginFields = array('user'=>$user, 'password'=>$password, 'rn'=>$rnd, 'hidepw'=>$hidepw, '6'=>'en'); //login form field names and values

$login = getUrl($loginUrl, 'post', $loginFields); //login to the site

$remotePage = getUrl($remotePageUrl); //get the remote page

function getUrl($url, $method='', $vars='') {
    $ch = curl_init();
    if ($method == 'post') {
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $vars);
    }
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
    curl_setopt($ch, CURLOPT_COOKIEJAR, 'cookies.txt');
    curl_setopt($ch, CURLOPT_COOKIEFILE, 'cookies.txt');
    $buffer = curl_exec($ch);
    curl_close($ch);
    return $buffer;
}
//echo($remotePage);
?>
