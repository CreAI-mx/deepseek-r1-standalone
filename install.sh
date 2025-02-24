#!/bin/bash

# Actualizar paquetes
echo "🔄 Actualizando paquetes..."
sudo apt-get update && sudo apt-get upgrade -y

# Instalar dependencias esenciales
echo "🛠 Instalando dependencias esenciales..."
sudo apt-get install -y build-essential git curl wget

# Instalar NVIDIA Container Toolkit
echo "🎮 Instalando NVIDIA Container Toolkit..."
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
sudo mkdir -p /usr/share/keyrings
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# Configurar NVIDIA runtime para Docker
echo "🖥 Configurando NVIDIA Container Runtime..."
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker || echo "⚠️ Docker no encontrado, será instalado a continuación."

# Instalar Docker
echo "🐳 Instalando Docker..."
sudo apt-get install -y docker.io

# Descargar y configurar DeepSeek-R1 en Ollama
echo "⬇️ Descargando DeepSeek-R1-Distill-Qwen-7B-GGUF en Ollama..."
docker pull ollama/ollama:latest
docker run --rm ollama/ollama:latest pull lmstudio-community/DeepSeek-R1-Distill-Qwen-7B-GGUF:Q3_K_L

echo "✅ Instalación completada. Puedes ejecutar el contenedor con: 
docker run --gpus all -p 11434:11434 ollama/ollama"
