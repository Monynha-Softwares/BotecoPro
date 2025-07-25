create or replace function catalog.sp_insertcategory(name varchar(100))
returns void
language plpgsql
as $$
begin
INSERT INTO Category (name)
    VALUES (@name);
    RAISE NOTICE 'sp_InsertCategory executed: Category ' + @name + ' inserted.';


end;
$$;


create or replace function catalog.sp_insertsupplier(name varchar(100), email varchar(100), phone varchar(20), notes text)
returns void
language plpgsql
as $$
begin
INSERT INTO Supplier (name, email, phone, notes)
    VALUES (@name, @email, @phone, @notes);
    RAISE NOTICE 'sp_InsertSupplier executed: Supplier ' + @name + ' inserted.';


end;
$$;


create or replace function catalog.sp_insertingredient(name varchar(100), unit_of_measure varchar(20), cost_price decimal(10,2), stock_quantity decimal(10,2), stock_minimum decimal(10,2), reorder_quantity decimal(10,2), last_order_date date, supplier_id int)
returns void
language plpgsql
as $$
begin
INSERT INTO Ingredient (name, unit_of_measure, cost_price, stock_quantity,
                             stock_minimum, reorder_quantity, last_order_date, supplier_id)
    VALUES (@name, @unit_of_measure, @cost_price, @stock_quantity,
            @stock_minimum, @reorder_quantity, @last_order_date, @supplier_id);
    RAISE NOTICE 'sp_InsertIngredient executed: Ingredient ' + @name + ' inserted.';


end;
$$;


create or replace function catalog.sp_insertrecipe(name varchar(100), type varchar(50), base_price decimal(10,2), preparation_time time, category_id int, notes text, recipe_id int, recipe_id as)
returns integer
language plpgsql
as $$
begin
INSERT INTO Recipe (name, type, base_price, preparation_time, category_id, notes)
    VALUES (@name, @type, @base_price, @preparation_time, @category_id, @notes);
    SET @recipe_id = currval(pg_get_serial_sequence('catalog.recipe','recipe_id'));
    RAISE NOTICE 'sp_InsertRecipe executed: Recipe ID ' + CAST(@recipe_id AS VARCHAR(10)) + ' inserted.';


end;
$$;


create or replace function catalog.sp_insertrecipeingredient(recipe_id int, ingredient_id int, quantity decimal(10,2), ingredient_id as, recipe_id as)
returns void
language plpgsql
as $$
begin
INSERT INTO Recipe_Ingredient (recipe_id, ingredient_id, quantity)
    VALUES (@recipe_id, @ingredient_id, @quantity);
    PRINT 'sp_InsertRecipeIngredient executed: Ingredient ' + CAST(@ingredient_id AS VARCHAR(10)) +
          ' added to Recipe ' + CAST(@recipe_id AS VARCHAR(10));


end;
$$;


create or replace function catalog.sp_insertrecipeaddition(recipe_id int, name varchar(100), extra_cost decimal(10,2), addition_id int, addition_id as)
returns integer
language plpgsql
as $$
begin
INSERT INTO Recipe_Addition (recipe_id, name, extra_cost)
    VALUES (@recipe_id, @name, @extra_cost);
    SET @addition_id = currval(pg_get_serial_sequence('catalog.recipe','recipe_id'));
    RAISE NOTICE 'sp_InsertRecipeAddition executed: Addition ID ' + CAST(@addition_id AS VARCHAR(10)) + ' inserted.';


end;
$$;


create or replace function catalog.sp_insertadditioningredient(addition_id int, ingredient_id int, quantity decimal(10,2), ingredient_id as, addition_id as)
returns void
language plpgsql
as $$
begin
INSERT INTO Addition_Ingredient (addition_id, ingredient_id, quantity)
    VALUES (@addition_id, @ingredient_id, @quantity);
    PRINT 'sp_InsertAdditionIngredient executed: Ingredient ' + CAST(@ingredient_id AS VARCHAR(10)) +
          ' added to Addition ' + CAST(@addition_id AS VARCHAR(10));


end;
$$;
