################### 方式一：使用ffmpeg代替ffplay进行压测 ##################################
# 依赖parallel
#!/bin/bash
# load_test_ffmpeg.sh

CONCURRENT=5
DURATION=20
URL="http://139.226.161.66:31036/mikudemo/timestamps.flv"

echo "🚀 使用FFmpeg进行流压测"
echo "并发数: $CONCURRENT"
echo "测试时长: ${DURATION}秒"
echo "目标: $URL"
echo "================================"

# 设置FFmpeg路径（根据你的实际路径调整）
FFMPEG_PATH="ffmpeg"  # 如果就在当前目录
# 或者如果已经复制到系统路径：FFMPEG_PATH="ffmpeg"

# 单个流测试函数
test_stream() {
    local id=$1
    local log_file="stream_${id}.log"
    
    echo "[$(date '+%H:%M:%S')] 启动流$id"
    
    # 使用ffmpeg拉流并输出到null（不保存文件）
    timeout $DURATION $FFMPEG_PATH \
        -v info \
        -i "$URL" \
        -t $DURATION `# 限制时长` \
        -f null - `# 输出到空，不保存文件` \
        > "$log_file" 2>&1
    
    local result=$?
    
    # 分析结果
    if grep -q "frame=.*fps=.*q=.*size=.*time=" "$log_file"; then
        local frames=$(grep "frame=" "$log_file" | tail -1 | sed 's/.*frame= *//' | sed 's/ .*//')
        echo "✅ 流$id 成功 - 处理帧数: $frames"
    else
        echo "❌ 流$id 失败"
        # 显示错误信息
        grep -E "error|Error|failed|Invalid" "$log_file" | head -3
    fi
    
    # 清理日志文件
    rm -f "$log_file"
}

export -f test_stream
export FFMPEG_PATH URL DURATION

echo "开始时间: $(date)"

# 使用parallel并发测试
seq 1 $CONCURRENT | parallel -j $CONCURRENT test_stream {}

echo "结束时间: $(date)"
echo "✅ 压测完成"

################### 方式二：使用ffmpeg代替ffplay进行压测 ##################################

for i in {1..3}; do 
    (
        echo "启动流$i..." 
        output=$(./ffmpeg -i "http://139.226.161.66:31036/mikudemo/timestamps.flv" -t 10 -f null - 2>&1)
        echo "$output" | grep -q "frame=" && echo "✅ 流$i 成功" || echo "❌ 流$i 失败"
    ) &
done

# 等待所有后台任务完成
wait
echo "所有流测试完成"
