# hotfix-sync

Скрипт для синхронизации веток `staging` и `dev` после заливки хотфикса в `main`.

## Использование

```bash
pnpm run hotfix-sync
```

Скрипт автоматически:
1. Вливает `origin/main` в `staging` и пушит
2. Вливает `origin/staging` в `dev` и пушит
3. Возвращает тебя на исходную ветку

## Требования

### SSH-ключ

Подключение к GitHub идёт по SSH. Ключ должен быть добавлен в аккаунт GitHub и загружен в агент.

**Mac / Linux** - обычно работает из коробки. Если нет:
```bash
ssh-add ~/.ssh/id_ed25519
```

**Windows** - нужен запущенный OpenSSH Authentication Agent:
1. `Win+R` -> `services.msc`
2. Найти `OpenSSH Authentication Agent`
3. Тип запуска: `Автоматически`, нажать `Запустить`
4. Добавить ключ: `ssh-add ~/.ssh/id_ed25519`

Проверить, что всё работает: `ssh -T git@github.com`

### Терминал на Windows

Запускать из **Git Bash** (не PowerShell, не CMD). В VSCode: `Ctrl+Shift+P` -> `Terminal: Select Default Profile` -> `Git Bash`.
