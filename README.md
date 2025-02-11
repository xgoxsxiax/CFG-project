# Book Rental Database  

# Opis projektu  
Ten projekt przedstawia bazę danych wypożyczalni książek, zawierającą tabele, widoki, procedury składowane, funkcje, triggery i zapytania SQL.  
Celem jest analiza wypożyczeń, zarządzanie karami oraz optymalizacja dostępności książek.  

Autorki: Małgorzata Krause & Martyna Skowronek  

Struktura bazy danych  
Baza danych zawiera następujące tabele:  
- Users – użytkownicy wypożyczalni  
- Categories – kategorie książek  
- Authors – autorzy  
- Books – książki  
- Borrowings – wypożyczenia  
- Penalties – kary  
- BookLocations – lokalizacje książek  
- Reviews – recenzje  


Zarządzanie wypożyczeniami:
- `Borrowings` – rejestracja wypożyczeń  
- Automatyczna aktualizacja liczby dostępnych egzemplarzy

Analiza danych: 
- Wyszukiwanie książek wypożyczonych co najmniej 3 razy  
- Sprawdzanie użytkowników, którzy nie zwrócili książek  
- Widok `BorrowingDetails` łączący dane o użytkownikach, książkach i autorach  

Obsługa kar: 
- Znalezienie książek z nałożonymi karami  
- Aktualizacja statusu płatności  
- Automatyczne czyszczenie kar starszych niż 1 rok (event `ClearOldPenalties`)  

Funkcje i procedury:
- `GetBookCountForUser(user_id)` – zwraca liczbę książek wypożyczonych przez danego użytkownika  
- `AddBorrowing(userId, bookId, borrowDate)` – procedura dodająca wypożyczenie  
- Trigger `AfterReturnBook` – automatycznie zwiększa dostępność książki po jej zwrocie  
