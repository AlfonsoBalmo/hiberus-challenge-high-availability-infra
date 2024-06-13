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
    connection = None
    try:
        # Establecer la conexión con la base de datos utilizando variables de entorno
        connection = pymysql.connect(
            host=os.environ['DB_HOST'],
            user=os.environ['DB_USER'],
            password=os.environ['DB_PASSWORD'],
            db=os.environ['DB_NAME'],
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
