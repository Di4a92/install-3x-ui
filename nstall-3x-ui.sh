#!/bin/bash

# Функция логирования
log() {
    echo "$(date) - $1" | tee -a /var/log/3x-ui-install.log
}

# Проверка прав root
if [[ $EUID -ne 0 ]]; then
   echo "Этот скрипт должен быть запущен с правами root" 
   exit 1
fi

log "=== Начало процесса установки 3x UI ==="

# Установка зависимостей
log "Проверка и установка необходимых пакетов..."
apt-get update && apt-get install -y curl wget unzip socat

# Проверка доступности URL для установки 3x UI
UI_URL="https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh"
log "Проверка доступности URL $UI_URL..."
HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" $UI_URL)

if [ "$HTTP_STATUS" -ne 200 ]; then
    log "Ошибка: Не удалось получить доступ к файлу установки 3x UI. HTTP статус: $HTTP_STATUS"
    exit 1
fi

# Установка 3x UI
log "Установка 3x UI..."
bash <(curl -Ls $UI_URL)
if [ $? -ne 0 ]; then
    log "Ошибка при установке 3x UI."
    exit 1
fi

log "3x UI установлен успешно."

# Запуск службы 3x UI
log "Запуск службы 3x UI..."
systemctl start x-ui
if [ $? -ne 0 ]; then
    log "Ошибка при запуске 3x UI."
    exit 1
fi

log "3x UI успешно запущен."
log "=== Установка 3x UI завершена ==="
