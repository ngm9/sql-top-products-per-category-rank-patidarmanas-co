BEGIN;

CREATE TABLE dim_categories (
    category_id SERIAL PRIMARY KEY,
    category_name TEXT NOT NULL
);

INSERT INTO dim_categories (category_name) VALUES
    ('Electronics'),
    ('Home & Kitchen'),
    ('Sports & Outdoors'),
    ('Books'),
    ('Clothing'),
    ('Health & Beauty'),
    ('Toys & Games'),
    ('Automotive'),
    ('Groceries'),
    ('Office Supplies'),
    ('Pet Supplies'),
    ('Garden & Outdoor'),
    ('Music & Instruments'),
    ('Baby Products'),
    ('Jewelry'),
    ('Shoes'),
    ('Tools & Hardware'),
    ('Video Games'),
    ('Movies & TV'),
    ('Art & Crafts');

CREATE TABLE dim_products (
    product_id SERIAL PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INT NOT NULL REFERENCES dim_categories(category_id),
    is_discontinued BOOLEAN NOT NULL DEFAULT FALSE
);

INSERT INTO dim_products (product_name, category_id, is_discontinued)
SELECT
    'Product ' || gs AS product_name,
    ((random() * 19)::int + 1) AS category_id,
    (random() < 0.1) AS is_discontinued
FROM generate_series(1, 1000) AS gs;

CREATE TABLE dim_customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name TEXT NOT NULL,
    region TEXT NOT NULL
);

INSERT INTO dim_customers (customer_name, region)
SELECT
    'Customer ' || gs AS customer_name,
    (ARRAY['North', 'South', 'East', 'West', 'Central'])[(random() * 4)::int + 1] AS region
FROM generate_series(1, 5000) AS gs;

CREATE TABLE fact_order_items (
    order_item_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id INT NOT NULL REFERENCES dim_products(product_id),
    customer_id INT NOT NULL REFERENCES dim_customers(customer_id),
    order_date DATE NOT NULL,
    quantity INT NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL
);

-- Timestamps span the last 730 days relative to CURRENT_DATE so that current-year queries return data
INSERT INTO fact_order_items (order_id, product_id, customer_id, order_date, quantity, unit_price)
SELECT
    (random() * 50000 + 1)::bigint AS order_id,
    (random() * 999 + 1)::int AS product_id,
    (random() * 4999 + 1)::int AS customer_id,
    CURRENT_DATE - (random() * 730)::int AS order_date,
    (random() * 9 + 1)::int AS quantity,
    ROUND((random() * 9900 + 100)::numeric, 2) AS unit_price
FROM generate_series(1, 150000) AS gs;

COMMIT;

//test commit 