#!/bin/bash

bookname=$1
author=$2
uuid=$(uuidgen)

# 定义 OPF 文件的头部和尾部
opf_header='<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="bookid">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:title>'$bookname'</dc:title>
    <dc:creator>'$author'</dc:creator>
    <dc:language>zh-CN</dc:language>
    <dc:identifier id="bookid">urn:uuid:'$uuid'</dc:identifier>
  </metadata>
  <manifest>'

cd epub
echo "开始生成 content.opf"
# 创建临时文件
opf_file="content.opf"
temp_manifest=$(mktemp)
temp_spine=$(mktemp)
temp_toc=$(mktemp)

# 写入头部到 OPF 文件
echo "$opf_header" > "$opf_file"
# 遍历当前目录中的所有 .html 文件
for file in ./content/*.html; do
    # 去掉 .html 后缀的文件名作为章节标题
    chapter_title=$(gsed -n 's/.*<h1>\(.*\)<\/h1>.*/\1/p' $file)
    # 生成 manifest 项
    echo "    <item id=\"$chapter_title\" href=\"$file\" media-type=\"application/xhtml+xml\"/>" >> "$temp_manifest"
    # 生成 spine 项
    echo "    <itemref idref=\"$chapter_title\"/>" >> "$temp_spine"
    # 生成 TOC 项
    echo "    <navPoint id=\"$chapter_title\" playOrder=\"$((++order))\">
      <navLabel>
        <text>$chapter_title</text>
      </navLabel>
      <content src=\"$file\"/>
    </navPoint>" >> "$temp_toc"
done

# 将 manifest 和 spine 内容追加到 OPF 文件
cat "$temp_manifest" >> "$opf_file"
echo '    <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>' >> "$opf_file"
echo '    <item id="book.css" href="book.css" media-type="text/css"/>' >> "$opf_file"
echo "  </manifest>" >> "$opf_file"
echo "  <spine toc=\"ncx\">" >> "$opf_file"
cat "$temp_spine" >> "$opf_file"
echo "  </spine>" >> "$opf_file"
echo "</package>" >> "$opf_file"

# 生成 TOC 文件
echo "开始生成 toc.ncx"
toc_file="toc.ncx"
toc_header='<?xml version="1.0" encoding="UTF-8"?>
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
  <head>
    <meta name="dtb:uid" content="urn:uuid:'$uuid'"/>
    <meta name="dtb:depth" content="1"/>
    <meta name="dtb:totalPageCount" content="0"/>
    <meta name="dtb:maxPageNumber" content="0"/>
  </head>
  <docTitle>
    <text>'$bookname'</text>
  </docTitle>
  <navMap>'
toc_footer='  </navMap>
</ncx>'

# 写入头部到 TOC 文件
echo "$toc_header" > "$toc_file"
# 追加 TOC 内容到 TOC 文件
cat "$temp_toc" >> "$toc_file"
# 写入尾部到 TOC 文件
echo "$toc_footer" >> "$toc_file"

# 删除临时文件
rm "$temp_manifest" "$temp_spine" "$temp_toc"

echo "OPF 文件和 TOC 文件已生成：$opf_file 和 $toc_file"

cd epub
zip -r ../"$bookname".epub .
cd ..
kindlegen "$bookname.epub" -dont_append_source