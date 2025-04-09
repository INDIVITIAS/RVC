#!/bin/bash

set -e

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

echo "📁 Создание папок..."
mkdir -p weights/VARGANOV inputs results

echo "📂 Ожидается:"
echo " - Модель: weights/VARGANOV/VARGANOV.pth"
echo " - Индекс: weights/VARGANOV/-VARGANOV"
echo " - Аудио:  inputs/1.wav"
read -p "⏳ Положи файлы и нажми Enter для продолжения..."

echo "🚀 Запуск инференса..."
python infer_cli.py \
  --input_path inputs/1.wav \
  --output_path results/output.wav \
  --model_path weights/VARGANOV/VARGANOV.pth \
  --index_path weights/VARGANOV/-VARGANOV \
  --f0_method harvest \
  --transpose 0 \
  --speaker_id 0

echo "✅ Готово! Файл: results/output.wav"
