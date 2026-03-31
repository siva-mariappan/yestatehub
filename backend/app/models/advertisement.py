from pydantic import BaseModel, Field
from typing import Optional, List
from enum import Enum


class AdStatusEnum(str, Enum):
    active = "active"
    paused = "paused"
    expired = "expired"
    draft = "draft"


class AdPlacementEnum(str, Enum):
    home_carousel = "home_carousel"
    search_banner = "search_banner"
    property_detail = "property_detail"
    sidebar = "sidebar"


class AdvertisementCreate(BaseModel):
    model_config = {"extra": "ignore"}

    title: str = ""
    subtitle: str = ""
    image_url: str = ""
    cta_text: str = "Learn More"
    cta_link: str = ""
    placement: str = "home_carousel"
    advertiser_name: str = ""
    advertiser_email: str = ""
    budget: float = 0
    priority: int = 1
    bg_color: str = "#1E3A5F"
    text_color: str = "#FFFFFF"
    icon: str = "campaign"
    start_date: str = ""  # ISO format
    end_date: str = ""    # ISO format
    status: str = "active"


class AdvertisementUpdate(BaseModel):
    title: Optional[str] = None
    subtitle: Optional[str] = None
    image_url: Optional[str] = None
    cta_text: Optional[str] = None
    cta_link: Optional[str] = None
    placement: Optional[str] = None
    advertiser_name: Optional[str] = None
    advertiser_email: Optional[str] = None
    budget: Optional[float] = None
    priority: Optional[int] = None
    bg_color: Optional[str] = None
    text_color: Optional[str] = None
    icon: Optional[str] = None
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    status: Optional[str] = None


class AdvertisementResponse(BaseModel):
    model_config = {"extra": "ignore"}

    id: str
    title: str = ""
    subtitle: str = ""
    image_url: str = ""
    cta_text: str = ""
    cta_link: str = ""
    placement: str = "home_carousel"
    advertiser_name: str = ""
    advertiser_email: str = ""
    budget: float = 0
    impressions: int = 0
    clicks: int = 0
    priority: int = 1
    bg_color: str = "#1E3A5F"
    text_color: str = "#FFFFFF"
    icon: str = "campaign"
    start_date: str = ""
    end_date: str = ""
    status: str = "active"
    created_by: str = ""
    created_at: str = ""
    updated_at: str = ""
