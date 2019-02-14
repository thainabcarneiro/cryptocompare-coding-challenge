from setuptools import setup

setup(
    name='cryptocompare-coding-challenge',
    packages=['util', 'entity'],
    author='Thainá Batista',
    author_email='thainabcarneiro@gmail.com',
    description='CryptoCompare.com API coding challenge',
    install_requires=['requests', 'mysql', 'pytz']
)
