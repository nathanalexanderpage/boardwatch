-- requires CREATEDB permission
CREATE DATABASE boardwatch
    WITH
    ENCODING = 'UTF8';

-- requires superuser permission
CREATE EXTENSION "uuid-ossp";

CREATE TABLE users (
	id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
	username varchar NOT NULL UNIQUE, -- char limit 40
	email varchar NOT NULL UNIQUE,
	password text NOT NULL,
	created_at timestamptz NOT NULL DEFAULT (now() AT TIME ZONE 'utc')
);

CREATE TABLE company_roles (
	id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	name varchar NOT NULL, -- char limit 50
	description text NULL
);

CREATE TABLE companies (
	id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	name varchar NOT NULL, -- char limit 150
	street_address text NULL,
	web_address text NULL,
	description text NULL
);

CREATE TABLE generations (
	id int PRIMARY KEY,
	year_begin smallint NULL,
	year_end smallint NULL
);

CREATE TABLE platform_families (
	id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	name varchar NULL UNIQUE, -- char limit 100
	generation smallint NULL REFERENCES generations(id)
);

CREATE TABLE platform_name_groups (
	id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	name varchar NULL UNIQUE, -- char limit 50
	description varchar NULL -- char limit 100
);

CREATE TABLE platforms (
	id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	name varchar NULL, -- char limit 100
	platform_family_id smallint NULL REFERENCES platform_families(id),
	name_group_id smallint NULL REFERENCES platform_name_groups(id),
	is_brand_missing boolean NOT NULL,
	model_no varchar NULL, -- char limit 100
	storage_capacity varchar NULL, -- char limit 100
	description text NULL,
	disambiguation varchar NULL, -- char limit 100
	relevance smallint NULL -- (#/10)
);

CREATE TABLE addon_platforms (
	id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	host_platform_id int NOT NULL REFERENCES platforms(id),
	addon_platform_id int NOT NULL REFERENCES platforms(id)
);

CREATE TABLE companies_platforms (
	company_id int NOT NULL REFERENCES companies(id),
	platform_id int NOT NULL REFERENCES platforms(id),
	company_role_id int NOT NULL REFERENCES company_roles(id),
	PRIMARY KEY (company_id, platform_id, company_role_id)
);

CREATE TABLE colors (
	id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	name varchar UNIQUE NOT NULL -- char limit 50?
);

CREATE TABLE platform_editions (
	id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	name varchar NULL, -- char limit 100
	platform_id smallint NULL REFERENCES platforms(id),
	official_color varchar NULL, -- char limit 60
	has_matte boolean NULL,
	has_transparency boolean NULL,
	has_gloss boolean NULL,
	note text NULL,
	image_url text NULL
);

CREATE TABLE colors_platform_editions (
	platform_edition_id int NOT NULL REFERENCES platform_editions(id),
	color_id smallint NOT NULL REFERENCES colors(id),
	PRIMARY KEY (platform_edition_id, color_id)
);

CREATE TABLE game_series (
	id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	name varchar UNIQUE, -- char limit 150
	description varchar -- char limit 255
);

CREATE TABLE game_families (
	id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	name varchar NOT NULL UNIQUE -- char limit 255
);

CREATE TABLE games (
	id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	name varchar NOT NULL, -- char limit 255
	year_first_release smallint NULL,
	is_bootleg boolean NOT NULL
);

CREATE TABLE game_families_games (
	game_id integer NOT NULL REFERENCES games(id),
	game_family_id integer NOT NULL REFERENCES game_families(id),
	PRIMARY KEY (game_family_id, game_id)
);

CREATE TABLE game_series_games (
	game_id integer NOT NULL REFERENCES games(id),
	game_series_id integer NOT NULL REFERENCES game_series(id),
	PRIMARY KEY (game_series_id, game_id)
);

CREATE TABLE games_platforms_compatibility (
	platform_id int NOT NULL REFERENCES platforms(id),
	game_id int NOT NULL REFERENCES games(id),
	PRIMARY KEY (platform_id, game_id)
);

CREATE TABLE accessory_types (
	id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	name varchar NOT NULL UNIQUE, -- char limit 100
	description varchar NULL -- char limit 255
);

CREATE TABLE accessories (
	id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	name varchar NOT NULL, -- char limit 255
	type smallint NOT NULL REFERENCES accessory_types(id),
	year_first_release smallint NULL,
	is_first_party boolean NOT NULL,
	description text
);

CREATE TABLE accessories_games_compatibility (
	game_id int NOT NULL REFERENCES games(id),
	accessory_id int NOT NULL REFERENCES accessories(id),
	PRIMARY KEY (game_id, accessory_id)
);

CREATE TABLE accessories_platforms_compatibility (
	platform_id int NOT NULL REFERENCES platforms(id),
	accessory_id int NOT NULL REFERENCES accessories(id),
	PRIMARY KEY (platform_id, accessory_id)
);

CREATE TABLE accessory_variations (
	id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	accessory_id int NOT NULL REFERENCES accessories(id),
	description varchar NOT NULL -- char limit 255
);

CREATE TABLE accessory_variations_colors (
	accessory_variation_id int NOT NULL REFERENCES accessory_variations(id),
	color_id int NOT NULL REFERENCES colors(id),
	PRIMARY KEY (accessory_variation_id, color_id)
);

CREATE TABLE characters (
	id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	name varchar NOT NULL, -- char limit 150
	name_disambiguation varchar NULL, -- char limit 150
	from_what varchar NOT NULL -- char limit 255
);

CREATE TABLE characters_in_games (
	character_id int NOT NULL REFERENCES characters(id),
	game_id int NOT NULL REFERENCES games(id),
	PRIMARY KEY (character_id, game_id),
	is_playable boolean NOT NULL,
	playability_extent text NULL
);

CREATE TABLE watchlist_platforms (
	user_id uuid NOT NULL REFERENCES users(id),
	platform_id int NOT NULL REFERENCES platforms(id),
	PRIMARY KEY (user_id, platform_id)
);

CREATE TABLE watchlist_platform_editions (
	user_id uuid NOT NULL REFERENCES users(id),
	platform_edition_id int NOT NULL REFERENCES platform_editions(id),
	PRIMARY KEY (user_id, platform_edition_id)
);

CREATE TABLE watchlist_games (
	user_id uuid NOT NULL REFERENCES users(id),
	game_id int NOT NULL REFERENCES games(id),
	PRIMARY KEY (user_id, game_id)
);

CREATE TABLE watchlist_accessories (
	user_id uuid NOT NULL REFERENCES users(id),
	accessory_id int NOT NULL REFERENCES accessories(id),
	PRIMARY KEY (user_id, accessory_id)
);

CREATE TABLE watchlist_accessory_variations (
	user_id uuid NOT NULL REFERENCES users(id),
	accessory_variation_id int NOT NULL REFERENCES accessory_variations(id),
	PRIMARY KEY (user_id, accessory_variation_id)
);

CREATE TABLE boards (
	id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	name varchar NOT NULL,
	company_id int NOT NULL REFERENCES companies(id),
	board_web_address_base text NULL
);

-- possible future tables for expansion beyond just the video game section

-- CREATE TABLE listing_categories (
-- 	id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
-- 	name varchar NOT NULL,
-- 	description text NULL
-- );

-- CREATE TABLE boards_listing_categories (
-- 	board_id int NOT NULL REFERENCES boards(id),
-- 	listing_category_id int NOT NULL REFERENCES listing_categories(id),
-- 	PRIMARY KEY (board_id, listing_category_id)
-- );

CREATE TABLE listings (
	id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
	board_id int NOT NULL REFERENCES boards(id),
	native_id text NULL,
	url text NOT NULL,
	title text NOT NULL,
	price int NULL,
	body text NULL,
	seller_email text NULL,
	seller_phone text NULL,
	is_scanned boolean DEFAULT false,
	date_posted timestamptz NULL,
	scraped_at timestamptz NOT NULL DEFAULT (now() AT TIME ZONE 'utc')
);

CREATE TABLE listings_platforms (
	listing_id uuid NOT NULL REFERENCES listings(id),
	platform_id int NOT NULL REFERENCES platforms(id),
	PRIMARY KEY (listing_id, platform_id)
);

CREATE TABLE listings_platform_editions (
	listing_id uuid NOT NULL REFERENCES listings(id),
	platform_edition_id int NOT NULL REFERENCES platform_editions(id),
	PRIMARY KEY (listing_id, platform_edition_id)
);

CREATE TABLE listings_games (
	listing_id uuid NOT NULL REFERENCES listings(id),
	game_id int NOT NULL REFERENCES games(id),
	PRIMARY KEY (listing_id, game_id)
);

CREATE TABLE listings_accessories (
	listing_id uuid NOT NULL REFERENCES listings(id),
	accessory_id int NOT NULL REFERENCES accessories(id),
	PRIMARY KEY (listing_id, accessory_id)
);

CREATE TABLE listings_accessory_variations (
	listing_id uuid NOT NULL REFERENCES listings(id),
	accessory_variation_id int NOT NULL REFERENCES accessory_variations(id),
	PRIMARY KEY (listing_id, accessory_variation_id)
);
