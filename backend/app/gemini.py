import json

from google import genai

from app.config import GEMINI_API_KEY
from app.prompts import build_weekly_prompt

# Create Gemini client
client = genai.Client(api_key=GEMINI_API_KEY)


def generate_weekly_quests(
    ghq_score: int,
    ghq_answers: dict,
    language: str = "English",
):
    """
    Generates personalized weekly wellness quests using Gemini.
    """

    prompt = build_weekly_prompt(
        ghq_score=ghq_score,
        ghq_answers=ghq_answers,
        language=language,
    )

    response = client.models.generate_content(
    model="gemini-3.6-flash",
    contents=prompt,
)           

    text = response.text.strip()

    # Remove Markdown code fences if Gemini returns them
    if text.startswith("```json"):
        text = text.replace("```json", "", 1)

    if text.endswith("```"):
        text = text[:-3]

    try:
        return json.loads(text.strip())

    except json.JSONDecodeError:
        return {
            "error": "Gemini returned an invalid JSON response.",
            "raw_response": text,
        }