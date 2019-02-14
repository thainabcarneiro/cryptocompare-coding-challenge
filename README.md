# Cryptocompare coding challenge - Jr. Data Analyst

### Challenge questions (language: pt_br)
    Qual entre as cripto moedas (BTC, ETH, XRP, LTC, DSH, XMR, NEO, XLM, NEM e DOGE) tiveram maior rendimento no ano de 2018?
    Qual entre as cripto moedas (BTC, ETH, XRP, LTC, DSH, XMR, NEO, XLM, NEM e DOGE) tiveram maior rendimento no ano de 2019 até os dias atuais?
    Quantas exchanges existem que contém "bit" no nome?
    No ano de 2018, qual foi o mês em que o BTC teve o maior número de dias em alta (ou variação positiva) consecutivos? E quantos dias?
    Em média, qual o horário com maior volume (em USD) de transações para o BTC no mês de Janeiro de 2019?
    Quais são as TOP 3 exchanges em volume de transações em: Janeiro de 2019, Janeiro de 2018 e Janeiro de 2017?


### Challenge questions resolution
    ```
    Folder:
        /
         sql_resources/
                       Questions and answers.sql
    ```
 
### CyptoCompare.com APIs
    https://min-api.cryptocompare.com/data/all/coinlist
    https://min-api.cryptocompare.com/data/exchanges/general
    https://min-api.cryptocompare.com/data/histohour
    https://min-api.cryptocompare.com/data/exchange/histoday    

    
### API docs
    https://min-api.cryptocompare.com/documentation

    
### Project dependencies
    Python 3.7
    MySQL 5.6/8.0


### How to setup the database
        Import the files below into your database:
        ```
        Folder:
            /
             sql_resources/
                           Database structure and procedures.sql
                           Database data.sql
        ```
        
### Database model

![](https://github.com/thainabcarneiro/cryptocompare-coding-challenge/sql_resources/EER.png)
