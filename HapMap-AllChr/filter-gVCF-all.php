<?php

$file1 = $argv[1];

$pattern = '/g\.vcf/';
$replacement = 'all.g.vcf';
$file2 = preg_replace($pattern, $replacement, $file1);

$min_gq = 30;
$fh1 = fopen($file1, "r") or die("Error $file1\n");
$fh2 = fopen($file2, "w") or die("Error $file2\n");
$count = 0;
$count_skip = 0;
$count_skip_rd = 0;
$line1 = fgets($fh1);
while (preg_match("/^#/", $line1)) {
    $pattern = '/chr(\d)(\w)_part(\d)/';
    $replacement = '$1$2$3';
    $line2 = preg_replace($pattern, $replacement, $line1);
    fwrite($fh2, $line2);
    $line1 = fgets($fh1);
}
while(!feof($fh1)) {
    $lineA = explode("\t", $line1);
    $qual = $lineA[5];
    $info = $lineA[8];
    $tmp3 = explode(":", $info);
    foreach ($tmp3 as $key=>$val) {
            if ($val == "GT") {
                $posGT = $key;
            } elseif ($val == "DP") {
                $posDP = $key;
            } elseif ($val == "GQ") {
                $posGQ = $key;
            }
    }
    $tmp1 = trim($lineA[9]);
    $tmp2 = explode(":", $tmp1);
    $gq = $tmp2[$posGQ];
    if ($qual == ".") {
        if ($gq > $min_gq) { 
            fwrite($fh2, $line2);
        }
    } elseif (isset($tmp2[$posGQ])) {
        $dp = $tmp2[$posDP];
            $gt = $tmp2[$posGT];
            if ($gq > $min_gq) {
               if (($gt == "0/1") || ($gt == "1/0")) {
               } elseif (($gt == "1/1") || ($gt == "0/0")) {
                   fwrite($fh2, $line2);
               } else {
                   echo "Bad allele $line1\n";
               }
            } else {
               $count_skip++;
            } 
    } else {
        echo "Error: $tmp1 $pos\n";
    }
    $line1 = fgets($fh1);
    $line2 = preg_replace($pattern, $replacement, $line1);
    $count++;
}
echo "$count_skip skip, gq < min_gq\n";
echo "$count_skip_rd skip read depth\n";
