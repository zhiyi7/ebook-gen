# 电子书生成脚本

当前自用，可自行修改成自己想要的

## 前提条件
可以命令行运行`aria2c`和`zip`

## 使用方式
1. 先获得章节url地址，存到urls.txt
2. 然后依次运行
```shell
./0-download.sh
./1-iconv.sh #可选，如果获得的文件是gbk
./2-clean.sh #注意修改里面的正则，确保获取到正确的文章内容
./3-mkepub.sh 书名 作者名
```

最后一步如果没有kindlegen也没关系，生成的epub可以随便转成其他格式。