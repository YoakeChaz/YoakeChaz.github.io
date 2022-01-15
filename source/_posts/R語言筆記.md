---
title: R語言筆記
date: 2022-01-02 21:14:12
categories: 程式指令筆記
tags: 
      - 程式筆記 
      - R語言
---
# 通用
<br>
## 過濾出需要的資料
```
  D2019_check = D2019[(D2019$rent_time==("rent_time")),]
```
## table 跟 c() 連用 同時table 多個資料
```
  table(c(x$rent_station, x$return_station))
```
## 文字貼上的區別
```
  c("a","b") #這很好用
```
## 切割文字(效率偏差)
```
  strsplit(bike_data$starttime[cut_num],split = '/')
```
## 尋找資料
```
  which(A==3)
```
## 寫入資料
```  
  write.csv(T2016_06,file="/Users/chenxinhong/Desktop/youbike_data/2016/xxx.csv",row.names = FALSE)
``` 
 <br>
 
## 關聯性分析
```  
cor(D3[,c("Gender0","Education0","Income0","Age","Card0","Credit_Limit","Annual_trans","Annual_trans_c")])
``` 
 <br>
 <br>
 <br>
 
# 圖片處理
<br>
## 疊圖
```
  par(new=TRUE)
```
## 多重顯示plot
```
  par(mfcol=c(1,2))
``` 
<br>
<br>
<br>

# 矩陣
<br>
## 依照位置橫向擺放矩陣
```
  data2<-cbind(z_down[2:4],c2_del)
```
## 依照位置縱向擺放矩陣
```
  data2<-rbind(z_up[1:4],data2)
```
## 矩陣轉畫圖格式
```
  graph.adjacency(xx) 
```
## 畫圖格式轉矩陣
```
  as_adjacency_matrix(xx)
```
<br>
<br>
<br>

# 時間處理
<br>
## 計算天數
```
  x<-as.Date("1970-01-01") 
  unclass(x) #設定第０天
  unclass(as.Date("1970-02-01")) #19700201代表第31天
```
## 切割時間
```
  x <- as.POSIXct("2016-06-25 21:00:00")
  year(x);month(x);day(x);hour(x);minute(x);second(x)
```
## 新增矩陣的資料
```
  move1_matric<-cbind(c(d2[,2]),d2) #新增一行 砍一行
```
## 刪除矩陣的資料
```
  move1_matric = move1_matric[,-3]
```
<br>
<br>
<br>

### 更新資訊
2021/01/07 18:47


