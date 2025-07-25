#!/bin/bash
# Development dependencies installer

# Example: install Supabase CLI if missing
if ! command -v supabase >/dev/null; then
  npm install -g supabase
fi
