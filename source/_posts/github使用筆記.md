---
title: github使用筆記
date: 2022-01-03 11:19:55
categories: 程式指令筆記
tags: 
      - 程式筆記 
      - github
---
## git + github 初始化到push流程  

``` 
CD 想要版本控制的資料夾路徑  
git init        //開始對這個資料夾版本控制  
git add .       //將所有變化量選擇起來  
git commit -m "新版本的名字"      //將上一部選擇的變化量做成一個紀錄點  
```

下一步要將資料同步到github

```
git branch -M main //更改當前分支名稱
git remote add origin https://github.com/YoakeChaz/DEMO.git //指定遠端數據庫位置
git push -u origin main //將main分支 推至github
```
//這裡會出現輸入帳號密碼的提示
//帳號輸入github的信箱
//密碼要留意 由於github在2021年更改設定 無法直接使用密碼登入所以要執行以下步驟
1.點github頭像 --> settings --> Developer settings --> Personal access tokens
2.點Generatenew token --> 描述/時間隨意 權限全勾
3.複製生成的金鑰名稱 必須用這行取代git push 時候的密碼


