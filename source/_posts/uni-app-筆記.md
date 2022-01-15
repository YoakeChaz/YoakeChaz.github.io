---
title: uni_app_筆記
date: 2022-01-14 21:05:17
categories: 程式指令筆記
tags: 
      - 程式筆記 
      - uni-app
      - vue
---
## 綁定圖片例子
```
//這裏表示物件的狀態
export default {     
    data() {
        return {
            img_box:
            [	
                {
                id:"1",
                imgSrc:"http://www.py3study.com/Public/images/article/thumb/random/158.jpg"
                },
                {
                  id:"2",
                  imgSrc:"http://www.py3study.com/Public/images/article/thumb/random/159.jpg",
                },
                {
                  id:"3",
                  imgSrc:"http://www.py3study.com/Public/images/article/thumb/random/160.jpg",
                },
            ]
        }
    }
```
```
//這裏表示template區塊調用物件的語法
<swiper-item v-for="(item,index) in img_box">  <!-- 這邊會從img_box裡面 逐一取出值 並賦予給 item -->
    <image v-bind:src="item.imgSrc">             <!-- 這邊則是逐一接收上一部步驟的值 -->
</swiper-item>
```

<br>
<br>

## 調整圖片屬性
```
<style lang = "scss">
		.news{
			swiper{
				width:  750rpx;
				height: 380rpx;
				image{
					height: 100%;
					width:  100%;
				}
			}
		}
</style>
```

<br>
<br>

## 按鈕事件綁定
```
<template>
    <button v-bind:type="buttontype"         //調整按鈕狀態  :type因為是v-bind:type  要再取出"buttontype"物件裡的值
            @click="changetextvalue()">      //綁定事件
    </button>
</template>
```
```
<script>  
        export default {  
            data() {  
                return { 
                    textvalue:"123"   //這裏設定物件
                };  
            },  
            
            onLoad() {
            },  
            
            methods: {  
                changetextvalue() {  
                    this.textvalue="789"//这里修改textvalue的值，页面自动刷新为789  
                }  
            }  
        }  
    </script>
```

<br>
<br>

## 通用物件的可操作性
```
<template>
    <view>
      <view>{{ number + 1 }}</view>
      <view>{{ ok ? 'YES' : 'NO' }}</view>    //判斷ok裡的變量 是true的話 輸出YES 否的話輸出NO
      <view>{{ message.split('e') }}</view>   //用e切割 物件message
    </view>
</template>
```

<br>
<br>

## v-for 常數版 結合 v-bind:class 以及單引號的應用
這裡因為單引號跟雙引號不能練用 不然會無法分辨引號哪裡
單引號也不會被解析為物件 而會被解析為純文字 -->
```
<template>
   <view>
      <view v-for="(item,index) in 10"> <!-- 這邊表示做10次 -->
      <view v-bind:class=" 'list-' + index%2">{{index%2}}</view> <!-- v-bind:class選擇器的連用 -->
   </view>
</template>
```

```
<script>
  export default {
    data() {
      return { }
    }
  }
</script>
```
```
<style>
  .list-0{
    background-color: #aaaaff;
  }
  .list-1{
    background-color: #ffaa7f;
  }
</style>
```

<br>
<br>

## v-bind:class 結合物件邏輯開關

```
<template>
	<view>
		<!-- 這裡是智慧綁定結合邏輯物件的調用 單引號的意義是包住字串 雙引號的意義是定義為字符串 -->
		<view class="static" v-bind:class="{'active': isActive}">111</view>
		<!-- 同一標籤內 可以使用多class 再配合邏輯的開關 未來可以更好修改 -->
		<view class="static" v-bind:class="{'active': isActive, 'text-danger': hasError }">222</view>
		<!-- 物件內可以自由的增加字符串 來達到實際的效果 -->
		<view v-bind:style="{ color: activeColor, fontSize: fontSize + 'px' }">333</view>
	</view>
</template>
```
```
<script>
	export default {
		data() {
			return {
				isActive: true, //這邊決定啟用class
				hasError: true,
				activeColor:"green",
				fontSize:50     //雖然這邊是50 但是可以在調用端增加px之類 來達到多樣的效果
			}
		}
	}
</script>
```
```
<style>
    .static{
        color: #2C405A;
    }
    .active{
        background-color: #007AFF;
    }
    .text-danger{
        color: #DD524D;
    }
</style>
```

<br>
<br>

## v-bind 結合中掛號大掛號的用法
```
<template>
    <view>
        <!-- 大括號內表示物件所以要用：定義物件屬性  中括號內表示數組則用,分開即可 -->
		<view class="static" v-bind:class="{'active': isActive}">111</view>
		<view class="static" v-bind:class="['active', isActive]">111</view>
		<!-- 物件數值取出後再轉成數組 其實一樣意思-->
		<view class="static" v-bind:class="[{'active': isActive}]">111</view>
		<!-- isActive是真實的嗎 如果是activeClass為空 如果不是 activeClass為errorClass   這裡的：試試三元表達是獨有的規定-->
        <view class="static" v-bind:class="[isActive ? activeClass :    '', errorClass]">222</view>
		<!-- {}[]的連用 表示物件用大掛號 物件內的值拿出來後在宣告為數組來取其特性 -->
        <view class="static" v-bind:class="[{ active: isActive }, errorClass]">333</view>
		<!-- 物件數值取出後 加字 再轉成數組 -->
        <view v-bind:style="[{ color: activeColor, fontSize: fontSize + 'px' }]">444</view>
    </view>
</template>
```
```
<script>
    export default {
        data() {
            return {
                isActive: true,
                activeClass: 'active',
                errorClass: 'text-danger',
                activeColor:"green",
                fontSize:50
            }
        }
    }
</script>
```
```
<style>
    .static{
        font-size:30rpx;
    }
    .active{
        background-color: #007AFF;
    }
    .text-danger{
        font-size:60rpx;
        color:#DD524D;
    }
</style>
```

<br>
<br>

## 標籤的v-show屬性
```
<template>
	<view>
		<view v-show="ok">Hello!</view>
        <view v-show= true >Heello!</view>
	</view>
</template>
```
```
<script>
	export default {
		data() {
			return {
				ok : true
			}
		}
	}
</script>
```

<br>
<br>

## 單純的if/else判斷式

template裡面是內容的部分,所以如果要用邏輯 必須寫在標籤裡
標籤裡的東西 會再去調用物件裡的邏輯
```
 <template>
	<view>
		<view v-if="seen">現在你看到我了</view>
		<view v-else>你看不到我了</view>
	</view>
</template>
```
```
<script>
	export default {
		data() {
			return {
				seen: true
			}
		}
	}
</script>
```

<br>
<br>

## 單純的else if 判斷式
三個等號為嚴格等於 必須完全一樣。
兩個等號為普通相等 true == 1 這樣也是真實
```
<template>
	<view>
		<view v-if     ="type === 'A'"> A </view>
		<view v-else-if="type === 'B'"> B </view>
		<view v-else-if="type === 'C'"> C </view>
		<view v-else>         Not A/B/C   </view>
	</view>
</template>
```
```
<script>
	export default {
		data() {
			return {
				type:'B'
			}
		}
	}
</script>
```

<br>
<br>

## v-for的語法介紹(數組篇)-----for in 數組 可以執行數組數量的次數
item 與 index為必要的變數 分別表示 物件 與 索引(順序是寫死的)
<view v-for="(item,index)in items">裡的 item與index 會暫時轉化為物件
item.message 可以指到item數組裡面的message名稱的物件
```
<template>
    <view>
        <view v-for="(item, index) in items"> 
            {{ index }} - {{ item.message }}  
        </view>
    </view>
</template>
```
創造一個數組item 裡面有名稱為message的2個物件
名稱之所以一樣 是因為方便for回圈call
```
data() {            
    return {
        items: [
            { message: 'Foo' },
            { message: 'Bar' }
        ]
    }
}
```

<br>
<br>

## v-for的語法介紹(物件篇)-----for in 物件 可以執行物件屬性數量的個數
```
<template>
	<view>
		<view v-for="(value, name, index) in object"> <!-- value, name, index 這個順序是寫死的 -->
			 {{ index }} . {{ name }} : {{ value }} 
		</view>
	</view>
</template>
```
```
<script>
	export default {
		data() {
			return {
				object: { //創造一個物件 具有4個屬性
					title:       'How to do lists in Vue!',
					author:      'Jane Doe',
					publishedAt: '2020-04-10',
					test:        'test'
				}
			}
		}
	}
</script>
```
