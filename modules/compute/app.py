from flask import Flask, request, jsonify, render_template
import pymysql
import os

app = Flask(__name__)

DB_CONFIG = {
    "host": os.environ.get("DB_HOST"),
    "user": os.environ.get("DB_USER"),
    "password": os.environ.get("DB_PASSWORD"),
    "db": os.environ.get("DB_NAME"),
    "cursorclass": pymysql.cursors.DictCursor
}


def get_connection():
    return pymysql.connect(**DB_CONFIG)


@app.route('/')
def home():
    return render_template('index.html')


@app.route('/calcola', methods=['POST'])
def calcola():
    try:
        data = request.get_json()

        capitale = float(data["capitale"])
        tasso = float(data["tasso"])
        anni = int(data["anni"])
        deposito_mensile = float(data["deposito_mensile"])

        mesi = anni * 12
        tasso_mensile = tasso / 100 / 12
        montante = capitale

        for _ in range(mesi):
            montante = (montante + deposito_mensile) * (1 + tasso_mensile)

        risultato = round(montante, 2)

        conn = get_connection()
        try:
            with conn.cursor() as cursor:
                sql = """
                    INSERT INTO calcoli (
                        capitale_iniziale,
                        tasso,
                        anni,
                        deposito_mensile,
                        risultato_finale
                    )
                    VALUES (%s, %s, %s, %s, %s)
                """
                cursor.execute(sql, (
                    capitale,
                    tasso,
                    anni,
                    deposito_mensile,
                    risultato
                ))
            conn.commit()
        finally:
            conn.close()

        return jsonify({"risultato": risultato})

    except Exception as e:
        print(f"ERRORE GENERALE: {e}")
        return jsonify({"errore": str(e)}), 500


@app.route('/cronologia', methods=['GET'])
def get_cronologia():
    try:
        conn = get_connection()
        try:
            with conn.cursor() as cursor:
                sql = """
                    SELECT
                        id,
                        capitale_iniziale,
                        tasso,
                        anni,
                        deposito_mensile,
                        risultato_finale,
                        created_at
                    FROM calcoli
                    ORDER BY id DESC
                    LIMIT 5
                """
                cursor.execute(sql)
                risultati = cursor.fetchall()
        finally:
            conn.close()

        return jsonify(risultati)

    except Exception as e:
        print(f"ERRORE CRONOLOGIA: {e}")
        return jsonify({"errore": str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)