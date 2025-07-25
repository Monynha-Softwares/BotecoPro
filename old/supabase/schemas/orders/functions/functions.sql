create or replace function orders.sp_createorder(table_id integer, employee_id integer, client_id integer default NULL, notes nvarchar, order_id integer, order_id as)
returns integer
language plpgsql
as $$
begin
INSERT INTO Order_Main (table_id, employee_id, client_id, order_datetime, status, notes)
    VALUES (@table_id, @employee_id, @client_id, GETDATE(), 'Pending', @notes);
    SET @order_id = lastval();
    PRINT 'sp_CreateOrder executed successfully. New Order ID: ' + CAST(@order_id AS VARCHAR(10));
end;
$$;


create or replace function orders.sp_addorderitem(order_id integer, recipe_id integer, quantity integer, base_price numeric(10,2), order_id and, quantity where, order_id and, order_id as, recipe_id as, order_id as, recipe_id as)
returns void
language plpgsql
as $$
begin
IF EXISTS (SELECT 1 FROM Order_Item WHERE order_id = @order_id AND recipe_id = @recipe_id)
    
        UPDATE Order_Item
        SET quantity = quantity + @quantity
        WHERE order_id = @order_id AND recipe_id = @recipe_id;
        PRINT 'sp_AddOrderItem: Quantity updated for Order ' + CAST(@order_id AS VARCHAR(10)) + ', Recipe ' + CAST(@recipe_id AS VARCHAR(10));
    
    ELSE
    
        INSERT INTO Order_Item (order_id, recipe_id, quantity, base_price)
        VALUES (@order_id, @recipe_id, @quantity, @base_price);
        PRINT 'sp_AddOrderItem: New item added for Order ' + CAST(@order_id AS VARCHAR(10)) + ', Recipe ' + CAST(@recipe_id AS VARCHAR(10));
end;
$$;


create or replace function orders.sp_addorderaddition(order_id integer, recipe_id integer, addition_id integer, quantity integer, addition_id as, order_id as)
returns void
language plpgsql
as $$
begin
INSERT INTO Order_Item_Addition (order_id, recipe_id, addition_id, quantity)
    VALUES (@order_id, @recipe_id, @addition_id, @quantity);
    PRINT 'sp_AddOrderAddition: Addition ' + CAST(@addition_id AS VARCHAR(10)) + ' added to Order ' + CAST(@order_id AS VARCHAR(10));
end;
$$;


create or replace function orders.sp_confirmorder(order_id integer, ing_id integer, qty numeric(10,2), qty where, qty where, order_id as)
returns void
language plpgsql
as $$
begin
UPDATE Order_Main SET status = 'Confirmed' WHERE order_id = @order_id;

    -- Decrement stock for each recipe ingredient
    DECLARE @ing_id INT, @qty DECIMAL(10,2);
    DECLARE ingred_cursor CURSOR FOR
        SELECT ri.ingredient_id, ri.quantity * oi.quantity
        FROM Order_Item oi
        JOIN Recipe_Ingredient ri ON oi.recipe_id = ri.recipe_id
        WHERE oi.order_id = @order_id;
    OPEN ingred_cursor;
    FETCH NEXT FROM ingred_cursor INTO @ing_id, @qty;
    WHILE @@FETCH_STATUS = 0
    
        UPDATE Ingredient
        SET stock_quantity = stock_quantity - @qty
        WHERE ingredient_id = @ing_id;
        FETCH NEXT FROM ingred_cursor INTO @ing_id, @qty;
    ;
    CLOSE ingred_cursor;
    DEALLOCATE ingred_cursor;

    -- Decrement stock for addition ingredients
    DECLARE add_cursor CURSOR FOR
        SELECT ai.ingredient_id, ai.quantity * oia.quantity
        FROM Order_Item_Addition oia
        JOIN Addition_Ingredient ai ON oia.addition_id = ai.addition_id
        WHERE oia.order_id = @order_id;
    OPEN add_cursor;
    FETCH NEXT FROM add_cursor INTO @ing_id, @qty;
    WHILE @@FETCH_STATUS = 0
    
        UPDATE Ingredient
        SET stock_quantity = stock_quantity - @qty
        WHERE ingredient_id = @ing_id;
        FETCH NEXT FROM add_cursor INTO @ing_id, @qty;
    ;
    CLOSE add_cursor;
    DEALLOCATE add_cursor;

    RAISE NOTICE 'sp_ConfirmOrder executed: Order ' + CAST(@order_id AS VARCHAR(10)) + ' confirmed and stock updated.';
end;
$$;


create or replace function orders.sp_cancelorder(order_id integer, restore_stock bit default 0, temp_id integer, temp_qty numeric(10,2), temp_qty where, temp_qty where, order_id as, order_id as)
returns void
language plpgsql
as $$
begin
-- Optionally restore stock before canceling
    IF @restore_stock = 1
    
        DECLARE @temp_id INT, @temp_qty DECIMAL(10,2);
        DECLARE restore_ing CURSOR FOR
            SELECT ri.ingredient_id, ri.quantity * oi.quantity
            FROM Order_Item oi
            JOIN Recipe_Ingredient ri ON oi.recipe_id = ri.recipe_id
            WHERE oi.order_id = @order_id;
        OPEN restore_ing;
        FETCH NEXT FROM restore_ing INTO @temp_id, @temp_qty;
        WHILE @@FETCH_STATUS = 0
        
            UPDATE Ingredient
            SET stock_quantity = stock_quantity + @temp_qty
            WHERE ingredient_id = @temp_id;
            FETCH NEXT FROM restore_ing INTO @temp_id, @temp_qty;
        ;
        CLOSE restore_ing;
        DEALLOCATE restore_ing;

        DECLARE restore_add CURSOR FOR
            SELECT ai.ingredient_id, ai.quantity * oia.quantity
            FROM Order_Item_Addition oia
            JOIN Addition_Ingredient ai ON oia.addition_id = ai.addition_id
            WHERE oia.order_id = @order_id;
        OPEN restore_add;
        FETCH NEXT FROM restore_add INTO @temp_id, @temp_qty;
        WHILE @@FETCH_STATUS = 0
        
            UPDATE Ingredient
            SET stock_quantity = stock_quantity + @temp_qty
            WHERE ingredient_id = @temp_id;
            FETCH NEXT FROM restore_add INTO @temp_id, @temp_qty;
        ;
        CLOSE restore_add;
        DEALLOCATE restore_add;

        PRINT 'sp_CancelOrder: Stock restored for Order ' + CAST(@order_id AS VARCHAR(10));
    

    UPDATE Order_Main SET status = 'Canceled' WHERE order_id = @order_id;
    RAISE NOTICE 'sp_CancelOrder executed: Order ' + CAST(@order_id AS VARCHAR(10)) + ' canceled.';
end;
$$;


create or replace function orders.sp_generateinvoice(order_id integer, food_tax_rate numeric(5,2), drink_tax_rate numeric(5,2), invoice_id integer, total_food numeric(10,2) default 0, total_drink numeric(10,2) default 0, tax_amount numeric(10,2), total_amount numeric(10,2), order_id and, order_id and, invoice_id as)
returns integer
language plpgsql
as $$
begin
DECLARE @total_food DECIMAL(10,2) = 0;
    DECLARE @total_drink DECIMAL(10,2) = 0;
    DECLARE @tax_amount DECIMAL(10,2);
    DECLARE @total_amount DECIMAL(10,2);

    -- Total base price of recipes, grouped by category
    SELECT
        @total_food = SUM(oi.quantity * oi.base_price)
    FROM Order_Item oi
    JOIN Recipe r ON oi.recipe_id = r.recipe_id
    JOIN Category c ON r.category_id = c.category_id
    WHERE oi.order_id = @order_id AND c.name = 'Food';

    SELECT
        @total_drink = SUM(oi.quantity * oi.base_price)
    FROM Order_Item oi
    JOIN Recipe r ON oi.recipe_id = r.recipe_id
    JOIN Category c ON r.category_id = c.category_id
    WHERE oi.order_id = @order_id AND c.name = 'Drink';

    SET @tax_amount = (@total_food * @food_tax_rate / 100) + (@total_drink * @drink_tax_rate / 100);
    SET @total_amount = @total_food + @total_drink + @tax_amount;

    INSERT INTO Invoice (order_id, invoice_date, total_amount, tax_amount, food_tax_rate, drink_tax_rate)
    VALUES (@order_id, GETDATE(), @total_amount, @tax_amount, @food_tax_rate, @drink_tax_rate);

    SET @invoice_id = lastval();
    RAISE NOTICE 'sp_GenerateInvoice executed: Invoice ' + CAST(@invoice_id AS VARCHAR(10)) + ' created.';
end;
$$;
