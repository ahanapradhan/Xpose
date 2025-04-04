# Text2SQL on TPCH Benchmark Queries using GPT-4o (04-04-2025):

| QID  | GPT Output                          | Remarks on Diff                                |
|------|-------------------------------------|-------------------------------------------------|
| Q2 |   https://chatgpt.com/share/67ef8147-b3d4-8005-9bcd-21444bf63e26                                  | Result is different.    https://www.diffchecker.com/zWuU3Apc/                                            |
|Q7|https://chatgpt.com/share/67efa0ba-6aa0-8005-9720-4b33d7722529|On original TPCH schema, text-to-sql produces the benchmark query. Now, on the synonymized schema, it includes spurious partupp table. It introduced 100 in the projection formula. Synonym mappings: region --> continent, nation --> country, orders --> bids, lineitem --> product, part --> item, partsupp --> itemven, supplier --> vendor, customer --> client.|
|Q8|https://chatgpt.com/share/67efa580-0874-8005-98cd-f18c5f4a0e16|On original TPCH schema, text-to-sql produces the benchmark query. Now, on the synonymized schema, it misses customer table, and one instance of nation table. It spuriously uses partsupp table. It uses l_shipdate for group by. Synonym mappings: region --> continent, nation --> country, orders --> bids, lineitem --> product, part --> item, partsupp --> itemven, supplier --> vendor, customer --> client.|
|Q11|https://chatgpt.com/share/67ef97b9-f440-8005-9a8d-d2150dc7f6c4|Tables missing in the inner query.|
|Q12|https://chatgpt.com/share/67ef95e4-900c-8005-a7ca-7f914246f78a|Query gives empty result. Because the constants are not correct. They are not specified in the text. This cannot be fixed only using the result and the text description. URGENT and HIGH constants can be corrected if the LLM is provided with few sample data. But the constants on l_shipmode predicate cannot be derived unless given.| 
|Q13|https://chatgpt.com/share/67ef9487-7968-8005-93e8-5077b4d7eb5e|missing projection group by in both levels.|
|Q16|https://chatgpt.com/share/67ef90f2-07d8-8005-8d08-7ed6beed5a2f|projection, group by missing.|
|Q17|https://chatgpt.com/share/67ef8e4a-a63c-8005-8d57-c719d4abbb4d|2 instances of part. Extra filters inside.|
|Q18|https://chatgpt.com/share/67ef8c4d-1968-8005-a5ae-cfb3cb8d4b41|Missing lineitem table. Incorrect inner aggregation. Semijoin on different attribute. Group by incorrect.|
|Q20 |https://chatgpt.com/share/67ef644d-131c-8005-8a3d-ef14d8bb48a4|Orders table is spurious. o_orderdate is in filter instead of l_shipdate.|
|Q21|https://chatgpt.com/share/67ef8b7d-4dec-8005-bdde-5e0573bd6e19|Missing projection and group by.|
| Q22  | https://chatgpt.com/c/677fa7f2-3c2c-8005-88a7-e01896ed6c52 |Single instance of customer, projection is missing|


------------------------------------------------------------------------------------------------------------------------------------------------


# Setting up the XRE Code:
-------------------------------------------------------------------------------------------------------------------------------------------------

# Setting Up the Database
## PostgreSQL Installation  

Follow the link https://www.postgresql.org/download/ to download and install the suitable distribution of the database for your platform. 

## Loading TPCH Data  

### Obtaining DBGEN
1. Open the TPC webpage following the link: https://www.tpc.org/tpc_documents_current_versions/current_specifications5.asp  
2. In the `Active Benchmarks` table (first table), follow the link of `Download TPC-H_Tools_v3.0.1.zip`, it'll redirect to `TPC-H Tools Download
` page   
3. Give your details and click `download`, it'll email you the download link. Use the link to download the zip file.  
4. Unzip the zip file, and it must have the `dbgen` folder among the extracted contents  

### Prepare TPCH data on PostgreSQL using DBGEN
1. Download the code `tpch-pgsql` from the link: [https://github.com/Data-Science-Platform/tpch-pgsql/tree/master](https://github.com/ahanapradhan/tpch-pgsql).  
2. Follow the `tpch-pgsql` project Readme to prepare and load the data.  
3. (In case the above command gives error as `malloc.h` not found, showing the filenames, go inside dbgen folder, open the file and replace `malloc.h` with `stdlib.h`)

## Sample TPCH Data  
TPCH 100MB (sf=0.1) data is provided at: https://github.com/ahanapradhan/UnionExtraction/blob/master/mysite/unmasque/test/experiments/data/tpch_tiny.zip  
The load.sql file in the folder needs to be updated with the corresponding location of the data .csv files.

## Loading TPCH Data using DuckDB
https://duckdb.org/docs/extensions/tpch.html

# Setting up IDE
A developement environment for python project is required next. Here is the link to PyCharm Community Edition: https://www.jetbrains.com/pycharm/download/  (Any other IDE is also fine)

### Requirements
* Python 3.8.0 or above
* `django==4.2.4`
* `sympy==1.4`
* `psycopg2==2.9.3`
* `numpy==1.22.4`

# Setting Up the Code

The code is organized into the following directories:  

## mysite

The `mysite` directory contains the main project code.

### unmasque

Inside `unmasque`, you'll find the following subdirectories:

#### src

The `src` directory contains code that has been refactored from the original codebase developed in various theses, as well as newly written logic, often designed to simplify existing code. This may include enhancements or entirely new functionality.

#### test

The `test` directory houses unit test cases for each extractor module. These tests are crucial for ensuring the reliability and correctness of the code.

Please explore the individual directories for more details on the code and its purpose.

# Usage

## Configuration
inside `mysite` directory, there are two files as follows:  
pkfkrelations.csv --> contains key details for the TPCH schema. If any other schema is to be used, change this file accordingly.
config.ini --> This contains database login credentials and flags for optional features. Change the fields accordingly.  

### Config File Details:
`database` section: set your database credentials.  

`support` section: give support file name. The support file should be present in the same directory of this config file.

`logging` section: set logging level. The developer mode is `DEBUG`. Other valid levels are `INFO`, `ERROR`.

`feature` section: set flags for advanced features, as the flag names indicate. Included features are, `UNION`, `OUTER JOIN`, `<>` or `!=` operator in arithmetic filter predicates and `IN` operator. 

`options` section: extractor options. E.g. the maximum value for `LIMIT` clause is 1000. If the user needs to set a higher value, use `limit=value`.


### Running Unmasque
Open `mysite/unmasque/src/main_cmd.py` file.  
This script has one default input specified.  
Change this query to try Unmasque for various inputs.  
`test.util` package has `queries.py` file, containing a few sample queries. Any of them can be used for testing.

#### From Command Line:
Change the current directory to `mysite`.
Use the following command:  
`python -m unmasque.src.main_cmd` 

#### From IDE:
the `main` function in main_cmd.py can be run from the IDE.  

(Current code uses relative imports in main_cmd.py script. If that causes import related error while trying to run from IDE, please change the imports to absolute.)

#### From GUI:
In the terminal, go inside `unmasque` folder and start the Django app using the command: `python3 manage.py runserver`
Once the server is up at the 8080 port of localhost, the GUI can be accessed through the link: `http://localhost:8080/unmasque/`

