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

    # ABA PayWay (see payway.py). Sandbox needs no domain/IP whitelisting.
    payway_merchant_id: str = ""
    payway_api_key: str = ""
    payway_base_url: str = "https://checkout-sandbox.payway.com.kh"
    # Public HTTPS address of this backend (e.g. an ngrok URL) so PayWay can
    # POST payment callbacks. Empty on a LAN-only dev box — the app's status
    # polling then confirms payments through Check Transaction instead.
    public_base_url: str = ""
    # Sandbox KHQR codes point at a placeholder account no real banking app
    # can pay, so on the sandbox the app approves an open QR itself after
    # this many seconds (0 turns that off). Ignored on production.
    payway_sandbox_khqr_approve_seconds: int = 8


settings = Settings()
