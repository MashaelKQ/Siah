from fastapi import FastAPI, HTTPException

from app.models import BurnoutInput, QuestRequest
from app.burnout import predict_burnout_result
from app.gemini import generate_weekly_quests

app = FastAPI(
    title="SIAH API",
    version="2.0.0",
)


@app.get("/")
def health_check():
    return {
        "status": "SIAH API is running",
        "version": "2.0.0",
    }


@app.post("/predict")
def predict_burnout(data: BurnoutInput):
    return predict_burnout_result(data)


@app.post("/generate-quests")
def generate_quests(request: QuestRequest):
    try:
        return generate_weekly_quests(
            ghq_score=request.ghq_score,
            ghq_answers=request.ghq_answers,
            language=request.language,
        )

    except Exception as error:
        raise HTTPException(
            status_code=500,
            detail=str(error),
        )