<?php

/**
 * intervals from EnsemblPlants genes
 * expand 1000, gap 100
 * convert into chromosome part reference
 */

$testing = false;

$gap = 100; //join together if less than this distance
$expand = 1000;  //expand to include promotor

$file = "/data/wheat/Triticum_aestivum.IWGSC.43.gff3";
$fh = fopen($file, "r") or die("Error: $file\n");
$count = 0;
echo "reading in $file\n";
while (!feof($fh)) {
    $tmp = fgets($fh);
    if (preg_match("/##sequence-region\s+(\w+)\s+\d+\s+(\d+)/", $tmp, $match)) {
        $chr = $match[1];
        $stop = $match[2];
        $chr_limit[$chr] = $stop;
        //echo "$chr $stop\n";
        continue;
    } elseif (preg_match("/^#/", $tmp)) {
        continue;
    }
    $line = explode("\t", $tmp);
    if (preg_match("/ID=gene:([^\;]+)/", $line[8], $match)) {
        $name = $match[1];
    } else {
        $name = "";
    }
    $chrom = "chr" . $line[0];
    $type = $line[2];
    if (preg_match("/gene/", $type)) {
        $start = $line[3] - $expand;
        $stop = $line[4] + $expand;
        if ($start < 1) {
            $start = 1;
            //echo "$line[0] $start\n";
        }
        if ($stop > $chr_limit[$line[0]]) {
            $stop = $chr_limit[$line[0]];
            //echo "$line[0] $stop\n";
        }
        $range[$chrom][] = array($start, $stop);
        $range_name[$chrom][] = $name;
        $count++;
        if (($count % 10000) == 0) {
            echo "$count\n";
        }
        if (($testing) && ($count > 100)) {
            break;
        }
    }
}
fclose($fh);
echo "$count from $file\n";

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
        echo "$chrom_part $chrom $stop\n";
    }
}
fclose($fh);

if ($testing) {
    $file = "intervals_expand1000_gap100_test.bed";
} else {
    $file = "intervals_expand1000_gap100.bed";
}
$fh = fopen($file, "w") or die("Error $file\n");
//sort then merge each chromosome
$min = 25;  //minimum size of reference range
$count_total = 0;
$count_good = 0;
$bases_total = 0;
echo "writing out $file\n";
foreach ($range as $chrom => $val) {
    $data = $range[$chrom];
    $name = $range_name[$chrom];
    $count1 = count($data);
    usort($data, function($a, $b) {
            return $a[0] - $b[0];
        }
    );
    
    $n = 0;
    $len = count($data);
    for ($i = 1; $i < $len; ++$i) {
        if ($data[$i][0] > $data[$n][1] + $gap + 1) {  //no overlap
            $n = $i;
        } elseif ($data[$n][1] < $data[$i][1] + $gap) {
            $tmp1n = $name[$n];
            $tmp2n = $name[$i];
            $tmp1 = $data[$n][1];
            $tmp2 = $data[$i][1];
            $tmp3 = $tmp2 - $tmp1;
            //echo "$tmp1n $tmp2n $tmp1 $tmp2 $tmp3\n";
            $data[$n][1] = $data[$i][1];
            unset($data[$i]);
        } else {
            unset($data[$i]);
        }
    }
    $count2 = count($data);

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
    //echo "using $chrom_tran for $chrom\n";
    
    foreach ($data as $i => $val) {
        $tmpn = $name[$i];
        $tmp1 = $data[$i][0];
        $tmp2 = $data[$i][1];
        $dist = $tmp2 - $tmp1;
        $bases_total += $dist;
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

        if (($tmp2 - $tmp1) > $min) {
            $count_good++;
            fwrite($fh, "$chrom_part\t$tmp1\t$tmp2\t$tmpn\n");
        } else {
            echo "Error: $tmp2 $tmp1\n";
        }
    }
    echo "$chrom origninal_count $count1 merge_count $count2 $bases_total\n";
}
echo "good $count_good\n";
