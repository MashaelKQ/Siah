from pathlib import Path

import joblib
import pandas as pd

# ==========================================================
# Load Burnout Model
# ==========================================================

BASE_DIR = Path(__file__).resolve().parent
MODEL_PATH = BASE_DIR / "ml" / "burnout_model.pkl"

model = joblib.load(MODEL_PATH)

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


# ==========================================================
# Helper Functions
# ==========================================================

def get_contributing_factors(data):
    factors = []

    if data.stress_level >= 70:
        factors.append("High stress level")

    if data.sleep_hours < 6:
        factors.append("Insufficient sleep")

    if data.daily_work_hours > 9:
        factors.append("Long daily working hours")

    if data.screen_time > 10:
        factors.append("High screen time")

    if data.exercise_hours < 0.5:
        factors.append("Low physical activity")

    if data.caffeine_intake > 4:
        factors.append("High caffeine intake")

    if not factors:
        factors.append(
            "No major risk factors were detected from the provided inputs."
        )

    return factors[:3]


def get_recommendations(factors):
    recommendations = []

    if "High stress level" in factors:
        recommendations.append(
            "Use short recovery breaks and stress-management activities."
        )

    if "Insufficient sleep" in factors:
        recommendations.append(
            "Aim for a more consistent sleep schedule."
        )

    if "Long daily working hours" in factors:
        recommendations.append(
            "Reduce continuous working time and schedule regular breaks."
        )

    if "High screen time" in factors:
        recommendations.append(
            "Take regular screen-free breaks throughout the day."
        )

    if "Low physical activity" in factors:
        recommendations.append(
            "Add light physical activity to your daily routine."
        )

    if "High caffeine intake" in factors:
        recommendations.append(
            "Consider gradually reducing caffeine intake."
        )

    if not recommendations:
        recommendations.append(
            "Continue monitoring your wellbeing habits."
        )

    return recommendations[:3]


def get_summary(risk_level, factors):
    factor_text = ", ".join(factors).lower()

    if risk_level == "High":
        return (
            "Your responses indicate elevated burnout risk. "
            f"The main contributing factors detected were {factor_text}."
        )

    if risk_level == "Medium":
        return (
            "Your responses indicate a moderate burnout risk. "
            f"The main contributing factors detected were {factor_text}."
        )

    return (
        "Your responses indicate a lower burnout risk. "
        f"The current assessment identified {factor_text}."
    )


# ==========================================================
# Main Prediction Function
# ==========================================================

def predict_burnout_result(data):
    input_df = pd.DataFrame(
        [data.model_dump()],
        columns=FEATURES,
    )

    predicted_class = int(model.predict(input_df)[0])
    probabilities = model.predict_proba(input_df)[0]

    probabilities_by_label = {
        LABELS[int(class_id)]: round(float(probability), 4)
        for class_id, probability in zip(
            model.classes_,
            probabilities,
        )
    }

    risk_level = LABELS[predicted_class]

    confidence = round(
        probabilities_by_label[risk_level] * 100
    )

    contributing_factors = get_contributing_factors(data)

    recommendations = get_recommendations(
        contributing_factors
    )

    summary = get_summary(
        risk_level,
        contributing_factors,
    )

    return {
        "risk_level": risk_level,
        "confidence": confidence,
        "summary": summary,
        "probabilities": probabilities_by_label,
        "contributing_factors": contributing_factors,
        "recommendations": recommendations,
        "disclaimer": (
            "This is a prototype risk estimate trained on synthetic data. "
            "It is not a medical diagnosis or a clinically validated assessment."
        ),
    }