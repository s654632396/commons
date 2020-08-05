<?php

// 表格对齐输出
function alignOutput($data)
{
    $colNum = count(current($data));

    $colMaxStrLen = array_pad([], $colNum, 0);
    foreach ($data as $datum) {
        foreach ($datum as $i => $item) {
            $colMaxStrLen[$i] = max($colMaxStrLen[$i], strlen($item));
        }
    }

    foreach ($data as $datum) {
        foreach ($datum as $i => $item) {
            echo $item;
            if ($colMaxStrLen[$i] == strlen($item)) {
                $rpt = 1;
            } else {
                if ((floor($colMaxStrLen[$i] / 8) * 8 - strlen($item)) % 8 == 0) {
                    $rpt = floor((floor($colMaxStrLen[$i] / 8) * 8 - strlen($item)) / 8) + 1;
                } else {
                    $rpt = floor((floor($colMaxStrLen[$i] / 8) * 8 - strlen($item)) / 8) + 2;
                }
            }
            echo str_repeat("\t", $rpt);
        }
        echo PHP_EOL;
    }
}
