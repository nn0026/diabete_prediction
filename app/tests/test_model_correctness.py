import joblib
import numpy as np
import os

# Define path to our model
MODEL_DIR = "models"


def test_model_correctness():
    """Test that the model correctly predicts a sample."""
    model_path = os.path.join(MODEL_DIR, "model.pkl")
    scaler_path = os.path.join(MODEL_DIR, "scaler.gz")
    
    assert os.path.exists(model_path), f"Model file not found at {model_path}"
    assert os.path.exists(scaler_path), f"Scaler file not found at {scaler_path}"
    
    # Load model and scaler
    clf = joblib.load(model_path)
    scaler = joblib.load(scaler_path)
    
    # Test data 
    data = [0.0, 120.0, 74.0, 18.0, 63.0, 30.5, 0.285, 26.0]
    x = np.array(data).reshape(-1, 8)
    x_scaled = scaler.transform(x)
    
    # Make prediction and test result
    pred = clf.predict(x_scaled)[0]
    assert pred == 0, f"Expected prediction to be 0 (no diabetes), but got {pred}"
    
    print("Model prediction test passed!")