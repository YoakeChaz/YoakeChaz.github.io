---
title: hexo筆記
date: 2022-01-03 20:12:37
categories: hexo
tags: 
    - hexo筆記
---
## 基本指令
```
hexo g  //重新編譯
hexo s  //掛載    
hexo d  //推至github
```
<br>

## 配置文件
由於程式碼區塊的行號，在預覽的時候會有很多數字不方便預覽
打開hexo下的 _config.yml設定文件
```
highlight: 
  enable: true
  line_number: false      //這裡的行號改成false
  auto_detect: false
```

