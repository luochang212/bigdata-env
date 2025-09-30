#!/bin/bash

# Hive 示例执行脚本
# 使用方法：./run_hive_examples.sh [选项]

echo "=== Hive 功能测试脚本 ==="
echo "请确保 Hive 服务已经启动"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函数：打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 函数：执行 Hive SQL 文件
execute_hive_sql() {
    local sql_file=$1
    local description=$2
    
    print_message $BLUE "正在执行: $description"
    print_message $YELLOW "文件: $sql_file"
    echo "----------------------------------------"
    
    if [ -f "$sql_file" ]; then
        hive -f "$sql_file"
        if [ $? -eq 0 ]; then
            print_message $GREEN "✓ $description 执行成功"
        else
            print_message $RED "✗ $description 执行失败"
        fi
    else
        print_message $RED "✗ 文件不存在: $sql_file"
    fi
    echo ""
}

# 函数：执行单个 Hive 命令
execute_hive_command() {
    local command=$1
    local description=$2
    
    print_message $BLUE "正在执行: $description"
    print_message $YELLOW "命令: $command"
    echo "----------------------------------------"
    
    echo "$command" | hive
    if [ $? -eq 0 ]; then
        print_message $GREEN "✓ $description 执行成功"
    else
        print_message $RED "✗ $description 执行失败"
    fi
    echo ""
}

# 函数：显示帮助信息
show_help() {
    echo "使用方法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help          显示此帮助信息"
    echo "  -1, --create        只执行创建数据库和表"
    echo "  -2, --insert        只执行插入样本数据"
    echo "  -3, --query         只执行查询示例"
    echo "  -a, --all           执行所有示例（默认）"
    echo "  -c, --connect       测试 Hive 连接"
    echo "  -s, --status        显示 Hive 状态信息"
    echo "  -i, --interactive   进入交互式 Hive 命令行"
    echo ""
    echo "示例:"
    echo "  $0                  # 执行所有示例"
    echo "  $0 -1               # 只创建数据库和表"
    echo "  $0 -c               # 测试连接"
    echo "  $0 -i               # 进入交互模式"
}

# 函数：测试 Hive 连接
test_connection() {
    print_message $BLUE "测试 Hive 连接..."
    execute_hive_command "SHOW DATABASES;" "显示数据库列表"
}

# 函数：显示 Hive 状态
show_status() {
    print_message $BLUE "显示 Hive 状态信息..."
    execute_hive_command "SHOW DATABASES;" "显示所有数据库"
    execute_hive_command "USE test_db; SHOW TABLES;" "显示 test_db 中的表"
}

# 函数：进入交互模式
interactive_mode() {
    print_message $GREEN "进入 Hive 交互式命令行..."
    print_message $YELLOW "提示: 输入 'quit;' 或 'exit;' 退出"
    hive
}

# 主执行函数
run_all_examples() {
    print_message $GREEN "开始执行 Hive 功能测试..."
    echo ""
    
    # 1. 创建数据库和表
    execute_hive_sql "01_create_database_tables.sql" "创建数据库和表结构"
    
    # 2. 插入样本数据
    execute_hive_sql "02_insert_sample_data.sql" "插入样本数据"
    
    # 3. 执行查询示例
    execute_hive_sql "03_query_examples.sql" "执行查询示例"
    
    print_message $GREEN "所有示例执行完成！"
}

# 解析命令行参数
case "$1" in
    -h|--help)
        show_help
        exit 0
        ;;
    -1|--create)
        execute_hive_sql "01_create_database_tables.sql" "创建数据库和表结构"
        ;;
    -2|--insert)
        execute_hive_sql "02_insert_sample_data.sql" "插入样本数据"
        ;;
    -3|--query)
        execute_hive_sql "03_query_examples.sql" "执行查询示例"
        ;;
    -c|--connect)
        test_connection
        ;;
    -s|--status)
        show_status
        ;;
    -i|--interactive)
        interactive_mode
        ;;
    -a|--all|"")
        run_all_examples
        ;;
    *)
        print_message $RED "未知选项: $1"
        show_help
        exit 1
        ;;
esac