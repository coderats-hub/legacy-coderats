CREATE TABLE users (
    id uuid PRIMARY KEY,
    name varchar(255) NOT NULL,
    email varchar(255),
    image varchar(255),
    github_user varchar(255) NOT NULL,
    github_id bigint NOT NULL,
    github_access_token varchar(255),
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL,
    deleted_at timestamptz,
    CONSTRAINT uk_users_email UNIQUE (email),
    CONSTRAINT uk_users_github_user UNIQUE (github_user),
    CONSTRAINT uk_users_github_id UNIQUE (github_id)
);

CREATE TABLE groups (
    id uuid PRIMARY KEY,
    name varchar(255) NOT NULL,
    description varchar(255),
    image varchar(255),
    code varchar(255),
    method varchar(255),
    status boolean NOT NULL,
    repository varchar(255),
    start_date timestamptz NOT NULL,
    end_date timestamptz,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL,
    deleted_at timestamptz,
    CONSTRAINT uk_groups_code UNIQUE (code)
);

CREATE TABLE group_participants (
    user_id uuid NOT NULL,
    group_id uuid NOT NULL,
    role varchar(255) NOT NULL,
    points integer NOT NULL,
    joined_at timestamptz NOT NULL,
    CONSTRAINT pk_group_participants PRIMARY KEY (user_id, group_id),
    CONSTRAINT fk_group_participants_user
        FOREIGN KEY (user_id) REFERENCES users (id),
    CONSTRAINT fk_group_participants_group
        FOREIGN KEY (group_id) REFERENCES groups (id)
);

CREATE TABLE checkins (
    id uuid PRIMARY KEY,
    user_id uuid NOT NULL,
    group_id uuid NOT NULL,
    title varchar(255) NOT NULL,
    description text,
    image text,
    summary_ai text,
    points integer NOT NULL,
    likes_count integer NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL,
    deleted_at timestamptz,
    CONSTRAINT fk_checkins_user
        FOREIGN KEY (user_id) REFERENCES users (id),
    CONSTRAINT fk_checkins_group
        FOREIGN KEY (group_id) REFERENCES groups (id)
);

CREATE TABLE checkin_likes (
    checkin_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamptz NOT NULL,
    CONSTRAINT pk_checkin_likes PRIMARY KEY (checkin_id, user_id),
    CONSTRAINT fk_checkin_likes_checkin
        FOREIGN KEY (checkin_id) REFERENCES checkins (id),
    CONSTRAINT fk_checkin_likes_user
        FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE INDEX idx_group_participants_group_id
    ON group_participants (group_id);

CREATE INDEX idx_group_participants_user_points
    ON group_participants (group_id, points DESC);

CREATE INDEX idx_checkins_group_created_at
    ON checkins (group_id, created_at DESC)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_checkins_group_points
    ON checkins (group_id, points DESC)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_checkins_user_created_at
    ON checkins (user_id, created_at DESC)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_checkins_created_at
    ON checkins (created_at DESC)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_checkin_likes_user_id
    ON checkin_likes (user_id);
