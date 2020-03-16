<?php
/**
 * 生成伪社会信用代码函数
 *
 */

function generateFakeCompanyLicense()
{
    // 社会信用代码构成
    // = 登记管理部门代码1位 + 机构类别代码1位
    // + 登记管理机关行政区划码6位
    // +主体标识码（组织机构代码）9位 + 校验码1位
    // @see https://zh.wikisource.org/zh-hans/GB_32100-2015_%E6%B3%95%E4%BA%BA%E5%92%8C%E5%85%B6%E4%BB%96%E7%BB%84%E7%BB%87%E7%BB%9F%E4%B8%80%E7%A4%BE%E4%BC%9A%E4%BF%A1%E7%94%A8%E4%BB%A3%E7%A0%81%E7%BC%96%E7%A0%81%E8%A7%84%E5%88%99
    $license_code = "Y0"; // 开头使用不使用的字符标识
    $license_code .= "000000";

    $map_chars = range(0, 9);
    $map_chars = array_merge($map_chars, array_map('chr', range(65, 90)));
    $map_chars = array_merge(array_diff($map_chars, ["I", "O", "Z", "S", "V"]));
    $map_chars = array_map('strval', $map_chars);

    $license_code .= strtoupper(random_string(9, join('', $map_chars)));

    $map_weight_factor = [
        0, 1 ,3, 9, 27, 19, 26, 16, 17, 20, 29, 25, 13, 8, 24, 10, 30, 28,
    ];
    $valid = 0;
    for ($i = 0; $i < strlen($license_code); $i++) {
        $el = $license_code{$i};
        $C = array_search($el, $map_chars, true);
        $W = $map_weight_factor[$i + 1];
        $valid += $C * $W;

    }
    $valid = 31 - ($valid % 31);
    $license_code .= isset($map_chars[$valid]) ? $map_chars[$valid] : "0";

    return $license_code;
}

function random_string($length = 6, $chars = '0123456789')
{
    $hash = '';
    $max  = strlen($chars) - 1;
    while ($length--) {
        $hash .= $chars[mt_rand(0, $max)];

    }

    return $hash;
}



// var_dump(generateFakeCompanyLicense());
