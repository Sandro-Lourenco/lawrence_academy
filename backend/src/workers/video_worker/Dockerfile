# Usar imagem base leve do Python
FROM python:3.11-slim

# Evitar escrita de arquivos .pyc e ativar flush de logs em tempo real
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Instalar FFmpeg, FFprobe e dependências do sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Definir diretório de trabalho
WORKDIR /app

# Copiar dependências e instalar
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copiar o código fonte do worker
COPY . /app/

# Expor a porta do healthcheck do FastAPI
EXPOSE 8000

# Executar o worker FastAPI em modo de escuta
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
