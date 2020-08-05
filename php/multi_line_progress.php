<?php
/**
*  ______        __             ____             __                        
* /_  __/__ ____/ /  ___  ___  / _(_)__ ___  ___/ /                        
*  / / / -_) __/ _ \/ _ \/ _ \/ _/ / -_) _ \/ _  /                         
* /_/  \__/\__/_//_/_//_/\___/_//_/\__/_//_/\_,_/                          
*    ___  ___  ___ _______ ______________________                          
*   |_  ||_  |( _ <  / __// __<  <  / __<  / ___ \___ ____ _ _______  __ _ 
*  / __// __// _  / /__ \/__ \/ // /__ \/ / / _ `/ _ `/ _ `// __/ _ \/  ' \
* /____/____/\___/_/____/____/_//_/____/_/\ \_,_/\_, /\_, (_)__/\___/_/_/_/
*                                          \___/  /_/  /_/                 
* 作者：Technofiend <2281551151@qq.com>
* 多进度条输出
*/
ini_set('max_execution_time', '0');

$percentStatus = [];

// 组合成进度条
function buildLine($percent) {
    $repeatTimes = 100;
    if ($percent > 0) {
        $hasColor = str_repeat('■', $percent);
    } else {
        $hasColor = '';
    }

    if ($repeatTimes - $percent > 0) {
        $noColor  = str_repeat(' ', $repeatTimes - $percent);
    } else {
        $noColor  = '';
    }

    $buffer      = sprintf("[{$hasColor}{$noColor}]");
    if ($percent !== 100) {
        $percentString = sprintf("[   %-6s]", $percent . '%');
    } else {
        $percentString = sprintf("[    %-5s]", 'OK');;
    }

    return $percentString . $buffer . "\r";
}

// 输出进度条
function outputProgress($clear = false)
{
    global $percentStatus;

    if ($clear) {
        $number = count($percentStatus);
        for ($i=0; $i < $number; $i++) { 
            system("tput cuu1");
            system("tput el");
        }
    }

    foreach ($percentStatus as $value) {
        echo buildLine($value) . "\n";
    }
}

// 更新进度条值
function updateProgressValue($k, $value) {
    $percentStatus[$k] = $value;
    if ($percentStatus[$k] >= 100) {
        $percentStatus[$k] = 100;
        outputProgress(true);
        return;
    }

    outputProgress(true);
    usleep(10000);
}


$percentStatus[0] = 0;
$percentStatus[1] = 0;
$percentStatus[2] = 0;
$percentStatus[3] = 0;
$percentStatus[4] = 0;
$percentStatus[5] = 0;
$percentStatus[6] = 0;
$percentStatus[7] = 0;
$percentStatus[8] = 0;
outputProgress();
while(1) {
    $percentStatus[0] = rand(0, 100);
    $percentStatus[1] = rand(0, 100);
    $percentStatus[2] = rand(0, 100);
    $percentStatus[3] = rand(0, 100);
    $percentStatus[4] = rand(0, 100);
    $percentStatus[5] = rand(0, 100);
    $percentStatus[6] = rand(0, 100);
    $percentStatus[7] = rand(0, 100);
    $percentStatus[8] = rand(0, 100);
    outputProgress(true);
    usleep(500000);
}
