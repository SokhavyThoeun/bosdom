from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str = "sqlite:///./bosdom.db"
    supabase_url: str = ""

    # Admin panel — a single hardcoded operator account, deliberately
    # separate from Supabase Auth/`Profile` since there's no admin role
    # anywhere in the regular user system (see routers/disputes.py's notes).
    admin_email: str = "admin@bosdom.app"
    admin_password: str = "change-me"
    admin_jwt_secret: str = "change-me-too"


settings = Settings()
