import json
import os
import pymysql
import logging
from pymysql.cursors import DictCursor

# Configuración del logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))

    # Imprimir las variables de entorno
    db_host = os.environ.get('DB_HOST')
    db_user = os.environ.get('DB_USER')
    db_password = os.environ.get('DB_PASSWORD')
    db_name = os.environ.get('DB_NAME')

    logger.info(f"DB_HOST: {db_host}")
    logger.info(f"DB_USER: {db_user}")
    logger.info(f"DB_PASSWORD: {db_password}")
    logger.info(f"DB_NAME: {db_name}")

    connection = None
    try:
        # Establecer la conexión con la base de datos utilizando variables de entorno
        connection = pymysql.connect(
            host=db_host,
            user=db_user,
            password=db_password,
            db=db_name,
            cursorclass=DictCursor
        )
        logger.info("Connection to RDS established")
        
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM mytable")
            result = cursor.fetchall()
            logger.info("Query executed successfully, result: %s", result)
        
        return {
            'statusCode': 200,
            'body': json.dumps(result)
        }
    except pymysql.MySQLError as e:
        logger.error("Error connecting to RDS: %s", e)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
    except Exception as e:
        logger.error("General error: %s", e)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
    finally:
        if connection:
            connection.close()
            logger.info("Connection to RDS closed")
