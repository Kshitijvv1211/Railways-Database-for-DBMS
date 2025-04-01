-- Create temporary tables for Indian names
CREATE TEMPORARY TABLE IndianFirstNames (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TEMPORARY TABLE IndianLastNames (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50)
);

-- Insert common Indian first names (100 male and female names)
INSERT INTO IndianFirstNames (name) VALUES
('Aarav'),('Aanya'),('Advait'),('Aditi'),('Akshay'),('Ananya'),('Arjun'),('Avni'),('Dhruv'),('Diya'),
('Ishaan'),('Ishita'),('Kabir'),('Kiara'),('Krish'),('Mira'),('Neel'),('Pari'),('Reyansh'),('Riya'),
('Shaurya'),('Saanvi'),('Vihaan'),('Vanya'),('Yash'),('Zara'),('Aadi'),('Aarushi'),('Abhinav'),('Anika'),
('Arnav'),('Bhavya'),('Chaitanya'),('Daksh'),('Esha'),('Gautam'),('Harsh'),('Ira'),('Jai'),('Kavya'),
('Laksh'),('Mahi'),('Navya'),('Om'),('Prisha'),('Rudra'),('Sara'),('Tanay'),('Urvi'),('Ved'),
('Aahana'),('Aarush'),('Ansh'),('Arya'),('Mihika'),('Kshitij'),('Dev'),('Kashish'),('Farhan'),('Gauri'),
('Hridaan'),('Inaya'),('Jivika'),('Kiaan'),('Lavanya'),('Myra'),('Nakul'),('Ojas'),('Pranav'),('Qasim'),
('Radha'),('Sahil'),('Tara'),('Uday'),('Vivaan'),('Yuvraj'),('Zoya'),('Aarohi'),('Brijesh'),('Charu'),
('Disha'),('Eshaan'),('Falguni'),('Gunjan'),('Hetal'),('Indra'),('Jhanvi'),('Kunal'),('Lila'),('Mohan'),
('Naina'),('Oorja'),('Parth'),('Quasar'),('Rashi'),('Shiv'),('Trisha'),('Udai'),('Vrinda'),('Yashika');

-- Insert common Indian last names (100 names)
INSERT INTO IndianLastNames (name) VALUES
('Patel'),('Sharma'),('Singh'),('Kumar'),('Gupta'),('Verma'),('Joshi'),('Malhotra'),('Reddy'),('Agarwal'),
('Mehta'),('Choudhary'),('Iyer'),('Nair'),('Menon'),('Pillai'),('Bose'),('Banerjee'),('Chatterjee'),('Das'),
('Ghosh'),('Sen'),('Mukherjee'),('Dutta'),('Chakraborty'),('Rao'),('Vasule'),('Rai'),('Yadav'),('Thakur'),
('Trivedi'),('Pathak'),('Mishra'),('Pandey'),('Dubey'),('Tiwari'),('Saxena'),('Sinha'),('Chauhan'),('Rathore'),
('Solanki'),('Parmar'),('Jain'),('Gandhi'),('Shah'),('Desai'),('Kapoor'),('Khanna'),('Ahuja'),('Bajaj'),
('Chawla'),('Dhawan'),('Grover'),('Handa'),('Khanna'),('Saxena'),('Malhotra'),('Nagpal'),('Oberoi'),('Puri'),
('Rastogi'),('Sarin'),('Talwar'),('Uppal'),('Vohra'),('Walia'),('Zutshi'),('Arora'),('Bhasin'),('Chadha'),
('Dewan'),('Gill'),('Hayer'),('Jolly'),('Kohli'),('Lamba'),('Mahajan'),('Nanda'),('Ojha'),('Puri'),
('Rana'),('Sethi'),('Tandon'),('Virk'),('Wahi'),('Xalxo'),('Yadav'),('Zaidi'),('Bedi'),('Chana'),
('Dhami'),('Grewal'),('Hooda'),('Jaggi'),('Khera'),('Loomba'),('Mangat'),('Narula'),('Ohri'),('Pannu');

-- Define base fare amounts for each class with more realistic ranges
SET @base_fare_1A = 300.00; -- First AC base fare
SET @base_fare_2A = 200.00; -- Second AC base fare
SET @base_fare_3A = 150.00; -- Third AC base fare
SET @base_fare_SL = 100.00;  -- Sleeper base fare
SET @base_fare_CC = 120.00; -- Chair Car base fare
SET @base_fare_EC = 250.00; -- Executive Chair Car base fare
SET @base_fare_2S = 80.00;  -- Second Sitting base fare
SET @base_fare_GN = 50.00;  -- General base fare
SET @base_fare_FC = 280.00; -- First Class base fare
SET @default_base_fare = 120.00; -- Default base fare

-- Populate PAX_info table with proper relationships to all other tables
INSERT INTO PAX_info (PNR_no, PAX_Name, PAX_age, PAX_sex, Seat_no, Fare, Passenger_id)
WITH RECURSIVE PNR_Series AS (
    SELECT PNR_no, 1 AS passenger_num
    FROM Ticket_Reservation
    UNION ALL
    SELECT PNR_no, passenger_num + 1
    FROM PNR_Series
    WHERE passenger_num < FLOOR(1 + RAND() * 6)  -- More realistic passenger count (1-6) per PNR
)
SELECT 
    ps.PNR_no,
    CONCAT(fn.name, ' ', ln.name) AS PAX_Name,
    FLOOR(1 + RAND() * 80) AS PAX_age,  -- Random age between 1-80
    CASE 
        WHEN RAND() < 0.5 THEN 'M' 
        ELSE 'F' 
    END AS PAX_sex,
    -- Improved seat number generation based on class
    CASE 
        WHEN c.Class_code = '1A' THEN CONCAT('H', FLOOR(1 + RAND() * 20)) -- 1AC has H1-H20
        WHEN c.Class_code = '2A' THEN CONCAT('A', FLOOR(1 + RAND() * 40)) -- 2AC has A1-A40
        WHEN c.Class_code = '3A' THEN CONCAT('B', FLOOR(1 + RAND() * 60)) -- 3AC has B1-B60
        WHEN c.Class_code = 'SL' THEN CONCAT('S', FLOOR(1 + RAND() * 80)) -- SL has S1-S80
        WHEN c.Class_code = 'CC' THEN CONCAT('C', FLOOR(1 + RAND() * 50)) -- CC has C1-C50
        WHEN c.Class_code = 'EC' THEN CONCAT('E', FLOOR(1 + RAND() * 30)) -- EC has E1-E30
        WHEN c.Class_code = '2S' THEN CONCAT('D', FLOOR(1 + RAND() * 100)) -- 2S has D1-D100
        ELSE CONCAT('X', FLOOR(1 + RAND() * 50)) -- Default for others
    END AS Seat_no,
    -- Improved fare calculation that properly uses your schema
    CASE 
        WHEN tf.Fare IS NOT NULL THEN
            -- Use actual fare from train_fares if available
            tf.Fare + 
            CASE 
                WHEN c.Class_code = '1A' THEN @base_fare_1A
                WHEN c.Class_code = '2A' THEN @base_fare_2A
                WHEN c.Class_code = '3A' THEN @base_fare_3A
                WHEN c.Class_code = 'SL' THEN @base_fare_SL
                WHEN c.Class_code = 'CC' THEN @base_fare_CC
                WHEN c.Class_code = 'EC' THEN @base_fare_EC
                WHEN c.Class_code = '2S' THEN @base_fare_2S
                WHEN c.Class_code = 'GN' THEN @base_fare_GN
                WHEN c.Class_code = 'FC' THEN @base_fare_FC
                ELSE @default_base_fare
            END
        ELSE
            -- Calculate fare based on distance from Ticket_Reservation when exact fare not available
            CASE 
                WHEN c.Class_code = '1A' THEN ROUND(3.5 * (tr.To_Km - tr.From_Km), 2) + @base_fare_1A
                WHEN c.Class_code = '2A' THEN ROUND(2.5 * (tr.To_Km - tr.From_Km), 2) + @base_fare_2A
                WHEN c.Class_code = '3A' THEN ROUND(1.8 * (tr.To_Km - tr.From_Km), 2) + @base_fare_3A
                WHEN c.Class_code = 'SL' THEN ROUND(1.2 * (tr.To_Km - tr.From_Km), 2) + @base_fare_SL
                WHEN c.Class_code = 'CC' THEN ROUND(1.5 * (tr.To_Km - tr.From_Km), 2) + @base_fare_CC
                WHEN c.Class_code = 'EC' THEN ROUND(3.0 * (tr.To_Km - tr.From_Km), 2) + @base_fare_EC
                WHEN c.Class_code = '2S' THEN ROUND(0.8 * (tr.To_Km - tr.From_Km), 2) + @base_fare_2S
                WHEN c.Class_code = 'GN' THEN ROUND(0.5 * (tr.To_Km - tr.From_Km), 2) + @base_fare_GN
                WHEN c.Class_code = 'FC' THEN ROUND(3.2 * (tr.To_Km - tr.From_Km), 2) + @base_fare_FC
                ELSE ROUND(1.0 * (tr.To_Km - tr.From_Km), 2) + @default_base_fare
            END
    END AS Fare,
    CONCAT(ps.PNR_no, '_', 
           CASE ps.passenger_num
               WHEN 1 THEN 'A'
               WHEN 2 THEN 'B'
               WHEN 3 THEN 'C'
               WHEN 4 THEN 'D'
               WHEN 5 THEN 'E'
               WHEN 6 THEN 'F'
           END) AS Passenger_id
FROM PNR_Series ps
JOIN Ticket_Reservation tr ON ps.PNR_no = tr.PNR_no
JOIN Train t ON tr.Train_code = t.Train_code
JOIN Train_class tc ON t.Train_code = tc.Train_code
JOIN Class c ON tc.Class_id = c.Class_id
-- Left join with Train_fare for exact fare if available
LEFT JOIN Train_fare tf ON 
    t.Train_code = tf.Train_code AND 
    c.Class_id = tf.Class_id AND
    tr.From_Km = tf.From_Km AND
    tr.To_Km = tf.To_Km
-- Random name generation
JOIN (SELECT name FROM IndianFirstNames ORDER BY RAND() LIMIT 10000) fn ON 1=1
JOIN (SELECT name FROM IndianLastNames ORDER BY RAND() LIMIT 10000) ln ON 1=1
WHERE ps.passenger_num <= FLOOR(1 + RAND() * 6)  -- Match the recursive limit
ORDER BY ps.PNR_no, ps.passenger_num;

DROP TEMPORARY TABLE IF EXISTS IndianFirstNames;
DROP TEMPORARY TABLE IF EXISTS IndianLastNames;