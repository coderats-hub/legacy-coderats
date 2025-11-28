ALTER TABLE checkins
ADD COLUMN likes_count INTEGER NOT NULL DEFAULT 0;

CREATE TABLE checkin_likes (
    checkin_id UUID NOT NULL REFERENCES checkins(id) ON DELETE CASCADE,
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (checkin_id, user_id)
);
