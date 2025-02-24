# Usa la imagen base de Ollama
FROM ollama/ollama:latest

# Instala dependencias necesarias
RUN apt-get update && apt-get install -y curl

# Descarga el modelo desde Hugging Face
RUN curl -L -o /root/.ollama/models/DeepSeek-R1-Distill-Qwen-7B-GGUF.Q3_K_L https://huggingface.co/lmstudio-community/DeepSeek-R1-Distill-Qwen-7B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-7B-GGUF.Q3_K_L.gguf

# Agrega el modelo a Ollama con una configuración específica
RUN ollama create deepseek-r1-distill-qwen --model /root/.ollama/models/DeepSeek-R1-Distill-Qwen-7B-GGUF.Q3_K_L

# Expone el puerto predeterminado de Ollama
EXPOSE 11434

# Inicia el servidor de Ollama
CMD ["ollama", "serve"]
