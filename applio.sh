#!/bin/bash

set -e

# Функция для обработки ошибок
error_exit()
{
    echo "❌ Ошибка: $1"
    exit 1
}

# Проверка на установку зависимостей
if [ ! -d "venv" ]; then
    echo "🔧 Установка зависимостей..."
    sudo apt update && sudo apt install -y git python3 python3-venv ffmpeg || error_exit "Не удалось установить зависимости"

    echo "📦 Клонирование Applio..."
    git clone https://github.com/IAHispano/Applio.git || error_exit "Не удалось клонировать репозиторий Applio"
    cd Applio

    echo "🐍 Настройка виртуального окружения..."
    python3 -m venv venv || error_exit "Не удалось создать виртуальное окружение"
    source venv/bin/activate || error_exit "Не удалось активировать виртуальное окружение"

    echo "📥 Установка Python-зависимостей..."
    pip install --upgrade pip || error_exit "Не удалось обновить pip"

    # Установка зависимостей из requirements.txt
    pip install -r requirements.txt || error_exit "Не удалось установить зависимости из requirements.txt"

    echo "⚙️ Установка PyTorch для CPU..."
    pip uninstall torch torchaudio -y
    pip install torch==2.3.1 torchaudio==2.3.1 -f https://download.pytorch.org/whl/torch_stable.html || error_exit "Не удалось установить PyTorch"
else
    echo "💾 Все зависимости уже установлены. Пропускаем установку."
fi

# Создание структуры папок, если её нет
echo "📁 Проверка и создание структуры папок..."
mkdir -p weights/VARGANOV inputs results || error_exit "Не удалось создать папки"

# Проверка наличия файлов
echo "📂 Ожидается:"
echo " - Модель: weights/VARGANOV/VARGANOV.pth"
echo " - Индекс: weights/VARGANOV/VARGANOV.index"
echo " - Аудио:  inputs/1.wav"
echo ""

# Проверка наличия файлов
if [ ! -f weights/VARGANOV/VARGANOV.pth ] || [ ! -f weights/VARGANOV/VARGANOV.index ] || [ ! -f inputs/1.wav ]; then
    echo "❗ Один или несколько файлов отсутствуют!"
    echo "Пожалуйста, положите файлы в нужные папки."
    echo "Модель в: weights/VARGANOV/VARGANOV.pth"
    echo "Индекс в: weights/VARGANOV/VARGANOV.index"
    echo "Аудиофайл в: inputs/1.wav"
    
    # Ожидание, пока файлы не будут добавлены
    read -p "🔄 Положите файлы в соответствующие папки и нажмите Enter для продолжения..."
fi

# Запуск инференса с выводом логов в консоль
echo "🚀 Запуск инференса..."

# Запуск Python скрипта с подробным выводом ошибок
python -m trace --trace rvc/infer/infer.py \
  --input_path inputs/1.wav \
  --output_path results/output.wav \
  --model_path weights/VARGANOV/VARGANOV.pth \
  --index_path weights/VARGANOV/VARGANOV.index \
  --f0_method harvest \
  --transpose 0 \
  --speaker_id 0 || error_exit "Ошибка при запуске инференса"

# Проверка, был ли создан файл
if [ -f results/output.wav ]; then
    echo "✅ Готово! Результат: results/output.wav"
else
    echo "❌ Ошибка: Файл output.wav не был создан."
    echo "Посмотри на вывод консоли для ошибок."
fi
