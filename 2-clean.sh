#!/bin/bash
cd ./epub/content
# 遍历当前文件夹中的所有 .html 文件
for file in *.html; do
    echo "清理 $file"
    # 使用 awk 处理文件
    awk '
    /<h1>/,/<\/h1>/ {
        print
    }
    /<div id="content"[^>]*>/,/<\/div>/ {
        print
    }
    ' "$file" > temp_file

    # 将处理后的内容覆盖原文件
    mv temp_file "$file"
done


# 定义头部和尾部内容
header='<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html lang="zh-CN" xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta charset="utf-8">
<link href="../book.css" rel="stylesheet" type="text/css"/>
<title></title>
</head>
<body>'
footer='</body>
</html>'

# 遍历当前文件夹中的所有 .html 文件
for file in *.html; do
    echo "标准化 $file"
    # 创建临时文件
    temp_file=$(mktemp)

    # 写入头部内容到临时文件
    echo "$header" > "$temp_file"

    # 追加原文件内容到临时文件
    cat "$file" >> "$temp_file"

    # 追加尾部内容到临时文件
    echo "$footer" >> "$temp_file"

    # 用临时文件覆盖原文件
    mv "$temp_file" "$file"
    gsed -i 's/　//g' "$file"
    gsed -i 's/<h1> /<h1>/g' "$file"
done

