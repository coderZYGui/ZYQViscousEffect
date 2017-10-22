# ZYQViscousEffect
### 效果如下<br>
    ![](https://github.com/coderZYGui/ZYQViscousEffect/blob/master/ZYQqViscousEffect/img/ViscousEffect.gif)<br>
    
    
### 实现思路:
  整体思路:<br>
      手指移动,按钮跟着移动.按钮跟着手指移动,移动时底部有个圆(称为小圆),根据上面的大圆按钮拖动的距离,小圆的半径减小,<br>
        移动时中间是一块不规则的填充区域.<br>
      手指移动超出一定的范围,填充效果消失,当手指松开时,判断当前两圆的距离<br>
        如果小于一个最大距离,就让大圆回到原来的位置,下次移动,具有同样的填充效果<br>
        如果大于一个最大距离,当手指松开时,播放一个动画,动画完成时,删除大圆.<br>

  计算不规则区域:<br>
    需要计算6个点,可根据下图来一一计算<br>
    ![](https://github.com/coderZYGui/ZYQViscousEffect/blob/master/ZYQqViscousEffect/img/vscosityCalc.png)
