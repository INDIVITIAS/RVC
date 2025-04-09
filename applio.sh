#!/bin/bash

set -e

# Проверка на установку зависимостей
if [ ! -d "venv" ]; then
    echo "🔧 Установка зависимостей..."
    sudo apt update && sudo apt install -y git python3 python3-venv ffmpeg

    echo "📦 Клонирование RVC..."
    git clone https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI.git
    cd Retrieval-based-Voice-Conversion-WebUI

    echo "🐍 Настройка виртуального окружения..."
    python3 -m venv venv
    source venv/bin/activate

    echo "📥 Установка Python-зависимостей..."
    pip install --upgrade pip
    pip install -r requirements.txt

    echo "⚙️ Установка PyTorch для CPU..."
    pip uninstall torch torchaudio -y
    pip install torch==2.0.1+cpu torchaudio==2.0.2+cpu -f https://download.pytorch.org/whl/torch_stable.html
else
    echo "💾 Все зависимости уже установлены. Пропускаем установку."
fi

# Создание структуры папок, если её нет
echo "📁 Проверка и создание структуры папок..."
mkdir -p weights/VARGANOV inputs results

# Проверка наличия файлов
echo "📂 Ожидается:"
echo " - Модель: weights/VARGANOV/VARGANOV.pth"
echo " - Индекс: weights/VARGANOV/VARGANOV.index"
echo " - Аудио:  inputs/1.wav"
echo ""

# Проверим, что файлы существуют
if [ ! -f weights/VARGANOV/VARGANOV.pth ] || [ ! -f weights/VARGANOV/VARGANOV.index ] || [ ! -f inputs/1.wav ]; then
    echo "❗ Один или несколько файлов отсутствуют!"
    echo "Пожалуйста, положите файлы в нужные папки."
    echo "Модель в: weights/VARGANOV/VARGANOV.pth"
    echo "Индекс в: weights/VARGANOV/VARGANOV.index"
    echo "Аудиофайл в: inputs/1.wav"
    
    # Ожидание, пока файлы не будут добавлены
    read -p "🔄 Положите файлы в соответствующие папки и нажмите Enter для продолжения..."
fi

# Запуск инференса
echo "🚀 Запуск инференса..."
python infer_cli.py \
  --input_path inputs/1.wav \
  --output_path results/output.wav \
  --model_path weights/VARGANOV/VARGANOV.pth \
  --index_path weights/VARGANOV/VARGANOV.index \
  --f0_method harvest \
  --transpose 0 \
  --speaker_id 0

# Завершение работы
echo "✅ Готово! Результат: results/output.wav"
