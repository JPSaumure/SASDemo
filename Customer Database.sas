/* Create a customer identification table */

data customers;
    infile datalines delimiter=',';
    length FirstName $ 20 LastName $ 20 Address $ 50 City $ 25;
    input CustomerID FirstName $ LastName $ Address $ City $;
    datalines;
1001,John,Smith,123 Main St,Anytown
1002,Sarah,Johnson,456 Oak Ave,Someville
1003,Michael,Brown,789 Pine Rd,Othertown
1004,Jennifer,Wilson,101 Maple Dr,Newcity
1005,Robert,Garcia,202 Elm Blvd,Oldtown
1006,Lisa,Martinez,303 Cedar St,Bigcity
1007,David,Anderson,404 Birch Ln,Smallville
1008,Michelle,Thomas,505 Walnut Ave,Metropolis
1009,James,Rodriguez,606 Cherry Dr,Gotham
1010,Patricia,Lewis,707 Spruce Rd,Atlantis
;
run;

proc casutil;
	load data=work.customers outcaslib="CASUSER"
	casout="customers";
run;

/* Create a product purchases table */

data purchases;
    infile datalines delimiter=',';
    format PurchaseDate mmddyy10.;
    input CustomerID ProductID PurchaseDate : mmddyy10. Quantity Amount;
    datalines;
1001,5001,01/15/2023,2,59.98
1002,5003,01/17/2023,1,125.00
1003,5002,01/18/2023,3,44.97
1001,5005,01/20/2023,1,199.99
1004,5001,01/22/2023,1,29.99
1005,5004,01/25/2023,2,39.98
1006,5002,01/27/2023,1,14.99
1007,5003,01/28/2023,1,125.00
1002,5001,01/30/2023,2,59.98
1008,5005,02/01/2023,1,199.99
1009,5004,02/03/2023,3,59.97
1010,5003,02/05/2023,1,125.00
1003,5001,02/07/2023,1,29.99
1005,5002,02/10/2023,2,29.98
1007,5005,02/12/2023,1,199.99
;
run;

proc casutil;
	load data=work.purchases outcaslib="CASUSER"
	casout="purchases";
run;

/* Create a products table and loads it to my CAS library*/

data products;
    infile datalines delimiter=',';
    length ProductName $ 30 Category $ 20;
    input ProductID ProductName $ Category $ UnitPrice InStock;
    datalines;
5001,Basic T-Shirt,Clothing,29.99,150
5002,Coffee Mug,Home,14.99,200
5003,Wireless Headphones,Electronics,125.00,75
5004,Yoga Mat,Fitness,19.99,100
5005,Smart Speaker,Electronics,199.99,50
;
run;

proc casutil;
	load data=work.products outcaslib="CASUSER"
	casout="products";
run;

/* Create a customer contact preferences table */

data contact_prefs;
    infile datalines delimiter=',';
    length PreferredContact $ 15;
    input CustomerID PreferredContact $ EmailOptIn SmsOptIn MailOptIn;
    datalines;
1001,Email,1,0,1
1002,SMS,1,1,0
1003,Mail,0,0,1
1004,Email,1,1,1
1005,SMS,0,1,0
1006,Email,1,0,0
1007,Mail,0,0,1
1008,SMS,1,1,0
1009,Email,1,0,1
1010,Mail,0,0,1
;
run;

proc casutil;
	load data=work.contact_prefs outcaslib="CASUSER"
	casout="contact_prefs";
run;

/* Create a customer demographics table */

data demographics;
    infile datalines delimiter=',';
    format JoinDate mmddyy10.;
    length AgeGroup $ 10 Income $ 15 Occupation $ 25;
    input CustomerID AgeGroup $ Income $ Occupation $ JoinDate : mmddyy10.;
    datalines;
1001,35-44,75K-100K,Engineer,05/12/2020
1002,25-34,50K-75K,Teacher,07/23/2020
1003,45-54,100K+,Doctor,08/05/2020
1004,18-24,25K-50K,Student,09/15/2020
1005,55-64,75K-100K,Manager,10/30/2020
1006,35-44,50K-75K,Accountant,11/14/2020
1007,65+,25K-50K,Retired,12/01/2020
1008,25-34,75K-100K,Programmer,01/17/2021
1009,45-54,100K+,Executive,02/28/2021
1010,55-64,50K-75K,Consultant,03/15/2021
;
run;

proc casutil;
	load data=work.demographics outcaslib="CASUSER"
	casout="demographics";
run;