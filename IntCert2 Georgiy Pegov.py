import psycopg2

db_params = {
    'dbname': 'demo',
    'user': 'postgres',
    'password': 'Null',
    'host': 'localhost',
    'port': '5432'
}

try:
    conn = psycopg2.connect(**db_params)

    cursor = conn.cursor()

    cursor.execute("""
    select * from bookings.passengers;
    """)

    rows = cursor.fetchall()

    for row in rows:
        print(row)

except psycopg2.Error as e:
    print("not good...", e)

finally:
    cursor.close()
    conn.close()