import os
from transformers import pipeline, BertForSequenceClassification, BertTokenizerFast

class ModelBERT():
    def __init__(self):
        self.model = None
        self.tokenizer = None
        self.modelname = "sqli-detector-bert"

    def load_model_and_tokenizer(self):
        current_working_directory = os.path.abspath(os.getcwd())
        base_model_path = current_working_directory + "/models/" + self.modelname + "/"
        self.model = BertForSequenceClassification.from_pretrained(base_model_path)
        self.tokenizer = BertTokenizerFast.from_pretrained(base_model_path)

    def get_verdict(self, text: str):
        try:
            nlp = pipeline("text-classification", model=self.model, tokenizer=self.tokenizer)
            result = nlp(text)
            verdict = result[0]['label']

            if verdict == "allowed":
                malicious =  False
            else:
                malicious = True
            
            return {'verdict': str(verdict), 'malicious': str(malicious)}
        except Exception as e:
            print("\033[91m {}\033[00m" .format(f'Crashed @ "get_verdict_from_bert": {e}'))
            return {'verdict': 'None', 'malicious': 'Not checked.'}