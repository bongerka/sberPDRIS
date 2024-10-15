#!/bin/bash

PIDFILE="/tmp/monitor.pid"

start_monitor() {
    if [ -f "$PIDFILE" ]; then
        PID=$(cat $PIDFILE)
        if kill -0 $PID 2>/dev/null; then
            echo "Мониторинг уже запущен. PID: $PID"
            exit 1
        else
            rm $PIDFILE
        fi
    fi
    nohup $0 MONITOR &>/dev/null &
    echo $! > $PIDFILE
    echo "Мониторинг запущен. PID: $!"
}

stop_monitor() {
    if [ -f "$PIDFILE" ]; then
        PID=$(cat $PIDFILE)
        if kill -0 $PID 2>/dev/null; then
            kill $PID
            rm $PIDFILE
            echo "Мониторинг остановлен"
        else
            echo "Процесс не запущен, но файл PID существует"
            rm $PIDFILE
        fi
    else
        echo "Файл PID не найден. Запущен ли мониторинг?"
    fi
}

status_monitor() {
    if [ -f "$PIDFILE" ]; then
        PID=$(cat $PIDFILE)
        if kill -0 $PID 2>/dev/null; then
            echo "Мониторинг запущен. PID: $PID"
        else
            echo "Мониторинг не запущен, но файл PID существует"
        fi
    else
        echo "Мониторинг не запущен"
    fi
}

monitor() {
    START_TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
    CURRENT_DATE=$(date '+%Y%m%d')
    FILENAME="monitor_${START_TIMESTAMP}_${CURRENT_DATE}.csv"
    echo "Timestamp,Filesystem,Used%,Available,InodesFree" > $FILENAME

    while true; do
        NEW_DATE=$(date '+%Y%m%d')
        if [[ "$NEW_DATE" != "$CURRENT_DATE" ]]; then
            CURRENT_DATE="$NEW_DATE"
            FILENAME="monitor_${START_TIMESTAMP}_${CURRENT_DATE}.csv"
            echo "Timestamp,Filesystem,Used%,Available,InodesFree" > $FILENAME
        fi

        TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
        df -hP | awk 'NR>1 {print $1,$5,$4,$6}' | while read filesystem used_percent available mounted_on; do
            inodes_free=$(df -hiP | awk -v fs="$filesystem" '$1==fs {print $4}')
            echo "$TIMESTAMP,$filesystem,$used_percent,$available,$inodes_free" >> $FILENAME
        done

        sleep 60
    done
}

case "$1" in
    START)
        start_monitor
        ;;
    STOP)
        stop_monitor
        ;;
    STATUS)
        status_monitor
        ;;
    MONITOR)
        monitor
        ;;
    *)
        echo "Использование: $0 {START|STOP|STATUS}"
        exit 1
        ;;
esac

