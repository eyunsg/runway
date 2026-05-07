CREATE TABLE
    portfolio_snapshots (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        portfolio_id UUID NOT NULL REFERENCES portfolios (id) ON DELETE CASCADE,
        snapshot_data JSONB NOT NULL,
        created_at TIMESTAMP
        WITH
            TIME ZONE NOT NULL DEFAULT now (),
            updated_at TIMESTAMP
        WITH
            TIME ZONE NOT NULL DEFAULT now (),
            deleted_at TIMESTAMP
        WITH
            TIME ZONE
    );