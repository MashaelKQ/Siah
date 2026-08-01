import joblib
import pandas as pd

MODEL_PATH = "models/burnout_model.pkl"

FEATURES = [
    "age",
    "experience_years",
    "daily_work_hours",
    "sleep_hours",
    "caffeine_intake",
    "screen_time",
    "exercise_hours",
    "stress_level",
]

LABELS = {
    0: "Low",
    1: "Medium",
    2: "High",
}

model = joblib.load(MODEL_PATH)

user_input = {
    "age": 25,
    "experience_years": 3,
    "daily_work_hours": 9,
    "sleep_hours": 5,
    "caffeine_intake": 3,
    "screen_time": 10,
    "exercise_hours": 1,
    "stress_level": 80,
}

input_df = pd.DataFrame([user_input], columns=FEATURES)

prediction = int(model.predict(input_df)[0])
probabilities = model.predict_proba(input_df)[0]

print("Estimated burnout risk:", LABELS[prediction])

print("\nProbabilities:")
for class_id, probability in zip(model.classes_, probabilities):
    print(f"{LABELS[int(class_id)]}: {probability:.1%}")