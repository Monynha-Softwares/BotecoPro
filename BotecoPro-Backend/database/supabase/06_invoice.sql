CREATE SCHEMA IF NOT EXISTS invoice;

CREATE TABLE IF NOT EXISTS invoice.invoices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL REFERENCES "order".orders(id),
  total numeric NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE invoice.invoices ENABLE ROW LEVEL SECURITY;
CREATE POLICY "invoice admin" ON invoice.invoices
  FOR ALL USING (core.is_admin());
