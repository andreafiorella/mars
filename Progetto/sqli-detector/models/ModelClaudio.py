import os, re, pickle
import numpy as np
from keras.models import load_model
from keras.preprocessing.sequence import pad_sequences

class ModelClaudio:
    
    def __init__(self):
        self.model = None
        self.tokenizer = None
        self.modelname = "sqli-detector-claudio"

    def load_model_and_tokenizer(self):
        current_working_directory = os.path.abspath(os.getcwd())
        base_model_path = current_working_directory + "/models/" + self.modelname + "/"

        model_path = base_model_path + "model.h5"
        tokenizer_path = base_model_path + "tokenizer.pickle"

        self.model = load_model(model_path)
        with open(tokenizer_path, 'rb') as handle:
            self.tokenizer = pickle.load(handle)

    def get_verdict(self, text: str):
        # Parametri per il preprocessing (usati durante l'addestramento)
        MAP = {0: "allowed", 1: "sqli"}
        max_len = 60

        sql_keywords = r"\b(SELECT|INSERT|UPDATE|DELETE|DROP|TABLE|FROM|WHERE|AND|OR|UNION|LIKE|IS|NULL|BETWEEN|HAVING)\b"
        sql_symbols = r"[=\-+\*/<>;,\"'|()`!@#$%^&*[]"

        # Combinare tutti i pattern in uno (senza \s+ per gli spazi)
        combined_regex = f"({sql_symbols}|{sql_keywords}|[\w]+)"

        try:
            tokens = re.findall(combined_regex, text)
            tokens = [' '.join(token) if isinstance(token, tuple) else token for token in tokens]
            preprocessed_texts = ' '.join(tokens)
            #print(preprocessed_texts)
            sequences = self.tokenizer.texts_to_sequences([preprocessed_texts])
            padded_sequences = pad_sequences(sequences, maxlen=max_len)
            padded_sequences = np.array(padded_sequences, dtype=np.int32)
            prediction = self.model.predict(padded_sequences)
            predicted_label = np.argmax(prediction, axis=1)
            probability = prediction[0][predicted_label[0]]
            verdict = MAP[predicted_label[0]]
            #print(verdict, probability, predicted_label)
            
            if verdict == "allowed":
                malicious =  False
            else:
                malicious = True
            
            return {'verdict': str(verdict), 'malicious': str(malicious)}
        except Exception as e:
            print("\033[91m {}\033[00m" .format(f'Crashed @ "get_verdict_from_claudio": {e}'))
            return {'verdict': 'None', 'malicious': 'Not checked.'}