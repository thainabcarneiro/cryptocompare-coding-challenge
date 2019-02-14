class FactCoin:

    def __init__(self, id_dim_date, id_dim_coin, id_dim_time, volume_from_usd, volume_to_usd, open, close, low, high, revenue):
        self.id_dim_date = id_dim_date
        self.id_dim_coin = id_dim_coin
        self.id_dim_time = id_dim_time
        self.volume_from_usd = volume_from_usd
        self.volume_to_usd = volume_to_usd
        self.open = open
        self.close = close
        self.low = low
        self.high = high
        self.revenue = revenue
