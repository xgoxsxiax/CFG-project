-- Malgorzata Krause & Martyna Skowronek

use bookrental;
SELECT * FROM Users;
SELECT * FROM Categories;
SELECT * FROM Authors;
SELECT * FROM Books;
SELECT * FROM Borrowings;
SELECT * FROM Penalties;
SELECT * FROM BookLocations;
SELECT * FROM Reviews;


-- Check which books have associated penalties
SELECT b.book_id, b.title AS title, bo.user_id AS who, bo.borrowing_id, penalty_amount, penalty_time
FROM Books b
LEFT JOIN Borrowings bo ON bo.book_id = b.book_id -- Join books with borrowings
LEFT JOIN Penalties p ON Bo.borrowing_id = p.borrowing_id -- Join borrowings with penalties
WHERE penalty_time>0
AND p.paid = 'NO';



-- Update the 'paid' status of a specific penalty to 'YES', indicating that this penalty has been settled.
UPDATE Penalties
set paid = 'YES'
WHERE borrowing_id = 3;

SELECT * FROM Penalties;

-- Replace the penalty record with penalty_id = 1 with the provided borrowing_id, penalty amount, penalty time, and 'paid' status ('YES').
REPLACE INTO Penalties (borrowing_id, penalty_amount, penalty_time, paid) values
(11, 4.50, 9, 'YES');
SELECT * FROM Penalties
WHERE borrowing_id = 11;




-- -- Retrieve the borrowing date, publication year, and title of borrowed books using INNER JOIN
SELECT title, publication_year , borrowing_date
FROM Books
INNER JOIN borrowings ON borrowings.book_id = books.book_id
ORDER BY borrowings.borrowing_date;



-- Retrieve the borrowing date, publication year, and title of borrowed books, if any, using LEFT JOIN
SELECT users.user_id,first_name,last_name,email,phone,book_id,borrowing_date,return_date
FROM users
LEFT JOIN borrowings
ON users.user_id = borrowings.user_id;



-- Create a function to count the number of borrowings for a specific user
DELIMITER $$
CREATE FUNCTION GetBookCountForUser(user_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE book_count INT; -- Declare a variable to store the count

    -- Count the number of borrowings for the given user
    SELECT COUNT(*) INTO book_count
    FROM borrowings
    WHERE borrowings.user_id = user_id;

    RETURN book_count;
END $$

DELIMITER ;

SELECT GetBookCountForUser(1);

-- Show the number of books borrowed by each user
SELECT 
    first_name, 
    last_name, 
    GetBookCountForUser(user_id) AS borrowed_books
FROM users;



-- Find books that have been borrowed at least 3 times - using GROUP BY and HAVING clauses to extract and analyze data from database
SELECT title
FROM books
WHERE book_id IN (
    SELECT book_id
    FROM borrowings
    GROUP BY book_id
    HAVING COUNT(borrowing_id) >= 3
);



INSERT INTO Books (title, author_id, publication_year, category_id, quantity_available) VALUES
('The Witcher 2', 1, 2000, 1, 7),
('What is a Crime?', 2, 1969, 2, 4),
('Sun', 3, 1963, 4, 3);




-- Find users who have not returned borrowed books
SELECT * FROM Users
WHERE user_id IN
  (SELECT user_id 
  FROM borrowings 
  WHERE return_date IS NULL);




-- Create a STORED PROCEDURE to add a borrowing record
DELIMITER $$

CREATE PROCEDURE AddBorrowing(
    IN userId INT,
    IN bookId INT,
    IN borrowDate DATE
)
BEGIN
    -- Check if the book is available
    IF (SELECT quantity_available FROM Books WHERE book_id = bookId) > 0 THEN
        -- Add a new borrowing record
        INSERT INTO Borrowings (user_id, book_id, borrowing_date, return_date)
        VALUES (userId, bookId, borrowDate, NULL); 

        -- Decrease the number of available copies
        UPDATE Books
        SET quantity_available = quantity_available - 1
        WHERE book_id = bookId;

        SELECT 'Borrowing added successfully!';
    ELSE
        SELECT 'No copies available!';
    END IF;
END $$

DELIMITER ;


-- Example usage of the stored procedure
CALL AddBorrowing(1, 3, '2024-12-30'); # User 1 borrowed book 3 2024-12-30
CALL AddBorrowing(5, 3, '2024-12-30');
CALL AddBorrowing(6, 3, '2024-12-30');
CALL AddBorrowing(9, 3, '2024-12-30');
CALL AddBorrowing(12, 3, '2024-12-30');
CALL AddBorrowing(12, 3, '2024-12-30');
CALL AddBorrowing(17, 15, '2024-12-31');
-- Verify the added borrowings
SELECT * FROM borrowings 





-- Create a trigger to update book availability after a return
DELIMITER $$

CREATE TRIGGER AfterReturnBook
AFTER UPDATE ON Borrowings
FOR EACH ROW
BEGIN
    -- Check if the return_date was updated
    IF NEW.return_date IS NOT NULL THEN
         -- Increase the number of available copies
        UPDATE Books
        SET quantity_available = quantity_available + 1
        WHERE book_id = NEW.book_id;
    END IF;
END $$

DELIMITER ;



-- Example: Update return_date for a borrowing to test the trigger
UPDATE Borrowings
SET return_date = '2025-01-02'
WHERE borrowing_id = 44;

SELECT * FROM borrowings; -- Verify 

-- Verify the trigger's effect on the Books table
SELECT * FROM Books WHERE book_id = 15;




-- Create a view combining data from multiple tables for analysis
DROP VIEW IF EXISTS BorrowingDetails;

CREATE VIEW BorrowingDetails AS
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    b.title AS book_title,
    a.first_name AS author_first_name,
    a.last_name AS author_last_name,
    bo.borrowing_date,
    bo.return_date
FROM 
    Users u
JOIN Borrowings bo ON u.user_id = bo.user_id
JOIN Books b ON bo.book_id = b.book_id
JOIN Authors a ON b.author_id = a.author_id;



-- Query the view to find borrowing details for a specific author
SELECT * FROM BorrowingDetails
WHERE author_last_name = 'Lem';







-- Create an event to clear penalties older than a year
DELIMITER $$

CREATE EVENT IF NOT EXISTS ClearOldPenalties
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DELETE FROM Penalties
    WHERE penalty_time < (CURDATE() - INTERVAL 1 YEAR); -- Remove penalties older than a year
END $$

DELIMITER ;
-- Enable the event scheduler
SET GLOBAL event_scheduler = ON;



-- Find authors who have written more than one book that we have in our library - extracting data from DB for analysis with group by and having
SELECT 
    a.author_id, 
    a.first_name AS author_first_name, 
    a.last_name AS author_last_name, 
    COUNT(b.book_id) AS number_of_books
FROM Authors a
JOIN Books b ON a.author_id = b.author_id -- Join authors with books
GROUP BY  a.author_id , a.first_name, a.last_name -- Group by author details
HAVING COUNT(b.book_id) > 1 -- Only include authors with more than one book
ORDER BY number_of_books DESC; -- Order by the number of books in descending order
