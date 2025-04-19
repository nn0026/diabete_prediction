import os
from time import time
from typing import List

import joblib
import numpy as np
from fastapi import FastAPI, File, UploadFile
from opentelemetry import metrics, trace
from opentelemetry.exporter.prometheus import PrometheusMetricReader
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.metrics import set_meter_provider
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.resources import SERVICE_NAME, Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.trace.sampling import ALWAYS_ON
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.trace.status import Status, StatusCode
from prometheus_client import start_http_server
from pydantic import BaseModel
from sklearn.preprocessing import StandardScaler
from utils.logging import logger


# Load the ML model
model = joblib.load(os.environ.get("MODEL_PATH", "models/model.pkl"))
scaler = joblib.load(os.environ.get("SCALER_PATH", "models/scaler.gz"))

# Start Prometheus client
start_http_server(port=8099, addr="0.0.0.0")
logger.info("Prometheus metrics server started on port 8099")

# Service name is required for most backends
resource = Resource(attributes={SERVICE_NAME: "diabetes-prediction-service"})

# Configure OTLP tracing via gRPC to Collector
OTLP_ENDPOINT = os.environ.get("OTLP_ENDPOINT", "jaeger-all-in-one.tracing.svc.cluster.local:4317")
logger.info(f"OpenTelemetry configured with OTLP_ENDPOINT: {OTLP_ENDPOINT}")

trace_provider = TracerProvider(
    resource=resource,
    sampler=ALWAYS_ON
)

# Configure the OTLP exporter to send traces to Jaeger
otlp_exporter = OTLPSpanExporter(
    endpoint=OTLP_ENDPOINT,
    insecure=True  
)

# Use BatchSpanProcessor for better performance
trace_provider.add_span_processor(BatchSpanProcessor(otlp_exporter))

# Set the global tracer provider
trace.set_tracer_provider(trace_provider)
tracer = trace.get_tracer(__name__)

# Exporter to export metrics to Prometheus
reader = PrometheusMetricReader()
provider = MeterProvider(resource=resource, metric_readers=[reader])
set_meter_provider(provider)
meter = metrics.get_meter("diabetespred", "0.1.1")

# Create counter
counter = meter.create_counter(
    name="diabetespred_request_counter", description="Number of diabetespred requests"
)

histogram = meter.create_histogram(
    name="diabetespred_response_histogram",
    description="diabetespred response histogram",
    unit="seconds",
)

app = FastAPI()
FastAPIInstrumentor.instrument_app(app)

class request_body(BaseModel):
    data: List[float]
    class Config:
        schema_extra = {"example": [0.0, 120.0, 74.0, 18.0, 63.0, 30.5, 0.285, 26.0]}

@app.get("/")
def home():
    return "API is working."

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.post("/preloaded_xgb")
async def diabetes_predict(input: request_body):
    with tracer.start_as_current_span("predict-preloaded-xgb") as span:
        span.set_attribute("input.data", str(input.data))
        starting_time = time()

        with tracer.start_as_current_span("preprocess-data"):
            x = np.array(input.data).reshape(-1, 8)
            x_scaled = scaler.transform(x)

        with tracer.start_as_current_span("model-inference"):
            logger.info("Make predictions...")
            pred = model.predict(x_scaled)[0]

        result = {}
        if pred == 0:
            result["diabetes result"] = "No diabetes"
        else:
            result["diabetes result"] = "Diabetes"

        label = {"api": "/diabetespred"}

        # Increase the counter
        counter.add(10, label)

        # Mark the end of the response
        ending_time = time()
        elapsed_time = ending_time - starting_time

        # Add histogram
        logger.info(elapsed_time)
        histogram.record(elapsed_time, label)

        span.set_attribute("prediction.outcome", result["diabetes result"])
        trace_provider.force_flush()
        
        return result