"""add kyc documents and profile verification status

Revision ID: e19311b268dc
Revises: d12220c2f962
Create Date: 2026-09-09 21:01:03.731590

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = 'e19311b268dc'
down_revision: Union[str, Sequence[str], None] = 'd12220c2f962'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table(
        'kyc_documents',
        sa.Column('id', sa.String(), nullable=False),
        sa.Column('profile_id', sa.String(), nullable=False),
        sa.Column('doc_type', sa.String(), nullable=False),
        sa.Column('file_url', sa.String(), nullable=False),
        sa.Column('uploaded_at', sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint('id'),
    )
    op.create_index(
        op.f('ix_kyc_documents_profile_id'), 'kyc_documents', ['profile_id'], unique=False
    )
    op.add_column(
        'profiles',
        sa.Column(
            'verification_status',
            sa.String(),
            nullable=False,
            server_default='unverified',
        ),
    )


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_column('profiles', 'verification_status')
    op.drop_index(op.f('ix_kyc_documents_profile_id'), table_name='kyc_documents')
    op.drop_table('kyc_documents')
