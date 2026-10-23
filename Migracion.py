"""
Configuración de conexiones. Ajuste estos valores a su equipo
o defínalos como variables de entorno (tienen prioridad).
"""
import os

# ---------------- SQL Server ----------------
# Driver: revise cuál tiene instalado en "Orígenes de datos ODBC (64 bits)" > pestaña Controladores.
#   - "ODBC Driver 18 for SQL Server" (el más reciente)
#   - "ODBC Driver 17 for SQL Server"
SQL_DRIVER = os.getenv("SQL_DRIVER", "ODBC Driver 18 for SQL Server")
SQL_SERVER = os.getenv("SQL_SERVER", "localhost\\SQLEXPRESS")  # nombre del servidor que aparece en SSMS
SQL_DATABASE = os.getenv("SQL_DATABASE", "TiendaOnlineDB")
SQL_USER = os.getenv("SQL_USER", "")                        # vacío = autenticación de Windows
SQL_PASSWORD = os.getenv("SQL_PASSWORD", "")


def cadena_sql_server():
    base = (f"DRIVER={{{SQL_DRIVER}}};SERVER={SQL_SERVER};DATABASE={SQL_DATABASE};"
            "TrustServerCertificate=yes;")
    if SQL_USER:
        return base + f"UID={SQL_USER};PWD={SQL_PASSWORD};"
    return base + "Trusted_Connection=yes;"


# ---------------- MongoDB ----------------
# Local: mongodb://localhost:27017   |   Atlas: mongodb+srv://usuario:clave@cluster.xxxxx.mongodb.net
MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017")
MONGO_DB = os.getenv("MONGO_DB", "tienda_online")
