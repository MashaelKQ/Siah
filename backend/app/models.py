from pydantic import BaseModel, Field


# ==========================================================
# Burnout Prediction Request
# ==========================================================
class BurnoutInput(BaseModel):
    age: float = Field(ge=18, le=100)
    experience_years: float = Field(ge=0, le=80)
    daily_work_hours: float = Field(ge=0, le=24)
    sleep_hours: float = Field(ge=0, le=24)
    caffeine_intake: float = Field(ge=0, le=20)
    screen_time: float = Field(ge=0, le=24)
    exercise_hours: float = Field(ge=0, le=24)
    stress_level: float = Field(ge=0, le=100)


# ==========================================================
# Weekly Wellness Quest Request
# ==========================================================
class QuestRequest(BaseModel):
    ghq_score: int = Field(
        ge=0,
        description="Overall GHQ score",
    )

    ghq_answers: dict = Field(
        description="Dictionary containing the user's GHQ responses",
    )

    language: str = Field(
        default="English",
        description="Language for the generated quests",
    )