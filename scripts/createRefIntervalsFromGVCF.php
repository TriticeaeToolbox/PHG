<?php

/*
* Create Reference Ranges for gVCF
* expand 10,000
* gap 100
* The script reads in gVCF files and creates bed file for loading into PHG
*/

$testing = false;

$minQUAL = 30;
$minGQ = 40;
$flank = 200;
$expand = 10000;

$file = "161010_Chinese_Spring_v1.0_pseudomolecules_parts_to_chr.bed";
$fh = fopen($file, "r") or die("Error: $file\n");
while (!feof($fh)) {
    $line = fgetcsv($fh, 0, "\t");
    $chrom_part = $line[0];
    $chrom = $line[3];
    $start = $line[4];
    $stop = $line[5];
    if ($start == 0) {
        $translate_list[$chrom] = $stop;
        echo "$chrom $stop\n";
    }
}
fclose($fh);

$count_file = 0;
$dir = "gvcfs";
$files = scandir($dir);
foreach ($files as $value) {
    if (preg_match("/bam.g.vcf$/", $value)) {
        echo "$value\n";
        $file = $dir . "/" . $value;
        $fh = fopen($file, "r") or die("Error $value");
        $count = 0;
        $count_file++;
        while (!feof($fh)) {
            $count++;
            $line1 = fgets($fh);
            if (!preg_match("/^#/", $line1)) {
                $lineA = explode("\t", $line1);
                $chr = $lineA[0];
                $pos = $lineA[1];
                $qual = $lineA[5];
                $info = $lineA[8];
                $tmp1 = $lineA[9];
                $tmp2 = explode(":", $tmp1);
                $gt = $tmp2[0];
                $gq = $tmp2[3];
                if ($qual > 30) { 
                    if (($gt == "0/0") || ($gt == "1/1")) {
                        $homo = 1;
                        if (isset($homo_cnt[$chr])) {
                            $hom_cnt[$chr]++;
                        } else {
                            $hom_cnt[$chr] = 1;
                        }
                    } else {
                        $homo = 0;
                        if (isset($het_cnt[$chr])) {
                            $het_cnt[$chr]++;
                        } else {
                            $het_cnt[$chr] = 1;
                        }
                    }
                    if (($gq > 40) && ($homo == 1)) {
                        if (isset($good_list[$chr][$pos])) {
                            $good_list[$chr][$pos]++;   // .= substr($value,0,5);
                        } else {
                            $good_list[$chr][$pos] = 1; //substr($value,0,5);
                        }
                    }
                }
                if (($testing) && ($count > 100000)) {
                    break;
                }
            }
        }
        fclose($fh);
        if (($testing) && ($count_file > 10)) {
            break;
        }
    }
}

echo "chrom\thomo\thet\n";
foreach ($hom_cnt as $chr => $val) {
    echo "$chr\t$hom_cnt[$chr]\t$het_cnt[$chr]\n";
}

$file = "intervals-exome.bed";
$fh = fopen($file, "w") or die("Error $file\n");

//convert to intervals
foreach ($good_list as $chrom => $val1) {
    $tmp = $good_list[$chrom];
    ksort($tmp);
    $data = array();
    $data_snp = array();
    foreach ($tmp as $key => $val2) {
        $data[] = array($key - 200, $key + 200);
        $data_snp[] = $val2;   //"$val2-$key";
    }
    $count = count($data);
    echo "$count for $chrom\n";

    $gap = 10000;
    $n = 0;
    $len = count($data);
    for ($i = 1; $i < $len; ++$i) {
        $pos1 = $data[$n][0] . " " . $data[$n][1];
        $pos2 = $data[$i][0] . " " . $data[$i][1];
        $snps = $data_snp[$i];
        if ($data[$i][0] > $data[$n][1] + $gap) { //no overlap
            $n = $i;
            //echo "skip $pos1 $pos2 $snps\n";
        } elseif ($data[$n][1] < $data[$i][1] + $gap) { //overlap
            $data[$n][1] = $data[$i][1];
            $pos3 = $data[$n][0] . " " .  $data[$n][1];
            //echo "overlap $pos1 $pos2 $pos3 $snps\n";
            $data_snp[$n] .= ",$data_snp[$i]";
            unset($data[$i]);
            unset($data_snp[$i]);
        } else { //contained in
            $pos3 = $data[$n][0] . " " .  $data[$n][1];
            echo "contained $pos1 $pos2 $pos3 $snps";
            $data_snp[$n] .= ",$data_snp[$i]";
            unset($data[$i]);
            unset($data_snp[$i]);
        }
    }
    $count1 = count($data);
    echo "$count1 from gvcf after merging\n";
 
    foreach ($data as $key => $value) {
        fwrite($fh, "$chrom\t$value[0]\t$value[1]\t$data_snp[$key]\n");
    }
}
