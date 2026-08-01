import pandas as pd
import joblib

from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
)

# -----------------------------
# Load Dataset
# -----------------------------
df = pd.read_csv("data/developer_burnout_dataset_7000.csv")

# -----------------------------
# Clean Data
# -----------------------------
df = df.dropna()

df = df.drop(
    columns=[
        "bugs_per_day",
        "commits_per_day",
        "meetings_per_day",
    ]
)

# -----------------------------
# Encode Target
# -----------------------------
mapping = {
    "Low": 0,
    "Medium": 1,
    "High": 2,
}

df["burnout_level"] = df["burnout_level"].map(mapping)

# -----------------------------
# Features & Target
# -----------------------------
X = df.drop("burnout_level", axis=1)
y = df["burnout_level"]

# -----------------------------
# Train/Test Split
# -----------------------------
X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42,
    stratify=y,
)

# -----------------------------
# Create Model
# -----------------------------
model = RandomForestClassifier(
    n_estimators=100,
    random_state=42,
)

# -----------------------------
# Train
# -----------------------------
model.fit(X_train, y_train)

# -----------------------------
# Predict
# -----------------------------
predictions = model.predict(X_test)

# -----------------------------
# Evaluate
# -----------------------------
print("\nAccuracy:")
print(accuracy_score(y_test, predictions))

print("\nClassification Report:")
print(classification_report(y_test, predictions))

print("\nConfusion Matrix:")
print(confusion_matrix(y_test, predictions))

# -----------------------------
# Feature Importance
# -----------------------------
importance = pd.DataFrame({
    "Feature": X.columns,
    "Importance": model.feature_importances_
})

importance = importance.sort_values(
    by="Importance",
    ascending=False,
)

print("\nFeature Importance:")
print(importance)

# -----------------------------
# Save Model
# -----------------------------
joblib.dump(model, "models/burnout_model.pkl")

print("\n✅ Model saved successfully!")