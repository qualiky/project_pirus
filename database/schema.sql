DROP DATABASE project_pirus;

CREATE DATABASE project_pirus;

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE OR REPLACE FUNCTION generate_ulid()
    RETURNS TEXT
    LANGUAGE plpgsql
AS $$
DECLARE
    unix_milliseconds BIGINT;
    ulid_string TEXT;
BEGIN
    -- Get the current timestamp in milliseconds since Unix epoch.
    unix_milliseconds := (EXTRACT(EPOCH FROM NOW()) * 1000)::BIGINT;
    -- Generate a random 80-bit value.
    ulid_string := encode(gen_random_bytes(10), 'hex');
    -- Combine the timestamp and randomness to create the ULID.
    ulid_string := LPAD(ULID_string, 16, '0') || LPAD(unix_milliseconds::TEXT, 13, '0');
    RETURN ulid_string;
END;
$$;


CREATE TABLE IF NOT EXISTS Credentials(
    credentialId text primary key not null unique default generate_ulid(),
    username text not null unique,
    password text not null,
    resetPasswordPrompt bool default false not null,
    previousLoginAttemptFlagged bool default false not null,
    isEmailVerified bool default false not null
);

CREATE TABLE IF NOT EXISTS SessionRecord(
    sessionRecordId text primary key not null unique default generate_ulid(),
    username text not null,
    loginIpAddress text not null,
    loginUserAgent text not null,
    loginTimeStamp timestamptz not null,
    loginBrowserAppVersion text not null,
    isLoginStatusRevoked bool not null default true,
    revokingAdminId text,
    revokeReason text,
    revokeTimeStamp timestamptz,
    hasLoggedOut bool not null default false,
    logoutTimeStamp timestamptz
);

CREATE TABLE IF NOT EXISTS CredentialManagementHistory(
    credentialManagementHistoryId text primary key not null unique default generate_ulid(),
    username text not null,
    previousPassword text not null,
    credentialActionSessionRecordId text not null,
    credentialActionUserId text not null,
    credentialActionTimeStamp timestamptz not null,
    credentialActionEmailVerified bool default false,
    credentialActionAdminApproved bool default false
);