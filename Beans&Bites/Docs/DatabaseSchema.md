# Local Database Schema (SQLite)

## Engine
- SQLite (recommended via GRDB or raw SQLite)
- ISO-8601 UTC timestamps
- Foreign keys enabled

## Tables

### users
- id TEXT PRIMARY KEY
- role TEXT NOT NULL
- username TEXT NOT NULL UNIQUE
- full_name TEXT NOT NULL
- email TEXT NOT NULL UNIQUE
- password_hash TEXT NOT NULL
- phone_number TEXT
- is_phone_verified INTEGER NOT NULL DEFAULT 0
- date_of_birth TEXT
- location TEXT
- gender TEXT
- level INTEGER NOT NULL DEFAULT 1
- xp INTEGER NOT NULL DEFAULT 0
- streak_days INTEGER NOT NULL DEFAULT 0
- favorite_brew_method TEXT
- bio TEXT
- profile_pic TEXT
- created_at TEXT NOT NULL
- updated_at TEXT NOT NULL

### equipment
- id TEXT PRIMARY KEY
- user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE
- equipment_type TEXT NOT NULL
- created_at TEXT NOT NULL

### coffee_beans
- id TEXT PRIMARY KEY
- name TEXT NOT NULL
- origin TEXT NOT NULL
- variety TEXT
- process TEXT
- altitude_meters INTEGER
- recommended_roast TEXT
- notes_json TEXT NOT NULL

### brew_templates
- id TEXT PRIMARY KEY
- user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE
- title TEXT NOT NULL
- method TEXT NOT NULL
- dose_grams REAL NOT NULL
- water_ml INTEGER NOT NULL
- grind_size TEXT NOT NULL
- roast TEXT NOT NULL
- notes TEXT
- is_public INTEGER NOT NULL DEFAULT 0
- created_at TEXT NOT NULL
- updated_at TEXT NOT NULL

### brew_sessions
- id TEXT PRIMARY KEY
- user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE
- template_id TEXT REFERENCES brew_templates(id) ON DELETE SET NULL
- bean_id TEXT REFERENCES coffee_beans(id) ON DELETE SET NULL
- method TEXT NOT NULL
- stage TEXT NOT NULL
- started_at TEXT NOT NULL
- ended_at TEXT
- is_completed INTEGER NOT NULL DEFAULT 0

### brew_steps
- id TEXT PRIMARY KEY
- session_id TEXT NOT NULL REFERENCES brew_sessions(id) ON DELETE CASCADE
- step_order INTEGER NOT NULL
- title TEXT NOT NULL
- details TEXT
- start_second INTEGER NOT NULL
- end_second INTEGER NOT NULL
- is_checked INTEGER NOT NULL DEFAULT 0

### taste_logs
- id TEXT PRIMARY KEY
- session_id TEXT NOT NULL UNIQUE REFERENCES brew_sessions(id) ON DELETE CASCADE
- acidity REAL NOT NULL
- sweetness REAL NOT NULL
- bitterness REAL NOT NULL
- body REAL NOT NULL
- flavor_notes TEXT
- rating INTEGER NOT NULL
- created_at TEXT NOT NULL

### achievements
- id TEXT PRIMARY KEY
- code TEXT NOT NULL UNIQUE
- title TEXT NOT NULL
- subtitle TEXT
- icon_name TEXT

### user_achievements
- id TEXT PRIMARY KEY
- user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE
- achievement_id TEXT NOT NULL REFERENCES achievements(id) ON DELETE CASCADE
- unlocked_at TEXT NOT NULL
- UNIQUE(user_id, achievement_id)

### challenges
- id TEXT PRIMARY KEY
- title TEXT NOT NULL
- description TEXT
- starts_at TEXT NOT NULL
- ends_at TEXT NOT NULL
- status TEXT NOT NULL

### challenge_entries
- id TEXT PRIMARY KEY
- challenge_id TEXT NOT NULL REFERENCES challenges(id) ON DELETE CASCADE
- user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE
- brew_session_id TEXT REFERENCES brew_sessions(id) ON DELETE SET NULL
- score REAL NOT NULL DEFAULT 0
- submitted_at TEXT NOT NULL

### community_posts
- id TEXT PRIMARY KEY
- user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE
- brew_session_id TEXT REFERENCES brew_sessions(id) ON DELETE SET NULL
- method TEXT NOT NULL
- dose_grams REAL
- water_ml INTEGER
- roast TEXT
- grind_size TEXT
- flavor_notes TEXT
- caption TEXT
- image_name TEXT
- likes_count INTEGER NOT NULL DEFAULT 0
- comments_count INTEGER NOT NULL DEFAULT 0
- created_at TEXT NOT NULL

### app_settings
- key TEXT PRIMARY KEY
- value TEXT NOT NULL

## Indexes
- CREATE INDEX idx_brew_sessions_user_started ON brew_sessions(user_id, started_at DESC);
- CREATE INDEX idx_taste_logs_session ON taste_logs(session_id);
- CREATE INDEX idx_community_posts_created ON community_posts(created_at DESC);
- CREATE INDEX idx_challenge_entries_challenge_score ON challenge_entries(challenge_id, score DESC);

## Migration Strategy
- schema_version integer in app settings
- forward-only migrations
- seed sample data in first launch transaction
