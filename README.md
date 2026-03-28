# KebunKomuniti AI 🌿

**Empowering Urban Food Security through AI-Driven Hyper-Local Aggregation.**

KebunKomuniti AI is a decentralized community farming platform designed to turn neighborhoods into resilient, self-sustaining food hubs. By utilizing AI and geo-spatial mapping, we help urban farmers manage their crops and pool micro-surpluses into bulk orders for local restaurants and food banks.

---

## 🚀 The Core Concept

Urban food security is often hindered by high delivery costs for small-scale produce. KebunKomuniti AI solves this by:
- **AI Plant Doctor:** Uses computer vision (Gemini 2.5 Flash) to diagnose plant diseases and provide localized fixes.
- **Neighborhood Aggregator:** A proprietary algorithm that clusters nearby micro-surpluses (e.g., 500g from 20 houses) into single 10kg bulk listings.
- **Hyper-Local Geo-Fencing:** Filters marketplace results to a walkable 3km-5km radius, eliminating traditional logistics costs.

## 🏗️ Technical Architecture

We use a **Dockerized Microservices Architecture** to ensure fault isolation and scalability:
- **Frontend:** Flutter Mobile App (Android/iOS).
- **API Gateway:** NGINX (Reverse Proxy, Rate-Limiting, Security Headers).
- **Service AI:** Python/FastAPI + Google Gemini API.
- **Service Inventory:** Python/FastAPI + Supabase (PostgreSQL/PostGIS).
- **Orchestration:** Docker Compose (Local/Demo Environment).

---

## 💻 Getting Started (For Developers)

### 1. Prerequisites
Ensure you have the following installed:
- [Docker & Docker Compose](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/)
- [VS Code](https://code.visualstudio.com/) (Recommended for Backend/DevOps)
- [Android Studio](https://developer.android.com/studio) (Required for Flutter development)

### 2. Initial Setup
```bash
# Clone the repository
git clone https://github.com/Nitezio/KebunKomuniti_AI.git
cd KebunKomuniti_AI

# Switch to the infrastructure branch
git checkout chore/initial-infrastructure
```

### 3. Environment Configuration
Navigate to the core directory and create your local environment file:
```bash
cd kebunkomuniti-core
cp .env.example .env
```
*Edit the `.env` file with your specific API keys (Gemini, Supabase).*

### 4. Running the Ecosystem
```bash
docker-compose up --build
```
The **API Gateway** will be available at `http://localhost:80`.

---

## 🛠️ Contribution & Workflow

To maintain a professional environment and prevent merge conflicts, we follow a **Feature-Branch Workflow**.

### Git Workflow Steps:
1. **Sync Main:** `git pull origin main`
2. **Create Feature Branch:** `git checkout -b feature/your-task-name`
3. **Stage Changes:** `git add .`
4. **Commit (Conventional Commits):** `git commit -m "feat: add plant diagnosis endpoint"`
5. **Push:** `git push origin feature/your-task-name`

### Role-Based Access Control (RBAC):
- **DevOps/Infrastructure:** Responsible for `docker-compose`, `nginx.conf`, and `Dockerfile`s.
- **AI Lead:** Responsible for `service-ai/` logic and Gemini prompts.
- **DB Lead:** Responsible for `service-inventory/` and Supabase schemas.
- **Mobile Lead:** Responsible for the Flutter codebase in `app-frontend/`.

---

## 🛡️ Security & Auditing

Every contribution is audited by our **Security Auditor** skill.
- **Rate Limiting:** NGINX is configured to 10r/s per IP to protect our free API tiers.
- **Secrets:** Never commit `.env` files. They are automatically ignored by our global `.gitignore`.
- **Headers:** Secure headers (XSS-Protection, CSP, etc.) are enforced at the gateway level.

---

## 🗺️ Project Roadmap
- [x] Initial Infrastructure & NGINX Gateway
- [x] Dockerization of Microservices
- [ ] AI Service Integration (Gemini 1.5 Flash)
- [ ] Inventory & Spatial Engine (Supabase/PostGIS)
- [ ] Flutter UI Prototype
- [ ] Ngrok Tunneling for Live Demo

---
*Created for PutraHack 2026. Built with 💚 for a sustainable future.*
