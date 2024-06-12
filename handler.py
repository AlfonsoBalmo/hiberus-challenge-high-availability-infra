import json
import pymysql

def lambda_handler(event, context):
    connection = pymysql.connect(
        host='mydbinstance.123456789012.us-east-1.rds.amazonaws.com',
        user='adminuser',
        password='mypassword',
        db='mydatabase'
    )
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM mytable")
    result = cursor.fetchall()
    connection.close()
    
    return {
        'statusCode': 200,
        'body': json.dumps(result)
    }
}
