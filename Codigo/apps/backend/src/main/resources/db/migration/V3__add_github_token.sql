ALTER TABLE users ADD COLUMN github_access_token TEXT;
ALTER TABLE users DROP COLUMN github_access_tokens;