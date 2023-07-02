import cx_Oracle

class DbConnection:

    def __init__(self):
        self.username= "system"
        self.password="root"

    @classmethod
    def connectDB(cls,username,usernamepwd,dsnInfo):
            connection = cx_Oracle.connect(user=username, password= usernamepwd, dsn="10.42.0.43:1521/ORCLCDB" ,encoding="UTF-8")
            return connection
