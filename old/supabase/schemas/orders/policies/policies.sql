
-- -- Policy: Only allow waiters to insert orders
-- create policy "Allow insert by waiters"
-- on orders.order_main
-- for insert
-- using (
--   auth.jwt() ->> 'role' = 'waiter'
-- );

-- -- Policy: Only allow access to own orders
-- create policy "Allow select by creator"
-- on orders.order_main
-- for select
-- using (
--   employee_id = (auth.jwt() ->> 'employee_id')::integer
-- );
