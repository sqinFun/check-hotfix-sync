#!/usr/bin/env bash
# Синхронизация веток staging и dev после заливки хотфикса в main.
# Использование: pnpm run hotfix-sync

set -euo pipefail

# --- Цвета ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

log_step() { echo -e "${CYAN}==> $1${RESET}"; }
log_ok()   { echo -e "${GREEN}OK: $1${RESET}"; }
log_err()  { echo -e "${RED}ОШИБКА: $1${RESET}"; }

# --- Запоминаем исходную ветку ---
ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# --- Проверка незакоммиченных изменений ---
if [ -n "$(git status --porcelain)" ]; then
    log_err "Есть незакоммиченные изменения."
    echo "Закоммить или спрячь их (git stash) перед запуском скрипта."
    exit 1
fi

# --- Вспомогательная функция: мерж с обработкой конфликтов ---
merge_or_stop() {
    local source_ref="$1"
    local target_branch="$2"

    if ! git merge "$source_ref" --no-edit; then
        echo ""
        log_err "Конфликт при мерже ${source_ref} в ${target_branch}."
        echo ""
        echo "Что делать:"
        echo "  1. Разреши конфликты в редакторе"
        echo "  2. git add ."
        echo "  3. git commit"
        echo "  4. git push"
        if [ "$target_branch" = "staging" ]; then
            echo "  5. Повтори: pnpm run hotfix-sync"
            echo "     (или продолжи вручную с шага dev)"
        fi
        echo ""
        exit 1
    fi
}

# --- Шаг 1: fetch ---
log_step "Fetching..."
git fetch
log_ok "Fetch выполнен"

# --- Шаг 2: staging ---
log_step "Переключаемся на staging..."
git checkout staging

log_step "Обновляем staging (pull)..."
git pull
log_ok "staging обновлен"

log_step "Мержим origin/main в staging..."
merge_or_stop "origin/main" "staging"
log_ok "origin/main успешно влит в staging"

log_step "Пушим staging..."
git push
log_ok "staging запушен"

# --- Шаг 3: dev ---
log_step "Fetching..."
git fetch

log_step "Переключаемся на dev..."
git checkout dev

log_step "Обновляем dev (pull)..."
git pull
log_ok "dev обновлен"

log_step "Мержим origin/staging в dev..."
merge_or_stop "origin/staging" "dev"
log_ok "origin/staging успешно влит в dev"

log_step "Пушим dev..."
git push
log_ok "dev запушен"

# --- Возврат на исходную ветку ---
log_step "Возвращаемся на ${ORIGINAL_BRANCH}..."
git checkout "$ORIGINAL_BRANCH"

echo ""
echo -e "${GREEN}Готово! staging и dev обновлены из main.${RESET}"
