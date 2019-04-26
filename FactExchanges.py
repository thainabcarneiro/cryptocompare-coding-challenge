import logging
import time
import pytz
import requests

from datetime import datetime
from util.Database import Database
from entity.Exchange import Exchange
from entity.Transaction import Transaction
from util.EnvVariable import EnvVariable as EnvVar

# Sets up the instance of the logger object
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s: %(message)s'
)


def main():
    # Return the list of all exchanges with their "IDs" and "names"
    exchanges = get_exchanges()

    # Request and persists the API resources
    request_api_histoday(
        '2017-01-01',
        exchanges
    )


def get_exchanges():
    con = Database().connect()
    cursor = con.cursor()
    cursor.execute('SELECT id_dim_exchange, internal_name FROM dim_exchange')
    data = cursor.fetchall()

    exchanges = []
    for value in data:
        # Builds the "Exchange" object from the response, and appends to the exchange list
        exchanges.append(
            Exchange(
                value[0],  # id_dim_exchange
                None,
                None,
                None,
                None,
                value[1]  # internal_name
            )
        )

    return exchanges


def request_api_histoday(start_date, exchanges):
    # Calculate the "Days between" today and the given date
    start_date = datetime.strptime(start_date, '%Y-%m-%d')
    number_of_days = abs((datetime.now() - start_date)).days

    base_url = 'https://min-api.cryptocompare.com/data/exchange/histoday?tsym=USD&limit=' + str(number_of_days)
    header = {
        'authorization': 'Apikey {}'.format(EnvVar.api_key)
    }

    local_tz = pytz.timezone('America/Sao_Paulo')
    api_tz = pytz.timezone('Etc/GMT')

    # For each exchange, gathers data related to daily transaction volume
    for e in exchanges:
        transactions = []

        url = base_url + '&e=' + e.internal_name
        logging.debug('Requesting API = ' + url)
        response = requests.get(url, headers=header)

        data = response.json()
        logging.debug('API response = ' + str(data))

        for value in data['Data']:
            # Get the timestamp object in GMT and converts to America/Sao Paulo timezone
            timestamp_return = (datetime.fromtimestamp(value['time']))
            timestamp_return = str(local_tz.localize(timestamp_return).astimezone(api_tz))

            # Get the "Date" portion from the timestamp
            date_transaction = timestamp_return.split(' ')[0]

            # Queries the database to get the "Date" dimension ID
            id_dim_date = get_id_dim_date(date_transaction)

            # Builds the "Transaction" object from the response, and appends to the transactions list
            transactions.append(
                Transaction(
                    id_dim_date,
                    e.id_dim_exchange,
                    value['volume'],
                    'USD'
                )
            )

        # Save the transaction elements to the database
        save_data(transactions)

        # Sleeps 2s to avoid DoS, then continues
        time.sleep(2)


def get_id_dim_date(date):
    prepared_stmt = 'SELECT id_dim_date FROM dim_date WHERE date = DATE(%s)'
    parameter = [date]

    con = Database().connect()
    cursor = con.cursor()
    cursor.execute(prepared_stmt, parameter)
    data = cursor.fetchone()

    return data[0] if len(data) else None


def save_data(elements):
    prepared_stmt = """
        INSERT INTO fact_exchange (
         id_dim_date,
         id_dim_exchange,
         volume,
         symbol
        )
        VALUES (%s, %s, %s, %s);
    """

    con = Database().connect()
    cursor = con.cursor()

    for e in elements:
        # Builds the INSERT statement parameters
        parameters = (
            e.id_dim_date,
            e.id_dim_exchange,
            e.volume,
            e.symbol
        )
        logging.debug('Saving transaction = ' + str(parameters))

        # Execute the INSERT statement within the transaction
        cursor.execute(prepared_stmt, parameters)

    # Final transaction COMMIT
    con.commit()


if __name__ == '__main__':
    main()
