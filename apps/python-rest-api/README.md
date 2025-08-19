# Python REST API

---

## 📖 Overview

This project is a **simple REST API** built with Flask. It exposes a single endpoint `/hello` that returns a JSON response. The API is intended as a minimal example for local development, containerization, and deployment scenarios.

---

## 🚀 Local Development

### Linux/macOS

Follow these steps to run the API locally on Linux or macOS:

1. **Create a virtual environment**
   > 📌 **Tip:** Using a virtual environment is recommended to isolate dependencies.
   ```bash
   # Create and activate a virtual environment
   python3 -m venv debug
   source debug/bin/activate
   ```
2. **Install dependencies**
   > Ensure you have **Python 3.8+** installed.
   ```bash
   pip install -r requirements.txt
   ```
3. **Start the API**
   > This command runs the Flask API server.
   ```bash
   python main.py
   ```
4. **Access the API**
   > Open your browser or use curl to access the endpoint:
   ```
   http://localhost:9001/hello
   ```
5. **Exit the virtual environment**
   > Deactivate the environment when finished.
   ```bash
   deactivate
   ```

---

### Windows (PowerShell)

Follow these steps to run the API locally on Windows:

1. **Install Python**
   > Download and install Python 3.8+ from the [official website](https://www.python.org/downloads/windows/).
2. **Create a virtual environment**
   > 📌 **Tip:** Use a virtual environment for dependency isolation.
   ```powershell
   python -m venv debug
   .\debug\Scripts\Activate.ps1
   ```
3. **Install dependencies**
   > Install required packages after activating the environment.
   ```powershell
   pip install -r requirements.txt
   ```
4. **Start the API**
   > Run the Flask API server.
   ```powershell
   python main.py
   ```
5. **Access the API**
   > Open your browser or use curl to access:
   ```
   http://localhost:9001/hello
   ```
6. **Exit the virtual environment**
   > Deactivate the environment when finished.
   ```powershell
   deactivate
   ```

---

## 🐳 Running with Docker

> 📌 **Note:** Run these commands from the `apps/python-rest-api` directory (where the Dockerfile is located).

### 1. Build Docker image
Build the Docker image for the API:
```bash
docker build -t python-rest-api .
```

### 2. Run Docker image
Run the container and expose port 9001:
```bash
docker run -p 9001:9001 python-rest-api
```

> The API will be available at `http://localhost:9001/hello`.

---

## 📦 Publishing to Docker Hub

Follow these steps to publish your image:

1. **Tag your image for Docker Hub**
   > Replace `<your-dockerhub-username>` with your Docker Hub username.
   ```bash
   docker tag python-rest-api <your-dockerhub-username>/python-rest-api:latest
   ```
2. **Login to Docker Hub**
   > Authenticate with your Docker Hub credentials.
   ```bash
   docker login
   ```
3. **Push the image to Docker Hub**
   > Upload your image to Docker Hub.
   ```bash
   docker push <your-dockerhub-username>/python-rest-api:latest
   ```

> Your image will now be available on Docker Hub under your account.

---