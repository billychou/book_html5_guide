## 选择器
1. 元素选择器
2. 派生选择器
3. id选择器
    #red {
      color: red;
    }
4. 类选择器

5. 属性选择器
    [href] {color: red;}

    [type="password"] {color: red;}

    [href^="http"] {color: red;}

    [href$=".cn"] {color: red;}

    [href*="baidu"] {color: red;}
    
    [class~="def"] {color: red;}// 属性值具有多值时，使用如<p class="abc def"></p>

    [lang|="en"] {color: red;}// 属性中有'-'时使用，如<p lang="en-us"></p>

## 选择器优先级
内联样式 > ID 选择器 > 类选择器 = 属性选择器 = 伪类选择器 > 标签选择器 = 伪元素选择器
