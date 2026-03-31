from pydantic import BaseModel, Field


class FavoriteCreate(BaseModel):
    target_type: str = Field(..., pattern="^(property|service|provider)$")
    target_id: str = Field(..., min_length=1)
    target_title: str = ""
    target_image: str = ""
