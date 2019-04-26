import logging
import requests

from util.Database import Database
from entity.Exchange import Exchange
from util.EnvVariable import EnvVariable as EnvVar

# Sets up the instance of the logger object
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s: %(message)s'
)


def main():
    # Request and persists the API resources
    request_api_exchanges()


def request_api_exchanges():
    url = 'https://min-api.cryptocompare.com/data/exchanges/general'
    header = {
        'authorization': 'Apikey {}'.format(EnvVar.api_key)
    }

    logging.debug('Requesting API = ' + url)
    response = requests.get(url, headers=header)

    data = response.json()
    logging.debug('API response = ' + str(data))

    exchanges = []
    for value in data['Data'].values():
        # Builds the "Exchange" object from the response, and appends to the exchange list
        exchanges.append(
            Exchange(
                value['Id'],
                value['Name'],
                value['AffiliateUrl'],
                value['Country'],
                value['CentralizationType'],
                value['InternalName']
            )
        )

    # Save the exchange elements to the database
    save_data(exchanges)


def save_data(elements):
    prepared_stmt = """
        INSERT INTO dim_exchange (
            id_dim_exchange,
            name,
            url,
            country,
            centralization_type,
            internal_name
        )
        VALUES (%s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            name    = %s,
            url     = %s,
            country = %s,
            centralization_type = %s,
            internal_name = %s
    """

    con = Database().connect()
    cursor = con.cursor()

    for e in elements:
        # Builds the INSERT statement parameters
        parameters = (
            e.id_dim_exchange,
            e.name,
            e.url,
            e.country,
            e.centralization_type,
            e.internal_name,
            e.name,
            e.url,
            e.country,
            e.centralization_type,
            e.internal_name
        )
        logging.debug('Saving exchange = ' + str(parameters))

        # Execute the INSERT statement within the transaction
        cursor.execute(prepared_stmt, parameters)

    # Final transaction COMMIT
    con.commit()


if __name__ == '__main__':
    main()
