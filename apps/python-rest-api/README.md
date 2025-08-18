# Python REST API

## Introduction
This project is a simple REST API built with Flask. 
It exposes a single endpoint `/hello` that returns a JSON response. 
The API is intended as a minimal example for local development, containerization, and deployment scenarios.

---

## How to Run Locally (Linux/macOS)

1. **Create a virtual environment (recommended)**
   In the project directory, run:
   ```bash
   python3 -m venv debug
   source debug/bin/activate
   ```

2. **Install dependencies**
   Ensure you have Python 3.8+ installed. Then, install the required packages:
   ```bash
   pip install -r requirements.txt
   ```

3. **Start the API**
   Run the following command from the project directory:
   ```bash
   python main.py
   ```

4. **Access the API**
   Open your browser or use curl to access:
   ```
   http://localhost:9001/hello
   ```

5. **Exit the virtual environment**
   When finished, deactivate the environment by running:
   ```bash
   deactivate
   ```

---

## How to Run Locally (Windows PowerShell)

1. **Install Python**
   Download and install Python 3.8+ from the official website: [https://www.python.org/downloads/windows/](https://www.python.org/downloads/windows/)

2. **Create a virtual environment (recommended)**
   In the project directory, run:
   ```powershell
   python -m venv debug
   .\debug\Scripts\Activate.ps1
   ```

3. **Install dependencies**
   After activating the virtual environment, install the required packages:
   ```powershell
   pip install -r requirements.txt
   ```

4. **Start the API**
   From the project directory, run:
   ```powershell
   python main.py
   ```

5. **Access the API**
   Open your browser or use curl to access:
   ```
   http://localhost:9001/hello
   ```

6. **Exit the virtual environment**
   When finished, deactivate the environment by running:
   ```powershell
   deactivate
   ```

---

## Running with Docker

> **Note:** The following commands must be run from the `apps/python-rest-api` project directory (where the Dockerfile is located).

### 1. Build Docker image
```bash
docker build -t python-rest-api .
```

### 2. Run Docker image
```bash
docker run -p 9001:9001 python-rest-api
```

The API will be available at `http://localhost:9001/hello`.

---

## Publishing to Docker Hub

1. **Tag your image for Docker Hub**
   Replace `<your-dockerhub-username>` with your Docker Hub username:
   ```bash
   docker tag python-rest-api <your-dockerhub-username>/python-rest-api:latest
   ```

2. **Login to Docker Hub**
   ```bash
   docker login
   ```

3. **Push the image to Docker Hub**
   ```bash
   docker push <your-dockerhub-username>/python-rest-api:latest
   ```

Your image will now be available on Docker Hub under your account.