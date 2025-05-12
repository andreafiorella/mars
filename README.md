# MARS - Machine-learning AI per Riconoscere SQLi

## 📌 Descrizione

**MARS** è un sistema avanzato di rilevamento per attacchi di tipo **SQL Injection (SQLi)** basato su **modelli di intelligenza artificiale**. Il progetto nasce come soluzione alternativa e migliorativa rispetto ai tradizionali Web Application Firewall (WAF), con particolare attenzione alla **facile integrazione nei sistemi legacy** e alla **scalabilità in ambienti moderni**. MARS analizza in tempo reale i parametri delle richieste HTTPS per rilevare e bloccare SQLi, anche in forme sofisticate ed evasive.

> Questo progetto è stato realizzato come parte di un esame universitario presso il Dipartimento di Informatica dell'Università degli Studi di Bari, e dimostra competenze in **Machine Learning**, **Cybersecurity**, **DevOps (Docker)**, **deployment full-stack**, sviluppo di **microservizi**.

## 🧠 Tecnologie e Architettura

### Modelli AI implementati

- 🔁 **RNN + BiLSTM**: Modello custom basato su embedding e LSTM bidirezionale, addestrato su un dataset di 430.000 richieste (SQLi vs. richieste lecite).
- 🤖 **Fine-tune di BERT**: Modello BERT adattato al task di classificazione binaria per SQLi detection, testato con eccellenti risultati sia su dataset piccolo che su quello esteso.
- I MODELLI NON SONO INCLUSI NELLA REPO

### Dataset

- **430k righe**, bilanciate tra richieste legittime e malevole.
- Dati raccolti tramite strumenti reali come `mitmproxy`, `SQLMap`, DVWA, e dataset pubblici (`rockyou`, `waf-a-mole`).
- Generazione e preprocessing automatizzato tramite script Python.

### Architettura di deploy

- 🐳 **Docker-based**: Tutti i componenti containerizzati per una facile distribuzione.
- 🌐 **NGINX + OpenResty**: Usato come Ingress Controller, integrato con script Lua per inoltrare le richieste al detector AI.
- 📊 **ElasticSearch + Kibana**: Per monitoraggio real-time e logging delle richieste.
- 🧪 **DVWA** come ambiente di test.
- 🔌 **REST API** in Flask per analisi delle richieste via endpoint `/api/v1/check`.

## 📈 Risultati

### RNN

- Accuracy: ~99.94%
- F1 Score: ~0.9992
- Validato con Stratified 10-fold cross validation
- Buona generalizzazione su nuovi dati

### BERT

- Accuracy su test set esteso: 99.93%
- Precision: 99.85%
- Recall: 99.99%
- F1 Score: 99.93%
- Elevata robustezza, con pochi falsi positivi/negativi anche su dataset ampio

## 🧩 Componenti principali del repository

- `/sqli-detector/` – Microservizio Flask per inferenza del modello
- `/nginx/` – Configurazioni di NGINX e script Lua per analisi e decisione sulle richieste

## 👤 Autori

- Andrea Fiorella
- Vito Claudio Giammaria
- Danilo Campanale

## 🎓 Università

Dipartimento di Informatica, Università degli Studi di Bari

## 📄 Licenza

Questo progetto è a scopo didattico e dimostrativo. Per informazioni commerciali o estensioni, contattare gli autori.
