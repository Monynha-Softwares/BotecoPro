CREATE SCHEMA IF NOT EXISTS staff;

CREATE TABLE IF NOT EXISTS staff.staff (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id),
  role text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE staff.staff ENABLE ROW LEVEL SECURITY;
CREATE POLICY "staff admin manage" ON staff.staff
  FOR ALL USING (core.is_admin());
