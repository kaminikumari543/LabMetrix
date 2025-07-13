USE Apple_Itunes;
GO

---ALTER TABLE [dbo].[playlist_track]
---ADD FOREIGN KEY ([playlist_id]) REFERENCES [dbo].[playlist]([playlist_id]);
---ALTER TABLE [dbo].album
---ADD FOREIGN KEY ([artist_id]) REFERENCES [dbo].[artist]([artist_id]);


SELECT s
    customer.country AS country,
    ROUND(SUM(invoice.total), 2) AS total_sales
FROM invoice
inner join customer on invoice.customer_id=customer.customer_id
GROUP BY customer.country
ORDER BY total_sales DESC;




--Montly sales trend
SELECT 
    FORMAT(invoice_date, 'yyyy-MM') AS month,
    ROUND(SUM(total), 2) AS monthly_sales
FROM invoice
GROUP BY FORMAT(invoice_date, 'yyyy-MM')
ORDER BY month;

--- Most popular music genres by sales
SELECT 
    g.name AS genre,
    COUNT(ii.invoice_line_id) AS track_sold
FROM invoice_line ii
INNER JOIN track t ON ii.track_id = t.track_id
INNER JOIN genre g ON t.genre_id = g.genre_id
GROUP BY g.name
ORDER BY track_sold DESC;

---Top artist by sales revenue
SELECT TOP 10
    ar.name AS artist,
   ROUND(SUM(ii.unit_price * ii.quantity), 2) AS total_revenue
FROM invoice_line AS ii
INNER JOIN track AS t ON ii.track_id = t.track_id
INNER JOIN album AS al ON t.album_id = al.album_id
INNER JOIN artist AS ar ON al.artist_id = ar.artist_id
GROUP BY ar.name
ORDER BY total_revenue DESC;

---Number of customers by country
SELECT 
    country,
    COUNT(*) AS customer_count
FROM customer
GROUP BY country
ORDER BY customer_count DESC;

---Average spending per invoice by customer
SELECT TOP 10
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    ROUND(AVG (i.total), 2) AS avg_invoice_total
FROM customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY avg_invoice_total DESC;

--- Customer Engagement — Number of Purchases per Customer
SELECT 
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    COUNT(i.invoice_id) AS total_purchases,
    ROUND(SUM(i.total), 2) AS total_spent
FROM customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

--- Playlist Popularity — Number of Tracks in Each Playlist
   --SELECT 
    p.name AS playlist_name,
    COUNT(pt.track_id) AS number_of_tracks
FROM playlist p
INNER JOIN playlist_track pt ON p.playlist_id = pt.playlist_id
GROUP BY p.name
ORDER BY number_of_tracks DESC;

---Top Tracks by Revenue
SELECT TOP 10
    t.name AS track_name,
    ROUND(SUM(ii.unit_price * ii.quantity), 2) AS revenue
FROM invoice_line ii
INNER JOIN track t ON ii.track_id = t.track_id
GROUP BY t.name
ORDER BY revenue DESC;

-----1. Customer Ranking and Lifetime Value (Window Function + Subquery)
----Goal: Rank customers by total amount spent
SELECT 
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    ROUND(SUM(i.total), 2) AS total_spent,
    RANK() OVER (ORDER BY SUM(i.total) DESC) AS customer_rank
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY customer_rank;


----2. Most Popular Playlist with Most Unique Tracks (CTE + Aggregation Subquery)
WITH PlaylistTrackCounts AS (
    SELECT 
        pt.playlist_id,
        COUNT(DISTINCT pt.track_id) AS unique_tracks
    FROM playlist_track pt
    GROUP BY pt.playlist_id
)
SELECT 
    p.name AS playlist_name,
    ptc.unique_tracks
FROM PlaylistTrackCounts ptc
JOIN playlist p ON p.playlist_id = ptc.playlist_id
ORDER BY ptc.unique_tracks DESC;

---3 Top Tracks by Artist Revenue Using Subquery
SELECT 
    ar.name AS artist_name,
    ranked_tracks.name AS track_name,
    total_revenue
FROM (
    SELECT 
        t.track_id,
        t.name,
        al.artist_id,
        SUM(ii.unit_price * ii.quantity) AS total_revenue,
        RANK() OVER (PARTITION BY al.artist_id ORDER BY SUM(ii.unit_price * ii.quantity) DESC) AS track_rank
    FROM invoice_line ii
    JOIN track t ON ii.track_id = t.track_id
    JOIN album al ON t.album_id = al.album_id
    GROUP BY t.track_id, t.name, al.artist_id
) AS ranked_tracks 
JOIN artist ar ON ranked_tracks.artist_id = ar.artist_id
WHERE track_rank = 1;

---

































