CREATE TABLE
    posts (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        user_id UUID NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
        portfolio_snapshot_id UUID REFERENCES portfolio_snapshots (id) ON DELETE SET NULL,
        content TEXT NOT NULL,
        comments_count INTEGER NOT NULL DEFAULT 0,
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