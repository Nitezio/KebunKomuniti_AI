# KebunKomuniti AI 🌿

[![Python](https://img.shields.io/badge/Python-3.11+-blue.svg)](https://www.python.org/downloads/)
[![Flutter](https://img.shields.io/badge/Flutter-3.29+-blue.svg)](https://flutter.dev/)
[![Docker](https://img.shields.io/badge/Docker-Enabled-blue.svg)](https://www.docker.com/)
[![SDG 2](https://img.shields.io/badge/SDG-2-green.svg)](https://sdgs.un.org/goals/goal2)
[![SDG 9](https://img.shields.io/badge/SDG-9-orange.svg)](https://sdgs.un.org/goals/goal9)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-success.svg)]()

**Decentralizing Urban Food Security through AI-Driven Hyper-Local Aggregation.**

KebunKomuniti AI is a professional-grade community farming platform that transforms urban neighborhoods into resilient, self-sustaining food hubs. By combining Multimodal AI, Geo-spatial clustering, and a secure microservices architecture, we enable communities to diagnose crops, pool surpluses, and trade locally with zero logistics waste.

---

## 🚀 Key Features

### 👨‍⚕️ AI Plant Doctor (Intelligence)
Powered by **Google Gemini 2.5 Flash**, the platform provides a multimodal computer vision system that identifies plant species and diagnoses diseases from a single photo. 
- **Automated Triage:** Built-in guardrails detect and reject non-plant images to optimize API usage.
- **Organic Remediation:** Provides localized Fixes and organic farming advice.

### 📦 Neighborhood Aggregator (Logistics)
A sophisticated **DBSCAN Clustering Algorithm** that solves the "Micro-Batch" problem.
- **Bulk Pooling:** Automatically groups small surpluses (e.g., 500g from 20 houses) into a single high-volume hub (10kg) for bulk buyers.
- **FAMA Price Regulation:** Integrated price-cap engine based on Malaysian government standards (+20% max fluctuation) to prevent community price gouging.

### 📍 Hyper-Local Geo-Fencing (Spatial)
Utilizes **PostGIS** to restrict marketplace discovery to a walkable 3km-5km radius.
- **Zero Emission:** Eliminates the need for delivery riders by focusing on neighborhood-only transactions.
- **Real-time Map:** Interactive Material 3 Map with dynamic markers and integrated Google Maps directions.

### 🤝 Secure Marketplace Ledger (Trust)
A professional transaction system designed for community trust.
- **Mutual 2-Way Handshake:** Transactions are only finalized once **both** the seller and buyer verify delivery/pickup on-site.
- **Digital Receipts:** Generates professional chronological ledgers with unique Order IDs and precise timestamps.

---

## 🏗️ Technical Architecture

The platform follows a **Dockerized Microservices Architecture** for maximum scalability and fault isolation.

- **API Gateway (NGINX):** The secure entry point handling reverse-proxying, rate-limiting (10r/s), and internal microservice routing.
- **AI Service (FastAPI):** A high-performance Python service managing multimodal LLM interactions and computer vision logic.
- **Inventory Service (FastAPI):** A data science engine managing DBSCAN clustering and PostGIS spatial queries.
- **Database (Supabase):** Cloud-native PostgreSQL providing persistence and geo-spatial data types.
- **Frontend (Flutter):** A modern Material 3 mobile application supporting cross-platform Android and iOS deployment.

---

## 💻 System Deployment

### 1. Prerequisites
- **Docker & Docker Compose**
- **Flutter SDK (3.29+)**
- **Google Gemini API Key**

### 2. Infrastructure Setup
```bash
cd kebunkomuniti-core
docker-compose up --build
```
*The API Gateway will be listening on Port 80.*

### 3. Frontend Setup
Update the `api_service.dart` with your gateway address (Localhost or Ngrok URL) and run:
```bash
flutter pub get
flutter run
```

---

## 🛡️ Security Posture
- **Defense-in-Depth:** Multi-layered rate limiting at both the Gateway (NGINX) and Application (SlowAPI) levels.
- **Environment Isolation:** All secrets are managed via strictly ignored `.env` files.
- **Crash Protection:** Fail-safe database connection logic ensures the AI remains operational even if the cloud database is intermittently offline.

---

## 🗺️ Future Roadmap
- [ ] QR-Code Physical Handshake verification.
- [ ] Integrated Peer-to-Peer Chat Bridge.
- [ ] Push Notifications for nearby harvest alerts.
- [ ] Multi-neighborhood "Mega-Hub" scaling.

---
*Developed for PutraHack 2026. Built with 💚 for sustainable urban communities.*
