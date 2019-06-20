<?php

/**
 * Create Reference Ranges for gVCF
 * The script reads in gVCF files and creates bed file for loading into PHG
 */

$selChrom = "chr1A";

$testing = false;

$minQUAL = 30;
$minGQ = 40;
$expand = 200;
$gap = 10000;

$file = "161010_Chinese_Spring_v1.0_pseudomolecules_parts_to_chr.bed";
$fh = fopen($file, "r") or die("Error: $file\n");
while (!feof($fh)) {
    $line = fgetcsv($fh, 0, "\t");
    $chrom_part = $line[0];
    $chrom = $line[3];
    $start = $line[4];
    $stop = $line[5];
    if ($start == 0) {
        $translate_list[$chrom_part] = $stop;
        echo "$chrom_part $chrom $stop\n";
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
        $line1 = "";;
        while (preg_match("/^#/", $line1)) {
             $line1 = fgets($fh);
        }
        while (!preg_match("/^$selChrom/", $line1)) {
             $line1 = fgets($fh);
        }
        while (preg_match("/^$selChrom/", $line1)) {
            $lineA = explode("\t", $line1);
            $chr = $lineA[0];
            $pos = $lineA[1];
            $qual = $lineA[5];
            $tmp1 = $lineA[9];
            $tmp2 = explode(":", $tmp1);
            $gt = $tmp2[0];
            $gq = $tmp2[2];
            if ($qual > $minQUAL) {
                $count++;
                if ($gq > $minGQ) {
                    if (isset($good_list[$chr][$pos])) {
                        $good_list[$chr][$pos]++;
                    } else {
                        $good_list[$chr][$pos] = 1;
                    }
                }
             }
             $line1 = fgets($fh);
             if (($testing) && ($count > 100000)) {
                 break;
             }
        }
        fclose($fh);
        if (($testing) && ($count_file > 10)) {
            break;
        }
    }
}

if ($testing) {
    $file = "intervals-exome-test.bed";
} else {
    $file = "intervals-exome.bed";
}
$fh = fopen($file, "w") or die("Error $file\n");
echo "writing out $file\n";

//convert to intervals
foreach ($good_list as $chrom => $val1) {
    $tmp = $good_list[$chrom];
    ksort($tmp);
    $data = array();
    $data_snp = array();
    foreach ($tmp as $key => $val2) {
        if ($val2 > 1) {
            $data[] = array($key - $expand, $key + $expand);
            $data_snp[] = $val2;
        }
    }
    $count = count($data);
    echo "$count for $chrom\n";

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
            //$data_snp[$n] .= ",$data_snp[$i]";
            unset($data[$i]);
            unset($data_snp[$i]);
        } else { //contained in
            $pos3 = $data[$n][0] . " " .  $data[$n][1];
            echo "contained $pos1 $pos2 $pos3 $snps";
            //$data_snp[$n] .= ",$data_snp[$i]";
            unset($data[$i]);
            unset($data_snp[$i]);
        }
    }
    $count1 = count($data);
    echo "$count1 from gvcf after merging\n";
  
    //translate coordinates
    if (preg_match("/chr([A-Za-z]+)/", $chrom, $match)) {
        $chrom_tran = "U";
        $break = 999999999999;
    } elseif (preg_match("/chr(\d[A-Z])/", $chrom, $match)) {
        $chrom_tran = $match[1];
        $break = $translate_list[$chrom];
    } else {
        echo "Error: $chrom no match\n";
        $chrom_tran = "U";
        $break = 999999999999;
    }
 
    foreach ($data as $key => $value) {
        $tmp1 = $data[$key][0];
        $tmp2 = $data[$key][1];
        if (($chrom == "chrUN") || ($chrom == "chrUn")) {
            $chrom_part = "U";
        } elseif ($tmp1 > $break) {
            $tmp1 = $tmp1 - $break;
            $tmp2 = $tmp2 - $break;
            $chrom_part = $chrom_tran . "2";
        } elseif (($tmp2 > $break) && ($tmp1 < $break)) {
            echo "Error: $break $tmp1 $tmp2\n";
            $chrom_part = $chrom_tran . "1";
            $tmp2 = $break;
        } else {
            $chrom_part = $chrom_tran . "1";
        }
        $taxonCnt = $data_snp[$key];
        fwrite($fh, "$chrom_part\t$tmp1\t$tmp2\t$taxonCnt\n");
    }
}
