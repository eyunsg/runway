CREATE TABLE
    portfolios (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        user_id UUID NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
        name VARCHAR(100) NOT NULL,
        simulation_input JSONB NOT NULL,
        simulation_result JSONB NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT now (),
        updated_at TIMESTAMP NOT NULL DEFAULT now (),
        deleted_at TIMESTAMP
    );