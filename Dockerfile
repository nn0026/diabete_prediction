FROM python:3.11

# Create a folder /app if it doesn't exist,
# the /app folder is the current working directory
WORKDIR /app


COPY ./requirements.txt /app

COPY ./models /app/models

COPY ./app/main.py /app
COPY ./app/utils /app/utils

ENV MODEL_PATH=/app/models/model.pkl
ENV SCALER_PATH=/app/models/scaler.gz

LABEL maintainer="hnmike"

EXPOSE 30000


RUN pip install -r requirements.txt --no-cache-dir

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "30000"]