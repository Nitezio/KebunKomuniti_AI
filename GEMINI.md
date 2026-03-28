# GEMINI.md - KebunKomuniti AI Project Context

## Project Progress Log
*Automatically updated by Project Manager skill.*

### Current Status: Infrastructure Initialized
- **Completed Tasks:**
  - Analyzed project requirements and DevSecOps architecture (Flutter, NGINX, FastAPI, Supabase).
  - Created initial `GEMINI.md` to establish foundational context, project architecture, and rules.
  - Implemented 3 specialized AI skills to enforce Role-Based Access Control (RBAC):
    - `project-manager`: Oversees tasks, manages state in `GEMINI.md`, tracks errors, and delegates work.
    - `devsecops-architect`: Strict infrastructure generation (`docker-compose.yml`, `nginx.conf`, `Dockerfile`).
    - `security-auditor`: Conducts read-only code reviews for frontend and backend logic.
  - **Infrastructure Phase 1 Complete:**
    - Generated `docker-compose.yml` for service orchestration.
    - Configured `gateway-nginx/nginx.conf` with reverse proxy, rate-limiting, and security headers.
    - Created optimized, lightweight `Dockerfile`s for `service-ai` and `service-inventory`.
    - Established standard directory structure.
- **Pending Tasks:**
  - **Waiting for Team Input:**
    - AI Lead to provide `service-ai/main.py` and `requirements.txt`.
    - Database Lead to provide `service-inventory/main.py` and `requirements.txt`.
    - Mobile Lead to provide `app-frontend` codebase for review.
  - Execute Git commit for initial infrastructure.
- **Errors/Fixes Required:** None.

---

## Project Overview
**KebunKomuniti AI** is an AI-driven community farming platform designed to enhance urban food security. It operates as a hyper-local aggregator, pooling small surpluses of home-grown produce into bulk orders for local restaurants and food banks. The platform also includes an AI "Plant Doctor" to assist urban farmers with gardening advice.

### Architecture
The project follows a **Dockerized Microservices Architecture** optimized for a RM0 (zero-cost) budget, utilizing Open Source Software (OSS) and free tiers of managed services.

- **Frontend:** Flutter Mobile App (cross-platform).
- **API Gateway:** NGINX (Reverse proxy, rate-limiting, secure routing).
- **Service A (AI Engine):** Python/FastAPI + Google Gemini 1.5 Flash API (Multimodal computer vision).
- **Service B (Inventory/Spatial):** Python/FastAPI + Supabase (PostgreSQL with PostGIS for geo-spatial queries).
- **Orchestration:** Docker Compose for local/demo environments.
- **Tunneling:** Ngrok (Exposes local NGINX to the internet for mobile testing).

## Building and Running

### Prerequisites
- Docker & Docker Compose
- Git
- Ngrok (for live demos)

### Key Commands
- **Initial Setup:**
  ```bash
  # Start the microservices ecosystem
  docker-compose up --build
  ```
- **Tunneling (Live Demo):**
  ```bash
  # Expose the NGINX gateway (assuming NGINX is on port 80/443)
  ngrok http 80
  ```
- **Git Workflow (Feature-Branch):**
  ```bash
  git pull origin main
  git checkout -b feature/your-feature-name
  # [Make changes]
  git add .
  git commit -m "feat: description of change"
  git push origin feature/your-feature-name
  ```

## Development Conventions

### Persona and Role Boundaries
- **Assistant Role:** Expert Site Reliability Engineer (SRE) and DevSecOps Lead.
- **Strict Boundaries:**
  - DO NOT write or architect Flutter/Dart UI code.
  - DO NOT write core Python business logic, AI prompts, or database schemas.
  - ONLY assist with infrastructure (`docker-compose.yml`, `Dockerfile`, `nginx.conf`), automation scripts, and security auditing.

### Coding Standards
- **Commit Messages:** Follow **Conventional Commits** (e.g., `feat:`, `fix:`, `chore:`, `sec:`). NEVER mention AI/Gemini or hackathon-specific event names in commit history.
- **Security-First:** Implement rate-limiting, secure headers, and structured logging in the gateway.
- **Zero-Cost Mandate:** All proposed solutions must utilize free tiers or open-source tools.

### Security Audit Protocol
When reviewing code snippets (Frontend/Backend), follow the **Security & Integration Auditor Mode**:
- **Audit Focus:** API keys leakage, input validation, SQLi, permissive CORS, and endpoint-to-gateway routing alignment.
- **Severity Classification:** Issues must be categorized as **CRITICAL**, **HIGH**, or **MODERATE**.
- **Reporting:** Provide a bulleted list of issues with professional explanations; do not rewrite the code unless specifically requested for infrastructure fixes.

## Project Structure
```text
/kebunkomuniti-core
  ├── /app-frontend          (Flutter mobile app)
  ├── /gateway-nginx         (NGINX configuration)
  │    └── nginx.conf
  ├── /service-ai            (AI/Vision FastAPI microservice)
  │    ├── main.py
  │    ├── requirements.txt
  │    └── Dockerfile
  ├── /service-inventory     (Geo-spatial/Inventory FastAPI microservice)
  │    ├── main.py
  │    ├── requirements.txt
  │    └── Dockerfile
  └── docker-compose.yml     (Orchestration)
```
