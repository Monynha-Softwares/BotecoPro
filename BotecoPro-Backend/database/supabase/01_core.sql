CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS staff;

-- Helper function to check if current user is an admin
CREATE OR REPLACE FUNCTION core.is_admin()
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM staff.staff s
    WHERE s.user_id = auth.uid()
      AND s.role = 'admin'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;
