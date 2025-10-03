# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**DNOTAS_APP** is a client-facing mobile/web application designed to replace WhatsApp as the primary communication channel between an ERP/accounting company and its clients. The company handles fiscal note emissions (NF-e/NFC-e) and accounting services for multiple clients identified by CNPJ (Brazilian tax ID).

## Project Structure

```
DNOTAS_APP/
├── APP/               # Mobile application (Flutter - iOS/Android)
├── SITE/              # Management website for company team (Vue.js)
├── APIS_APP/          # Backend API endpoints (to be developed)
├── REFERENCIAS/       # UI/UX reference images and company logo
└── README            # Project specification and requirements
```

## Development Philosophy

This is a **greenfield project** being built incrementally. The README file contains the complete specification divided into 7 parts (PARTE 0-7). Each part should be implemented sequentially:

- **PARTE 0**: Database structure (PostgreSQL) and client registration/login
- **PARTE 1**: General objectives and UI/UX guidelines
- **PARTE 2**: WhatsApp-like chat with notifications
- **PARTE 3**: NF-e/NFC-e request system
- **PARTE 4**: API integration for automated messages
- **PARTE 5**: User inactivity tracking
- **PARTE 6**: Financial area (boletos/payments)
- **PARTE 7**: Security (JWT, bcrypt, HTTPS)

## Key Architecture Decisions

### Technology Stack
- **Mobile App (APP/)**: Flutter (supports both iOS and Android from single codebase)
- **Management Website (SITE/)**: Vue.js (for company team to manage operations)
- **Backend (APIS_APP/)**: To be defined (will serve both app and website)
- **Database**: PostgreSQL

### Database
- **PostgreSQL** for all data storage
- CNPJ is the primary identifier for client-related operations
- Create tables incrementally as features are developed (see README PARTE 0)

### Multi-Branch Architecture (Matriz/Filiais)
- The company operates with **headquarters (Matriz)** and **branches (Filiais)**
- Each branch manages its own set of clients independently
- **Data isolation by branch**:
  - Matriz sees only matriz clients (e.g., 100 clients)
  - Filial 1 sees only filial 1 clients (e.g., 50 clients)
  - Filial 2 sees only filial 2 clients (e.g., 75 clients)
- **SITE/ login authentication** must include branch identification
- All database queries for client management must filter by branch/filial
- Each employee/user account is associated with a specific branch
- Branch ID must be stored alongside CNPJ for proper data segregation

### Authentication & Security
- JWT for authentication
- bcrypt for password hashing
- HTTPS required for production
- Index CNPJ columns for performance

### Backend (APIS_APP)
- Create API endpoints as needed for each feature
- Protected internal routes for company-to-client automated messages
- Support for multiple content types: text, images (reports), PDFs (invoices)
- Must serve both Flutter app and Vue.js management site

### Key Features
1. **Chat System**: WhatsApp-like interface with message history, file sharing, and notifications
2. **NF-e/NFC-e Requests**: Client-initiated fiscal note requests with status tracking
3. **Notifications**: Triggered by new messages, reports, invoices, payment due dates, and inactivity
4. **Financial Dashboard**: View boletos, pending payments, receipts

## UI/UX Guidelines

Reference designs are in `REFERENCIAS/`. The app should have:
- **Dark theme** with white/gray contrast elements
- Modern typography emphasizing numbers and values
- Central company logo/banner card
- Direct action buttons (Send, Receive, Request NF)
- Transaction/conversation list with status icons
- Bottom navigation bar with icons:
  - 💬 Chat
  - 📤 Request NF
  - 📁 Reports
  - 📊 Financial
  - ⚙️ Settings

## Development Workflow

1. Read the README thoroughly to understand the current development phase
2. API endpoints should be created in `APIS_APP/` as features require them
3. Database schemas should be generated using PostgreSQL CREATE TABLE commands when needed
4. Follow the sequential part structure (PARTE 0 → PARTE 7)
5. **Data isolation is critical**:
   - All client operations filter by CNPJ
   - All management operations (SITE) filter by Branch/Filial ID
   - Employee accounts are tied to specific branches

## Important Notes

- The project is written in **Portuguese (Brazilian)** - maintain this for user-facing content
- **APP/** folder contains the Flutter mobile application (iOS/Android)
- **SITE/** folder contains the Vue.js management website for company team
- **APIS_APP/** contains backend that serves both frontend applications
- Company specializes in fiscal note emission and accounting services for clients

## Project Components

### APP/ (Flutter Mobile)
- Client-facing mobile application
- Built with Flutter for cross-platform support (iOS + Android)
- Main features: Chat, NF requests, Reports, Financial dashboard
- Consumes REST APIs from APIS_APP

### SITE/ (Vue.js Website)
- Management interface for company team
- Built with Vue.js
- Features: Client management, message broadcasting, request handling, analytics
- Administrative panel to manage all client interactions
- **Branch-based access control**:
  - Login requires branch/filial identification
  - Users only see and manage clients from their assigned branch
  - Matriz employees manage matriz clients only
  - Filial employees manage their respective filial clients only

### APIS_APP/ (Backend)
- RESTful API serving both APP and SITE
- Handles authentication, data persistence, file storage
- Business logic for NF-e/NFC-e processing
- Real-time notifications and chat functionality
