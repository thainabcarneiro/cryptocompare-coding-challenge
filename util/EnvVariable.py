import os


class EnvVariable:
    api_key = os.environ.get('CRYPTOCOMPARE_AUTH_API_KEY')
