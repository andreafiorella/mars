from flask import Flask, request, jsonify

from config import MINION_IP, MINION_PORT, DEFAULT_MODEL_NAME
from model_manager import init_model

app = Flask(__name__)

model = init_model(DEFAULT_MODEL_NAME)

@app.route('/api/v1/check', methods=['POST'])
def check_param():
    try:
        data = request.json
        param = data['p']
        return jsonify(model.get_verdict(param))
    except Exception as e:
        print("\033[91m {}\033[00m" .format(f'Crashed @ "check_param": {e}'))
        return {'verdict': 'None', 'malicious': 'Not checked.'}

if __name__ == '__main__':
    app.run(host=MINION_IP, port=MINION_PORT, debug=True)