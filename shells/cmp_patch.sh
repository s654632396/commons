#!/bin/env bash
#set -x
# ##################################################################################
# Description:
#   分拣操作： 差分文件补丁，比对覆盖/比对编辑
#
# Version:  v0.1.1
#
# Author: dongchaofeng
# Usage:
#   > 先将差分文件拷贝到当前目录，根据具体情况命名初始变量，然后执行
#   > bash cmp_patch.sh {补丁文件目录} {目标文件目录}
#
# Usage cases:
#   > ./cmp_patch.sh  /tmp/patch_dirs/some_patch /data/www/project
#   > ./cmp_patch.sh --target-path=/data/www some_patch project
#   > ./cmp_patch.sh -P $(pwd) -T "/data/www" some_patch project
#   > ./cmp_patch.sh --patch-path "/tmp/patch_dirs" --target-path "/data/www" some_patch project
#
# Options:
#  -P --patch-path         [option] 补丁顶层目录 默认值： 当前脚本目录
#  -T --target-path        [option] 目标顶层目录  默认值： /data/www
#
# Todo List:
#   - [options] -h | --help         输出命令使用帮助
#   - [options] -b | --backup       备份目标目录文件
#   - [options] -t | --diff-tool    比对文件的工具, 默认：icdiff, 其他可选 diff
#   - [options] -e | --diff-editor  比对编辑文件的编辑器，默认：vimdiff
# ##############################################################################

## predefined defines variables
SHELL_FOLDER=$(
  cd "$(dirname "$0")"
  pwd
)
DefaultPatchPrefixPath=${SHELL_FOLDER}
DefaultTargetPrefixPath="/data/www"

TEMPLATE=$(getopt -o P:T: --longoptions patch-path:,target-path: -n 'cmp_patch.sh' -- "$@")
if [ $? != 0 ]; then
  echo "Terminating..." >&2
  exit 1
fi

eval set -- "$TEMPLATE"
while true; do
  case "$1" in
  -P | --patch-path)
    PATCH_PATH_PREFIX=$2
    shift 2
    ;;
  -T | --target-path)
    TARGET_PATH_PREFIX=$2
    shift 2
    ;;
  --)
    shift
    break
    ;;
  *)
    echo "Internal error!"
    exit 1
    ;;
  esac
done

# 获取剩余参数： {patch} {target}
declare -i idx=1
for arg; do
  case "${idx}" in
  1)

    PatchPathName=$arg
    ;;
  2)

    TargetPathName=$arg
    ;;
  esac
  idx=${idx}+1
done
if [[ '' = $PatchPathName ]]; then
  echo "Must have arguments patch_path."
  exit 1
fi
if [[ '' = $TargetPathName ]]; then
  echo "Must have arguments target_path."
  exit 1
fi

if [[ '' = ${PATCH_PATH_PREFIX} && ${PatchPathName} == /* ]]; then
  PatchPath=${PatchPathName}
else
  # PATCH_PATH_PREFIX 缺省值
  if [[ '' = ${PATCH_PATH_PREFIX} ]];then
    PATCH_PATH_PREFIX=${DefaultPatchPrefixPath}
  fi
  PatchPath="${PATCH_PATH_PREFIX}/${PatchPathName}"
fi

if [[ '' = ${TARGET_PATH_PREFIX} && ${TargetPathName} == /* ]]; then
  TargetPath=${TargetPathName}
else
    # TARGET_PATH_PREFIX 缺省值
    if [[ '' = ${TARGET_PATH_PREFIX} ]];then
      TARGET_PATH_PREFIX=${DefaultTargetPrefixPath}
    fi
    TargetPath="${TARGET_PATH_PREFIX}/${TargetPathName}"
fi

# 检验绝对路径是否存在
checkAbsPathExists() {
    if [[ ! -d $1 ]]; then
        echo -e "\033[31m路径($1)不是一个正确的目录\033[0m"
        exit 1
    fi
}



# choose better diff tools
BinDiffTool="diff"
which icdiff
if [[ $? -eq 0 ]]; then
  BinDiffTool="icdiff"
fi

## env vars output
cat <<EOF
+++++++++++++++++++++++++ENV Vars++++++++++++++++++++++
补丁文件目录前缀  ==> ${PATCH_PATH_PREFIX}
补丁文件目录      ==> ${PatchPath}
目标源文件目录前缀 ==> ${TARGET_PATH_PREFIX}
目标源文件目录     ==> ${TargetPath}
+++++++++++++++++++++++++++++++++++++++++++++++++++++++
EOF

# checking input
checkAbsPathExists ${PatchPath}
checkAbsPathExists ${TargetPath}

sleep 1


listFiles() {
  local dirs=$(ls $1)
  for path in ${dirs}; do
    if [[ -f ${path} ]]; then
      # 是文件
      findTargetFile ${path}
    else
      # recursive call
      listFiles "$1/${path}"
    fi
  done
}

# 查找目标目录对应的文件
findTargetFile() {
  local patch_file=$1
  local relate_patch_file=${patch_file#${PATCH_PATH_PREFIX}/*}
  local patch_keyword=${relate_patch_file%%/*}
  local relate_path=${relate_patch_file#*/}
  local tgPathPrefix="/tmp/"

  tgPathPrefix="${TargetPath}/"
  checkAbsPathExists ${tgPathPrefix}

  # start comparing files
  local source_file="${tgPathPrefix}${relate_path}"
  compareFiles $patch_file $source_file
}

# 文件比对
compareFiles() {
  local srcFile=$1
  local trgFile=$2

  if [[ ! -f ${trgFile} ]]; then
    createTrgFile $trgFile
  fi

  diffLineNums=$(${BinDiffTool} ${trgFile} ${srcFile} | wc -l)
  if [[ $diffLineNums -eq 0 ]]; then
    echo "文件(${trgFile})完全一致，skipped."
    return 0
  fi
  cat <<EOF
>>>>>>>>>>>>>>>>>>>>>>>>>>
${BinDiffTool}  ${trgFile}  ${srcFile}
--- ${trgFile}
+++ ${srcFile}
EOF
  ## 来看看有什么不同
  ${BinDiffTool} ${trgFile} ${srcFile} | less
  if [[ $diffLineNums -gt 0 ]]; then
    overwriteFile ${srcFile} ${trgFile}
  fi
}

createTrgFile() {
  # mkdir
  local file=$1
  local directory=${file%/*}
  if [[ ! -d ${directory} ]]; then
    echo "create directory="$directory
    mkdir ${directory}
  fi
  # touch files
  touch ${file}
}

overwriteFile() {
  local srcFile=$1
  local trgFile=$2
  while :; do
    read -r -p '请确认覆盖/编辑文件($trgFile) (y[es]/n[o]/e[dit]/v[iew]): ' input
    case ${input} in
    [nN][oO] | [nN])
      ############      【直接跳过】        ##############
      echo -e "\033[32m====> skipped overwrite: ${trgFile}\033[0m"
      break
      ;;
    [yY][eE][sS] | [yY])
      ############      【覆盖操作】          ###########
      echo "\033[31m====> replace ${srcFile} ---> ${trgFile}\033[0m"
      cp ${srcFile} ${trgFile}
      break
      ;;
    [eE][dD][iI][tT] | [eE])
      ###########  【vimdiff工具编辑操作】  ##############
      vimdiff $trgFile $srcFile
      break
      ;;
    [vV][iI][eE][vV] | [vV])
      ###########  【重新查看比较信息】  ###############
      ${BinDiffTool} ${trgFile} ${srcFile} | less
      ;;
    *)
      echo "请确认操作..."
      ;;
    esac
  done
}

listFiles ${PatchPath}
