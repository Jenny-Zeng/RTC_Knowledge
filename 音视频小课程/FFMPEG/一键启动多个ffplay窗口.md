在实际测试中，我们有时会开启多个控制台窗口去拉流，最简单的方式是使用循环批量启动，具体脚本如下
# 启动10个 ffplay 窗口
    for i in {1..10}; do
        ffplay "http://129.226.161.66/bucketdemo/timestamps.flv" &
    done

# 停止所有 ffplay 窗口
    pkill ffplay