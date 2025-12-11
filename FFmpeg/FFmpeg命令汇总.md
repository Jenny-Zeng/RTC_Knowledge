# 查看 FFmpeg 支持的容器
ffmpeg -formats
# 查看 FFmpeg 已安装的编码器
ffmpeg -encoders
# ffmpeg 推流命令
1. h264/h265推流，唯一的区别是视频源

    ```ffmpeg -re -stream_loop -1 -i /Users/Downloads/bbb_30fps_gop_60_3mbps.mp4 -vcodec copy -acodec copy -f flv "rtmp://h../test02"```

    ```ffmpeg -re -i "<input>" -c copy -f flv "<output>"```

2. h265推流

    ```ffmpeg -re -stream_loop -1 -i /Users/zengzhaoxia/Downloads/qiniu-2023-720p-fps-1.mp4 -c:v libx265 -preset fast -b:v 2M -c:a aac -b:a 128k -f flv "rtmp://test61.com:1935/ztest/test0109?domain=test61.com"```

   ```ffmpeg -re -i /Users/reikyZ/Desktop/oceans.mp4 -vcodec libx265 -acodec aac output.mp4```
3. 音视频录音录屏推流
ffmpeg -f avfoundation -i "1:0" -vcodec libx264 -preset ultrafast -acodec aac -ar 44100 -ac 1 -f flv "推流地址"
4. 将直播媒体保存至本地文件
ffmpeg -i rtmp://server/live/streamName -c copy dump.flv
5. 将一个高清流，复制为几个不同视频清晰度的流重新发布，其中音频不变
ffmpeg -re -i rtmp://server/live/high_FMLE_stream -acodec copy -vcodec x264lib -s 640×360 -b 500k -vpre medium -vpre baseline rtmp://server/live/baseline_500k -acodec copy -vcodec x264lib -s 480×272 -b 300k -vpre medium -vpre baseline rtmp://server/live/baseline_300k -acodec copy -vcodec x264lib -s 320×200 -b 150k -vpre medium -vpre baseline rtmp://server/live/baseline_150k -acodec libfaac -vn -ab 48k rtmp://server/live/audio_only_AAC_48k

# 视频解复用
    ffmpeg –i test.mp4 –vcodec copy –an –f m4v test.264 ffmpeg –i test.avi –vcodec copy –an –f m4v test.264

# 将视频切片输出
ffmpeg -i http://xxx.com/test.mp4 -c:v libx264 -c:a aac -strict -2 -f hls output.m3u8

# ffmpeg 抽取音视频流
1. ffmpeg抽取音频流

    ```ffmpeg -i demo.mp4 -vn -y -acodec copy demo.aac```
或者
    ```ffmpeg -i input_file -acodec copy -vn output_file_audio```

2. ffmpeg抽取视频流 

    ```ffmpeg -i input_file -vcodec copy -an output_file_video ```     

# 视频转码
1. 转码为码流原始文件

    ```ffmpeg –i test.mp4 –vcodec h264 –s 352*278 –an –f m4v test.264 ```  
2. 转码为码流原始文
    ```ffmpeg –i test.mp4 –vcodec h264 –bf 0 –g 25 –s 352*278 –an –f m4v test.264  ```
3. 转码为封装文件 //-bf B帧数目控制，-g 关键帧间隔控制，-s 分辨率控制

    ```ffmpeg –i test.avi -vcodec mpeg4 –vtag xvid –qsame test_xvid.avi ```

4. 将视频旋转 90 度后输出新视频文件
ffmpeg -i discovery.mp4 -c copy -metadata:s:v:0 rotate=90 -f mp4 output.mp4
5. 将.avi转成.flv
ffmpeg -i video_origine.avi -ab 56 -ar 44100 -b 200 -r 15 -s 320x240 -f flv video_finale.flv
6. 将.avi转成dv
ffmpeg -i video_origine.avi -s pal -r pal -aspect 4:3 -ar 48000 -ac 2 video_finale.dv
或者：
ffmpeg -i video_origine.avi -target pal-dv video_finale.dv
7. 将.avi压缩成divx
ffmpeg -i video_origine.avi -s 320x240 -vcodec msmpeg4v2 video_finale.avi

# 视频封装
    ffmpeg –i video_file –i audio_file –vcodec copy –acodec copy output_file
或者
ffmpeg -i xxx.mp3 -i xxx.mp3 -filter_complex amix=inputs=2:duration=first:dropout_transition=2 -f mp3 a.mp3
# 视频剪切
1. 提取图片

    ```ffmpeg –i test.avi –r 1 –f image2 image-%3d.jpeg```
2. 剪切视频，-r 提取图像的频率，-ss 开始时间，-t 持续时间

    ```ffmpeg -ss 0:1:30 -t 0:0:20 -i input.avi -vcodec copy -acodec copy output.avi``` 

## 录制视频 
    ffmpeg –i rtsp://192.168.3.205:5555/test –vcodec copy out.avi`
    ffmpeg -i rtsp://hostname/test -vcoder copy out.avi

# YUV序列播放
    ffplay -f rawvideo -video_size 1920x1080 input.yuv
# YUV序列转AVI
    ffmpeg –s w*h –pix_fmt yuv420p –i input.yuv –vcodec mpeg4 output.avi 


# 录制屏幕
1. 录制
ffmpeg -f avfoundation -i "1" -vcodec libx264 -preset ultrafast -acodec libfaac -f flv screen.flv
2. 只录制系统声音：
ffmpeg -f dshow -i audio="virtual-audio-capturer" out.mp3
3. 同时录制屏幕+系统声音：
ffmpeg -f dshow -i audio="virtual-audio-capturer":video="screen-capture-recorder" -pix_fmt yuv420p out.mp4

4. 同时录制屏幕+系统声音+麦克风（参数较长，为便于阅读增加了换行）：
ffmpeg -f dshow -i audio="麦克风 (Realtek High Definition Audio)"
-f dshow -i audio="virtual-audio-capturer"
-filter_complex amix=inputs=2:duration=first:dropout_transition=0
-f dshow -i video="screen-capture-recorder" -pix_fmt yuv420p
out.mp4



# 添加 GIF 水印
1. 
ffmpeg -y -i oceans.mp4 -ignore_loop 0 -i test0.gif -filter_complex '[0:0]scale=iw:ih[firstInput]; [1:0]scale=iw/4:ih/4[secondInput]; [firstInput][secondInput]overlay=0:0:1' movieScaleGif.mp4
2. 视频添加水印，水印局中
ffmpeg -i out.mp4 -i sxyx2008@163.com.gif -filter_complex overlay="(main_w/2)-(overlay_w/2):(main_h/2)-(overlay_h)/2" output.mp4
参数解释
-i out.mp4(视频源)
-i xxoo.gif (水印图片)
overlay 水印的位置
output.mp4 输出文件




x264 to fragmented mp4

ffmpeg -re -i d:\test.264 -g 52 -acodec libvo_aacenc -ab 64k -vcodec libx264 -vb 448k -f mp4 -movflags frag_keyframe+empty_moov d:\output.mp4

# 将图片序列合成视频
ffmpeg -f image2 -i image%d.jpg video.mpg

# 截图：
1. 从指定时间开始，连续对1秒钟的视频进行截图
ffmpeg -y -i input.mp4 -ss 00:01:24 -t 00:00:01 output_%3d.jpg
2. 截取一张352x240尺寸大小，格式为jpg的图片
ffmpeg -i input_file -y -f image2 -t 0.001 -s 352x240 output.jpg
3. 把视频的前30帧转换成一个Animated Gif
ffmpeg -i input_file -vframes 30 -y -f gif output.gif
4. 在视频的第8.01秒出截取230x240的缩略图
ffmpeg -i input_file -y -f mjpeg -ss 8 -t 0.001 -s 320x240 output.jpg
5. 每隔一秒截一张图
ffmpeg -i out.mp4 -f image2 -vf fps=fps=1 out%d.png
6. 每隔20秒截一张图
ffmpeg -i out.mp4 -f image2 -vf fps=fps=1/20 out%d.png
7. 从视频中生成GIF图片
ffmpeg -i out.mp4 -t 10 -pix_fmt rgb24 out.gif
8. 转换视频为图片（每帧一张图）
ffmpeg -i out.mp4 out%4d.png

# 为音频添加封面
ffmpeg -loop 1 -i cover.jpg -i input.mp3 -c:v libx264 -c:a aac -b:a 192k -shortest output.mp4
视频翻转和旋转
翻转
水平翻转语法: -vf hflip
ffplay -i out.mp4 -vf hflip
垂直翻转语法：-vf vflip
ffplay -i out.mp4 -vf vflip
旋转
语法：transpose={0,1,2,3}

0:逆时针旋转90°然后垂直翻转

1:顺时针旋转90°

2:逆时针旋转90°

3:顺时针旋转90°然后水平翻转

将视频顺时针旋转90度
ffplay -i out.mp4 -vf transpose=1
将视频水平翻转(左右翻转)
ffplay -i out.mp4 -vf hflip
顺时针旋转90度并水平翻转
ffplay -i out.mp4 -vf transpose=1,hflip




# 上述参数说明：
    -i 设定输入流
    -f 设定输出格式
    -ss 开始时间
    -c：指定编码器

## 视频参数：
    -c copy：直接复制，不经过重新编码（这样比较快）
    -c:v：指定视频编码器
    -c:a：指定音频编码器
    -b 设定视频流量，默认为200Kbit/s
    -r 设定帧速率，默认为25
    -s 设定画面的宽与高
    -aspect 设定画面的比例
    -vn 不处理视频
    -an：去除音频流
    -vcodec 设定视频编解码器，未设定时则使用与输入流相同的编解码器
    音频参数：
    -ar 设定采样率
    -ac 设定声音的Channel数
    -acodec 设定声音编解码器，未设定时则使用与输入流相同的编解码器
    -an 不处理音频
    -preset：指定输出的视频质量，会影响文件的生成速度，有以下几个可用的值 ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow。

