<<<<<<< HEAD
# kebun_komuniti

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
=======
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
- **Service AI:** Python/FastAPI + Google Gemini 2.5 Flash API + Supabase DB.
- **Service Inventory:** Python/FastAPI + Supabase (PostgreSQL/PostGIS).
- **Orchestration:** Docker Compose (Local/Demo Environment).

---

## 🛡️ Security & Auditing (Defense-in-Depth)

The platform is built with a multi-layered security approach:
1. **Network Level (NGINX):** Rate-limited to 10 requests per second per IP to mitigate DDoS.
2. **Application Level (FastAPI):** Internal rate-limiting (5 requests/minute) to protect Gemini API keys from accidental spam.
3. **Data Level (Validation):** Multi-modal guardrails ensure the AI only processes farming-related images.
4. **Environment Security:** Secrets are managed via `.env` and are strictly excluded from repository tracking.

---

## 💻 Getting Started (For Developers)

### 1. Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/)
- [VS Code](https://code.visualstudio.com/)

### 2. Initial Setup
```bash
git clone https://github.com/Nitezio/KebunKomuniti_AI.git
cd KebunKomuniti_AI
git checkout nitesh
```

### 3. Environment Configuration
Navigate to the core directory and create your local environment file:
```bash
cd kebunkomuniti-core
cp .env.example .env
```
*Edit the `.env` file with your `GEMINI_API_KEY` and `SUPABASE` credentials.*

### 4. Running the Ecosystem
```bash
docker-compose up --build
```
The **API Gateway** will be available at `http://localhost:80`.

---

## 🗺️ Project Roadmap
- [x] Initial Infrastructure & NGINX Gateway
- [x] Dockerization of Microservices
- [x] AI Service Integration (Gemini 2.5 Flash + Supabase)
- [x] Application-Level Security & Rate Limiting
- [ ] Inventory & Spatial Engine implementation (Service Inventory)
- [ ] Flutter UI Prototype Integration
- [ ] Ngrok Tunneling for Live Demo

---
*Created for PutraHack 2026. Built with 💚 for a sustainable future.*
>>>>>>> 224b6bb846a4a459d763d76ccc26098edb511b42
