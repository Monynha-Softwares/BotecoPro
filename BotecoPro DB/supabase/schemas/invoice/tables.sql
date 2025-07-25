-- ============================================
-- invoice/tables.sql
-- ============================================

create table invoice.invoice (
    invoice_id serial primary key,
    order_id integer references "order".order_main(order_id),
    invoice_date date default current_date,
    total_amount numeric(10,2),
    tax_amount numeric(10,2),
    food_tax_rate numeric(5,2),
    drink_tax_rate numeric(5,2)
);
