from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    stripe_secret_key: str
    stripe_publishable_key: str
    database_url: str = "sqlite:///./bosdom.db"


settings = Settings()
