# ⚙️ DeepSeek-R1 Deployment on AWS (ECS + Fargate)

## 📌 Overview
This repository contains the necessary Terraform configuration and Docker setup to deploy **DeepSeek-R1-Distill-Qwen-7B-GGUF** using **Ollama** on **AWS ECS (Fargate & EC2)** with **Application Load Balancer (ALB)**.

### **Infrastructure Components**
- **Amazon ECS (Elastic Container Service)**: Runs DeepSeek-R1 as a containerized application.
- **AWS Fargate**: Serverless execution for Open WebUI.
- **EC2 Instances (G4dn.xlarge)**: Optimized for GPU-based inference.
- **Amazon ECR (Elastic Container Registry)**: Stores Docker images.
- **Application Load Balancer (ALB)**: Routes traffic to DeepSeek.
- **AWS VPC (Virtual Private Cloud)**: Secure network setup.
- **IAM Roles & Security Groups**: Permissions & security settings.

### **Instance Specifications**
| **Service**       | **Instance Type**  | **vCPUs** | **Memory** | **GPU**      | **Networking** |
|-------------------|-------------------|----------|-----------|-------------|---------------|
| **DeepSeek on EC2** | `g4dn.xlarge`     | 4 vCPUs  | 16 GB RAM | 1x NVIDIA T4 | Up to 25 Gbps |
| **Open WebUI on Fargate** | `FARGATE` (1 vCPUs) | 1 vCPUs  | 1 GB RAM | No GPU |  |

### **Infrastructure Diagram**
![Infrastructure Diagram](img/infrastructure.png)

---

## 🏰️ Infrastructure Setup

### **1️⃣ Prerequisites**
Before running Terraform, make sure you have:
- **AWS CLI** installed & configured (`aws configure`).
- **Terraform** installed (`terraform -v`).
- **Docker** installed (`docker -v`).

### **2️⃣ Infrastructure Deployment**
Run the following commands to provision AWS resources:
```sh
terraform init  # Initialize Terraform
terraform apply -auto-approve  # Deploy Infrastructure
```
Terraform will:
✅ Create **ECS Cluster**  
✅ Deploy **Fargate for Open WebUI**  
✅ Setup **ALB & Networking**  
✅ Launch **DeepSeek-R1 on EC2 with GPU**  

After deployment, Terraform will output the **Load Balancer URL**, which you can use to access the service.

---

## 🐳 Docker Setup

### **1️⃣ Pull & Run Ollama Locally**
Instead of building a custom image, we use **Ollama** directly:
```sh
docker run -d --name ollama -p 11434:11434 ollama/ollama
```

### **2️⃣ Download DeepSeek-R1 Model**
Modify this command to switch to another model:
```sh
docker exec -it ollama ollama pull hf.co/bartowski/DeepSeek-R1-Distill-Qwen-1.5B-GGUF:IQ4_NL
```
To use a different model, replace `DeepSeek-R1-Distill-Qwen-1.5B-GGUF:IQ4_NL` with another model name from the comparison table below.

### **3️⃣ Verify the Model is Available**
```sh
curl http://localhost:11434/api/tags
```

### **4️⃣ Test API Locally**
```sh
curl -X POST http://localhost:11434/api/generate -d '{
  "model": "hf.co/bartowski/DeepSeek-R1-Distill-Qwen-1.5B-GGUF:IQ4_NL",
  "prompt": "Hello, how are you?",
  "stream": false
}' -H "Content-Type: application/json"
```

---

## 📊 Model Comparison
Below is a performance comparison of different models:

| Model | AIME 2024 pass@1 | AIME 2024 cons@64 | MATH-500 pass@1 | GPQA Diamond pass@1 | LiveCodeBench pass@1 | CodeForces rating |
|-------------------|----------------|----------------|----------------|----------------|----------------|----------------|
| GPT-4o-0513 | 9.3 | 13.4 | 74.6 | 49.9 | 32.9 | 759 |
| Claude-3.5-Sonnet-1022 | 16.0 | 26.7 | 78.3 | 65.0 | 38.9 | 717 |
| o1-mini | 63.6 | 80.0 | 90.0 | 60.0 | 53.8 | **1820** |
| QwQ-32B-Preview | 44.0 | 60.0 | 90.6 | 54.5 | 41.9 | 1316 |
| **DeepSeek-R1-Distill-Qwen-1.5B** | 28.9 | 52.7 | 83.9 | 33.8 | 16.9 | 954 |
| **DeepSeek-R1-Distill-Qwen-7B** | 55.5 | 83.3 | 92.8 | 49.1 | 37.6 | 1189 |
| **DeepSeek-R1-Distill-Qwen-14B** | 69.7 | 80.0 | 93.9 | 59.1 | 53.1 | 1481 |
| **DeepSeek-R1-Distill-Qwen-32B** | **72.6** | **83.3** | **94.3** | **62.1** | **57.2** | 1691 |

Use this table to decide which model best suits your use case and modify the Docker command accordingly.

---

## 📝 install.sh Script (GPU + Docker Setup)
The `install.sh` script automates the installation of:
✅ **NVIDIA Drivers & Container Toolkit**  
✅ **Docker**  
✅ **DeepSeek Model in Ollama**  

### **Run it on EC2:**
```sh
chmod +x install.sh
./install.sh
```

---


## 🌐 Installing Open WebUI Locally

Open WebUI can be installed using pip, the Python package installer. Before proceeding, ensure you're using Python 3.11 to avoid compatibility issues.

1️⃣ Install Open WebUI: Open your terminal and run the following command to install Open WebUI:


```
pip install open-webui
```
2️⃣ Running Open WebUI: After installation, you can start Open WebUI by executing:

```
open-webui serve
```
3️⃣ Access the Open WebUI

Open your browser and navigate to:
```
http://localhost:8080
```

---


## 🌎 Accessing the Deployment
Once Terraform is applied, you can access DeepSeek-R1 via:
```
http://<load-balancer-url>
```
To interact with the API, use:
```sh
curl http://<load-balancer-url>/api/generate -d '{"model": "deepseek-r1-distill-qwen", "prompt": "Hello!"}'
```

---

## 🔥 Future Improvements
- ✅ **Auto Scaling for EC2 Instances**
- ✅ **CloudWatch Monitoring & Logs**
- ✅ **Additional Security Best Practices**

🚀 **Contributions are welcome!** Feel free to open issues or submit PRs.

