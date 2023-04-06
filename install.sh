#!/bin/bash

cat << 'EOL' > /usr/local/bin/tcpa
#!/bin/bash

start_sh_path="/usr/local/storage/tcpav2/start.sh"
backup_sh_path="/usr/local/storage/tcpav2/start.sh.bak"

if [ ! -f "$start_sh_path" ]; then
    if [ -f "$backup_sh_path" ]; then
        cp "$backup_sh_path" "$start_sh_path"
        echo "start.sh文件丢失，已从备份文件恢复至$start_sh_path"
    else
        echo "未找到$start_sh_path，请检查TCPA是否正确安装。按任意键退出。"
        read -rsn1
        exit 1
    fi
fi

if [ ! -f "$backup_sh_path" ]; then
    cp "$start_sh_path" "$backup_sh_path"
    echo "已将配置文件备份至：$backup_sh_path"
else
    echo "已找到备份文件$backup_sh_path"
fi

add_ports() {
    local ports=$1

    # 查找已存在的端口行的最后一个位置
    local last_port_line=$(grep -n 'tport' $start_sh_path | tail -n 1 | cut -d ':' -f 1)

    IFS=',' read -ra port_array <<< "$ports"
    for port in "${port_array[@]}"; do
        # 在最后一个端口行后面添加新的端口行
        sed -i "${last_port_line}a \$BINDIR/\$CTLAPP access add tip \$ip tport $port" $start_sh_path
        echo "已添加端口 $port"
        last_port_line=$((last_port_line + 1))
    done
}

remove_port() {
    local port=$1

    # 删除指定端口的行
    sed -i "/tport $port/d" $start_sh_path
    echo "已删除端口 $port"
}

restore_backup() {
    cp "$backup_sh_path" "$start_sh_path"
    echo "已从备份文件恢复至$start_sh_path"
}

view_start_sh() {
    cat "$start_sh_path"
}

while true; do
    echo "1) 添加端口"
    echo "2) 删除端口"
    echo "3) 从备份恢复配置"
    echo "4) 查看start.sh源码"
    echo "5) 退出"
    echo "请输入选项（1-5）： "
    read -r option

    case $option in
        1)
            echo "请输入要添加的端口（用逗号分隔）： "
            read -r ports
            add_ports "$ports"
            read -rsp $'按任意键继续...\n' -n1
            ;;
        2)
            echo "请输入要删除的端口： "
            read -r port
            remove_port "$port"
            read -rsp $'按任意键继续...\n' -n1
            ;;
        3)
            restore_backup
            read -rsp $'按任意键继续...\n' -n1
            ;;
        4)
            view_start_sh
            read -rsp $'按任意键继续...\n' -n1
            ;;
        5)
            break
            ;;
        *)
            echo "无效的选项，请输入1-5之间的数字。"
            read -rsp $'按任意键继续...\n' -n1
            ;;
    esac
done
EOL

clear && 
chmod +x /usr/local/bin/tcpa
