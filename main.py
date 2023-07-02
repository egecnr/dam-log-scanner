from fastapi import FastAPI
from dbclass import DbConnection

app = FastAPI()


@app.get("/")
async def root():
    dbobject = DbConnection()
    connection = dbobject.connectDB("system","root","10.42.0.43:1521/ORCLCDB")
    return connection.dsn
