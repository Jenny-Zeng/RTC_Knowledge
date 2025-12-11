    ########################################## 方式一 ####################################
    # 无限循环地创建名为 test01 到 test100 的RTMP流，每个流只推送1秒视频，然后切换到下一个流名继续推送。
    #!/bin/bash
    
    count=1
    while true; do
        stream_name=$(printf "test%02d" $count)
        echo "推送流: $stream_name"
        
        # 添加 -y 参数强制覆盖
        # -t 1：关键参数 - 只推送1秒时长
        # 2> /dev/null：将错误输出重定向到空设备（不显示FFmpeg日志）
        ffmpeg -y \
            -re \
            -stream_loop -1 \
            -i "/Users/Downloads/bbb_30fps_gop_60_3mbps.mp4" \
            -vcodec copy \
            -acodec copy \
            -f flv \
            -t 1 \
            "rtmp://publish-callback.com/buckettest/$stream_name" \
            2> /dev/null
        
        echo "流 $stream_name 推送完成"
        
        count=$((count + 1))
        if [ $count -gt 100 ]; then count=1; fi
    done

    # 典型应用场景
    ##CDN压力测试：模拟大量直播流同时推流；流媒体服务器性能测试；负载均衡测试；直播平台容量验证

    # 注意事项
    ## 由于每个流只推1秒，服务器端可能还来不及建立完整连接就断开了；2> /dev/null 会隐藏错误信息，调试时建议移除；实际测试时可能需要调整 -t 参数的值以获得更好的测试效果
        
        
    ########################################## 方式二 ####################################

#!/bin/bash

# 同时推送5路流
for i in {1..5}; do
    stream_name="test$(printf "%02d" $i)"
    echo "启动推流: $stream_name"
    
    ffmpeg -re \
        -stream_loop -1 \
        -i "/Users/Downloads/bbb_30fps_gop_60_3mbps.mp4" \
        -vcodec copy -acodec copy \
        -f flv \
        "rtmp://publish-callback.com/buckettest/$stream_name" \
        2> /dev/null &
done

echo "所有推流任务已启动"
echo "输入 'pkill ffmpeg' 停止所有推流"
wait