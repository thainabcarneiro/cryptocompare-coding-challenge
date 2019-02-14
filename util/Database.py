import mysql.connector


class Database:
    connection = None

    def connect(self):
        if self.connection is None:
            self.connection = mysql.connector.connect(
                host='localhost',
                port=3306,
                user='root',
                passwd='root',
                database='cryptocompare'
            )
            self.connection.autocommit = False

        return self.connection
