"""initial schema

Revision ID: d12220c2f962
Revises:
Create Date: 2026-09-09 20:51:38.721720

Baseline for the tables SQLAlchemy owns (profiles, shops, listings,
order_reports). The live Supabase database also has legacy tables
(user_profiles, products, orders, categories, co_buy_pools,
co_buy_participants, order_items) from the original supabase/migrations/*.sql
schema; those are not managed by this app's ORM and must not be touched here.
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = 'd12220c2f962'
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "profiles",
        sa.Column("id", sa.String(), primary_key=True),
        sa.Column("email", sa.String(), nullable=False),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("phone", sa.String(), nullable=False),
        sa.Column("role", sa.String(), nullable=False),
        sa.Column("avatar_url", sa.String(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_table(
        "shops",
        sa.Column("id", sa.String(), primary_key=True),
        sa.Column("shop_name", sa.String(), nullable=False),
        sa.Column("business_type", sa.String(), nullable=False),
        sa.Column("year_established", sa.String(), nullable=False),
        sa.Column("location", sa.String(), nullable=False),
        sa.Column("phone", sa.String(), nullable=False),
        sa.Column("email", sa.String(), nullable=False),
        sa.Column("description", sa.String(), nullable=False),
        sa.Column("logo_url", sa.String(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_table(
        "listings",
        sa.Column("id", sa.String(), primary_key=True),
        sa.Column("seller_id", sa.String(), nullable=False),
        sa.Column("product_name", sa.String(), nullable=False),
        sa.Column("category", sa.String(), nullable=False),
        sa.Column("price", sa.Float(), nullable=False),
        sa.Column("moq_qty", sa.Integer(), nullable=False),
        sa.Column("stock_qty", sa.Integer(), nullable=False),
        sa.Column("description", sa.String(), nullable=False),
        sa.Column("sample_testing_enabled", sa.Boolean(), nullable=False),
        sa.Column("sample_price", sa.Float(), nullable=True),
        sa.Column("photo_urls", sa.JSON(), nullable=False),
        sa.Column("sizes", sa.JSON(), nullable=False),
        sa.Column("colors", sa.JSON(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index(
        op.f("ix_listings_seller_id"), "listings", ["seller_id"], unique=False
    )
    op.create_table(
        "order_reports",
        sa.Column("id", sa.String(), primary_key=True),
        sa.Column("order_id", sa.String(), nullable=False),
        sa.Column("reason", sa.String(), nullable=False),
        sa.Column("note", sa.String(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index(
        op.f("ix_order_reports_order_id"), "order_reports", ["order_id"], unique=False
    )


def downgrade() -> None:
    op.drop_index(op.f("ix_order_reports_order_id"), table_name="order_reports")
    op.drop_table("order_reports")
    op.drop_index(op.f("ix_listings_seller_id"), table_name="listings")
    op.drop_table("listings")
    op.drop_table("shops")
    op.drop_table("profiles")
