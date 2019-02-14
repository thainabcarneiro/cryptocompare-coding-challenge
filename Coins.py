import logging
import requests

from entity.Coin import Coin
from util.Database import Database

# Sets up the instance of the logger object
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s: %(message)s'
)


def main():
    # Request and persists the API resources
    request_api_coinlist()


def request_api_coinlist():
    url = 'https://min-api.cryptocompare.com/data/all/coinlist'
    header = {
        'authorization': "Apikey 34ce19ee730f1d0b27769cbd0a4da96cec7e269e138bb8b07df5aae371f317b9"
    }

    logging.debug('Requesting API = ' + url)
    response = requests.get(url, headers=header)

    data = response.json()
    logging.debug('API response = ' + str(data))

    coins = []
    for value in data['Data'].values():
        # Builds the "Coin" object
        coins.append(
            Coin(
                value['Id'],
                value['Name'],
                value['Symbol'],
                value['CoinName'],
                value['FullName']
            )
        )

    save_data(coins)


def save_data(elements):
    prepared_stmt = """
        INSERT INTO dim_coin (
            id_dim_coin,
            name,
            symbol,
            coin_name,
            full_name
        )
        VALUES (%s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            name      = %s,
            symbol    = %s,
            coin_name = %s,
            full_name = %s
    """

    con = Database().connect()
    cursor = con.cursor()

    for e in elements:
        # Builds the INSERT statement parameters
        parameters = (
            e.coin_id,
            e.name,
            e.symbol,
            e.coin_name,
            e.full_name,
            e.name,
            e.symbol,
            e.coin_name,
            e.full_name
        )
        logging.debug('Saving coin = ' + str(parameters))

        # Execute the INSERT statement within the transaction
        cursor.execute(prepared_stmt, parameters)

    # Final transaction COMMIT
    con.commit()


if __name__ == '__main__':
    main()
