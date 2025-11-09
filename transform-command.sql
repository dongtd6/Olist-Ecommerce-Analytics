-- Replacing the abbreviated geo city to its name
CREATE TABLE dwh_olist.olist_geolocation_clean AS
SELECT 
  geolocation_zip_code_prefix,
  CONCAT(
    UPPER(SUBSTR(ANY_VALUE(geolocation_city), 1, 1)),
    LOWER(SUBSTR(ANY_VALUE(geolocation_city), 2, LENGTH(ANY_VALUE(geolocation_city))))
  ) AS geolocation_city,
  CASE ANY_VALUE(geolocation_state)
      WHEN 'AC' THEN 'Acre'
      WHEN 'AL' THEN 'Alagoas'
      WHEN 'AP' THEN 'Amapa'
      WHEN 'AM' THEN 'Amazonas'
      WHEN 'BA' THEN 'Bahia'
      WHEN 'CE' THEN 'Ceara'
      WHEN 'DF' THEN 'Distrito Federal'
      WHEN 'ES' THEN 'Espirito Santo'
      WHEN 'GO' THEN 'Goias'
      WHEN 'MA' THEN 'Maranhao'
      WHEN 'MT' THEN 'Mato Grosso'
      WHEN 'MS' THEN 'Mato Grosso do Sul'
      WHEN 'MG' THEN 'Minas Gerais'
      WHEN 'PA' THEN 'Para'
      WHEN 'PB' THEN 'Paraiba'
      WHEN 'PR' THEN 'Parana'
      WHEN 'PE' THEN 'Pernambuco'
      WHEN 'PI' THEN 'Piaui'
      WHEN 'RJ' THEN 'Rio de Janeiro'
      WHEN 'RN' THEN 'Rio Grande do Norte'
      WHEN 'RS' THEN 'Rio Grande do Sul'
      WHEN 'RO' THEN 'Rondonia'
      WHEN 'RR' THEN 'Roraima'
      WHEN 'SC' THEN 'Santa Catarina'
      WHEN 'SP' THEN 'Sao Paulo'
      WHEN 'SE' THEN 'Sergipe'
      WHEN 'TO' THEN 'Tocantins'
  END AS geolocation_state
FROM dwh_olist.olist_geolocation_dataset
GROUP BY geolocation_zip_code_prefix;

---------------------------------------------------------------------------

-- Replacing the abbreviated customer_state to its full name
UPDATE dwh_olist.olist_customers_dataset
SET customer_state = 
CASE customer_state
    WHEN 'AC' THEN 'Acre'
    WHEN 'AL' THEN 'Alagoas'
    WHEN 'AP' THEN 'Amapa'
    WHEN 'AM' THEN 'Amazonas'
    WHEN 'BA' THEN 'Bahia'
    WHEN 'CE' THEN 'Ceara'
    WHEN 'DF' THEN 'Distrito Federal'
    WHEN 'ES' THEN 'Espirito Santo'
    WHEN 'GO' THEN 'Goias'
    WHEN 'MA' THEN 'Maranhao'
    WHEN 'MT' THEN 'Mato Grosso'
    WHEN 'MS' THEN 'Mato Grosso do Sul'
    WHEN 'MG' THEN 'Minas Gerais'
    WHEN 'PA' THEN 'Para'
    WHEN 'PB' THEN 'Paraiba'
    WHEN 'PR' THEN 'Parana'
    WHEN 'PE' THEN 'Pernambuco'
    WHEN 'PI' THEN 'Piaui'
    WHEN 'RJ' THEN 'Rio de Janeiro'
    WHEN 'RN' THEN 'Rio Grande do Norte'
    WHEN 'RS' THEN 'Rio Grande do Sul'
    WHEN 'RO' THEN 'Rondonia'
    WHEN 'RR' THEN 'Roraima'
    WHEN 'SC' THEN 'Santa Catarina'
    WHEN 'SP' THEN 'Sao Paulo'
    WHEN 'SE' THEN 'Sergipe'
    WHEN 'TO' THEN 'Tocantins'
END
where true;

-------------------------------------------------

-- Changing the customer_city to a proper case
UPDATE dwh_olist.olist_customers_dataset
SET customer_city =
CONCAT(
    UPPER(SUBSTR(customer_city, 1, 1)),
    LOWER(SUBSTR(customer_city, 2, LENGTH(customer_city)))
)
where true;

-- To capitalize the english product category
UPDATE dwh_olist.product_category_name_translation
SET product_category_name_english =
CONCAT(
    UPPER(SUBSTR(product_category_name_english, 1, 1)),
    LOWER(SUBSTR(product_category_name_english, 2, LENGTH(product_category_name_english)))
)
where true;


--let's capitalize the seller city and rename it to its full form
UPDATE dwh_olist.olist_sellers_dataset
SET seller_city =
CONCAT(
    UPPER(SUBSTR(seller_city, 1, 1)),
    LOWER(SUBSTR(seller_city, 2, LENGTH(seller_city)))
)
where true;
-------------------------------------
-- Renaming it
UPDATE dwh_olist.olist_sellers_dataset
SET seller_state = 
CASE seller_state
    WHEN 'AC' THEN 'Acre'
    WHEN 'AL' THEN 'Alagoas'
    WHEN 'AP' THEN 'Amapa'
    WHEN 'AM' THEN 'Amazonas'
    WHEN 'BA' THEN 'Bahia'
    WHEN 'CE' THEN 'Ceara'
    WHEN 'DF' THEN 'Distrito Federal'
    WHEN 'ES' THEN 'Espirito Santo'
    WHEN 'GO' THEN 'Goias'
    WHEN 'MA' THEN 'Maranhao'
    WHEN 'MT' THEN 'Mato Grosso'
    WHEN 'MS' THEN 'Mato Grosso do Sul'
    WHEN 'MG' THEN 'Minas Gerais'
    WHEN 'PA' THEN 'Para'
    WHEN 'PB' THEN 'Paraiba'
    WHEN 'PR' THEN 'Parana'
    WHEN 'PE' THEN 'Pernambuco'
    WHEN 'PI' THEN 'Piaui'
    WHEN 'RJ' THEN 'Rio de Janeiro'
    WHEN 'RN' THEN 'Rio Grande do Norte'
    WHEN 'RS' THEN 'Rio Grande do Sul'
    WHEN 'RO' THEN 'Rondonia'
    WHEN 'RR' THEN 'Roraima'
    WHEN 'SC' THEN 'Santa Catarina'
    WHEN 'SP' THEN 'Sao Paulo'
    WHEN 'SE' THEN 'Sergipe'
    WHEN 'TO' THEN 'Tocantins'
END
where true;
