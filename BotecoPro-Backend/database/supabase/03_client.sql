CREATE SCHEMA IF NOT EXISTS client;

CREATE TABLE IF NOT EXISTS client.clients (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id),
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE client.clients ENABLE ROW LEVEL SECURITY;
CREATE POLICY "client owner or admin" ON client.clients
  FOR ALL USING (core.is_admin() OR auth.uid() = user_id);
