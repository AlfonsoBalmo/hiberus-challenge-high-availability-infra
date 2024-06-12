import json
import os
import pymysql
from pymysql.cursors import DictCursor

def lambda_handler(event, context):
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
        
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM mytable")
            result = cursor.fetchall()
        
        return {
            'statusCode': 200,
            'body': json.dumps(result)
        }
    except pymysql.MySQLError as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
    finally:
        if connection:
            connection.close()
