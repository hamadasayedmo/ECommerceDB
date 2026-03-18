
BACKUP DATABASE ECommerceDB
TO DISK = 'C:\Users\Etech\Desktop\ECommerceDB\08_Full Backup Database\ECommerceDB.bak'
WITH FORMAT;

-- If you face permission issues, run this command in CMD as admin:
-- icacls "C:\Users\Etech\Desktop\ECommerceDB\08_Full Backup Database" /grant "NT Service\MSSQLSERVER":(OI)(CI)F