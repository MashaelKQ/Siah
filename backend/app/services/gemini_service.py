import os

from dotenv import load_dotenv
from google import genai

load_dotenv()

api_key = os.getenv("GEMINI_API_KEY")

if not api_key:
    raise ValueError("GEMINI_API_KEY is missing from the .env file.")

client = genai.Client(api_key=api_key)


def generate_weekly_quests(
    ghq_score: int,
    ghq_answers: dict,
    language: str = "English",
) -> str:
    prompt = f"""
You are a wellbeing assistant.

Generate 5 personalized wellness quests for the user's upcoming week.

User information:
GHQ total score: {ghq_score}

GHQ answers:
{ghq_answers}

Preferred language:
{language}

Requirements:
- Do not diagnose the user.
- Do not claim the user has a mental health condition.
- Do not provide medical treatment.
- Keep each quest practical and achievable.
- Each quest should take no more than 20 minutes.
- Focus on wellbeing areas such as:
  - sleep
  - stress management
  - recovery
  - social connection
  - movement
  - healthy routines
  - mindfulness
- Generate exactly 5 quests.
- Keep the wording supportive and concise.
- Return valid JSON only.

Use this exact structure:

{{
  "weekly_quests": [
    {{
      "title": "Quest title",
      "description": "Short quest description",
      "category": "Category",
      "estimated_minutes": 10
    }}
  ]
}}
"""

    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=prompt,
    )

    return response.text