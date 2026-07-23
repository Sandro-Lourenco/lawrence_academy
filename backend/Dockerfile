FROM python:3.14-slim

WORKDIR /app

# Instalar dependências básicas do sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN useradd --create-home --shell /usr/sbin/nologin appuser \
    && chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

# Script de inicialização da API Principal (regra inegociável)
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
