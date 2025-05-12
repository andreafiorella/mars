import sys

MODELS = {
    0: "sqli-detector-claudio",
    1: "sqli-detector-bert"
}

from models.ModelClaudio import ModelClaudio
from models.ModelBERT import ModelBERT

def init_model(model_name):

    model = None

    if model_name == MODELS[0]:
        model = ModelClaudio() 
    elif model_name == MODELS[1]:
        model = ModelBERT()

    if model is None:
        print("Model not found. Check model's name.")
        sys.exit()
    else:
        model.load_model_and_tokenizer()

    return model