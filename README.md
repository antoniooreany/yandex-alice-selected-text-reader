# Yandex Alice Selected Text Reader

Проект для Windows, который помогает запускать озвучивание выделенного текста в Яндекс.Браузере через AutoHotkey.

## Возможности

- F8 — подсказка по настройке.
- F9 — основной режим озвучивания выделенного текста.
- F10 — альтернативный режим для сайтов с другой позицией пункта меню.
- Работа только в активном окне Яндекс.Браузера.
- Базовое логирование в проекте.
- Тесты структуры проекта через Pester.

## Требования

- Windows
- Яндекс.Браузер
- AutoHotkey v2
- PowerShell 5.1+ или PowerShell 7+
- Pester (для запуска тестов)

## Быстрый старт

1. Установить AutoHotkey v2.
2. Открыть `scripts/yandex-alice-read-selected.ahk`.
3. При необходимости изменить:
   - `MAIN_MENU_INDEX`
   - `ALT_MENU_INDEX`
4. Запустить AHK-скрипт.
5. В Яндекс.Браузере выделить текст и проверить F9 / F10.

## Запуск тестов

```powershell
.\tools\run-tests.ps1
```

## Логи

Логи складываются в папку `logs/`.

## Структура проекта

```text
yandex-alice-selected-text-reader/
├─ README.md
├─ .gitignore
├─ logs/
│  └─ .gitkeep
├─ scripts/
│  └─ yandex-alice-read-selected.ahk
├─ docs/
│  ├─ notes.md
│  └─ test-cases.md
├─ tests/
│  └─ project.tests.ps1
└─ tools/
   ├─ bootstrap-project.ps1
   ├─ run-tests.ps1
   └─ common.ps1
```
