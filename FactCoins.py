import logging
import time
import requests

from datetime import datetime
from datetime import timedelta
from util.Database import Database
from entity.FactCoin import FactCoin
from util.EnvVariable import EnvVariable as EnvVar

logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s: %(message)s'
)

# Cryptocurrencies
COINS = [
    'BTC',  # Bitcoin
    'ETH',  # Ethereum
    'XRP',  # Ripple
    'LTC',  # Litecoin
    'DSH',  # Dashcoin
    'XMR',  # Monero
    'NEO',  # Neo
    'XLM',  # Stellar
    'XEM',  # XEM
    'DOGE'  # Dogecoin
]


def main():
    # For each coin, request and persists the API resources
    for coin in COINS:
        request_api_histohour(
            '2017-01-01',
            '2019-02-10',
            coin
        )


def request_api_histohour(start_date, end_date, coin):
    start_date = datetime.strptime(start_date, '%Y-%m-%d')
    end_date = datetime.strptime(end_date, '%Y-%m-%d')
    actual_date = start_date

    base_url = 'https://min-api.cryptocompare.com/data/histohour?tsym=USD&limit=23&toTs='
    header = {
        'authorization': 'Apikey {}'.format(EnvVar.api_key)
    }

    while actual_date < end_date:
        transactions = []

        id_dim_date = get_id_dim_date(actual_date)
        id_dim_coin = get_id_dim_coin(coin)

        # Converts the "Date" to "Unix time", according to the API interface
        unixtime = time.mktime(actual_date.timetuple())

        # Builds the URL to request
        url = base_url + str(unixtime) + '&fsym=' + coin
        logging.debug('Requesting API = ' + url)
        response = requests.get(url, headers=header)

        data = response.json()
        logging.debug('API response = ' + str(data))

        for value in data['Data']:
            timestamp_return = str(datetime.fromtimestamp(value['time']))

            # Get the "Time" portion from the timestamp
            time_transaction = timestamp_return.split(' ')[1]

            # Queries the database to get the "Time" dimension ID
            id_dim_time = get_id_dim_time(time_transaction)

            # Builds the "FactCoin" object from the response, and appends to the transaction list
            transactions.append(
                FactCoin(
                    id_dim_date,
                    id_dim_time,
                    id_dim_coin,
                    value['volumefrom'],
                    value['volumeto'],
                    value['open'],
                    value['close'],
                    value['high'],
                    value['low'],
                    ((value['close'] / value['open']) - 1)  # Hourly revenue
                )
            )

        actual_date += timedelta(days=1)

        # Save the exchanges transaction to the database
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


def get_id_dim_time(time):
    prepared_stmt = 'SELECT id_dim_time FROM dim_time WHERE time = %s'
    parameter = [time]

    con = Database().connect()
    cursor = con.cursor()
    cursor.execute(prepared_stmt, parameter)
    data = cursor.fetchone()

    return data[0] if len(data) else None


def get_id_dim_coin(coin):
    prepared_stmt = 'SELECT id_dim_coin FROM dim_coin WHERE symbol = %s'
    parameter = [coin]

    con = Database().connect()
    cursor = con.cursor()
    cursor.execute(prepared_stmt, parameter)
    data = cursor.fetchone()

    return data[0] if len(data) else None


def save_data(elements):
    prepared_stmt = """
        INSERT IGNORE INTO fact_coin (
            id_dim_date,
            id_dim_time,
            id_dim_coin,
            volume_from_usd,
            volume_to_usd,
            close,
            open,
            high,
            low,
            revenue
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
    """

    con = Database().connect()
    cursor = con.cursor()

    for e in elements:
        # Builds the INSERT statement parameters
        parameters = (
            e.id_dim_date,
            e.id_dim_coin,
            e.id_dim_time,
            e.volume_from_usd,
            e.volume_to_usd,
            e.open,
            e.close,
            e.low,
            e.high,
            e.revenue
        )
        logging.debug('Saving transaction = ' + str(parameters))

        # Execute the INSERT statement within the transaction
        cursor.execute(prepared_stmt, parameters)

    # Final transaction COMMIT
    con.commit()


if __name__ == '__main__':
    main()
