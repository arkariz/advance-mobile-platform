# Mobile Platform

A modular **mobile platform repository** designed to support multiple applications through shared architecture, reusable components, and standardized development practices.

This repository acts as the foundation for mobile apps by centralizing core logic, infrastructure integrations, and reusable packages.

---

## 🏗️ Architecture Overview

The project follows a modular and layered approach

### Key Principles

- Separation of Concerns (Core vs Infrastructure)
- Reusability across multiple apps
- Scalability for future features and apps
- Consistency in architecture and coding standards

---

## 🚀 Tech Stack

- Flutter 3.41.6 (managed via FVM)
- Dart 3.11.4
- Melos 7.5.1 (monorepo & package orchestration)

---

## 📦 Monorepo Management (Melos)

This project uses Melos to manage multiple packages in a single repository.

### Common Commands

- Bootstrap all packages  
  melos bootstrap

- Run analyze across all packages  
  melos run analyze

- Run tests across all packages  
  melos run test

- Clean all packages  
  melos run clean

---

## 🎯 Flutter Version Management (FVM)

We use FVM to ensure consistent Flutter SDK versions across the team.

### Setup

- Install FVM  
  dart pub global activate fvm

- Install Flutter version (defined in .fvmrc)  
  fvm install 3.41.6

- Use the configured Flutter version  
  fvm use 3.41.6

### Usage

Always run Flutter commands through FVM:

- fvm flutter pub get  
- fvm flutter run  
- fvm flutter test  

---

## ⚙️ Getting Started

### 1. Clone Repository

git clone git@gitlab.bankcapital.co.id:mobile-services/mobile-platform.git
cd mobile-platform

### 2. Setup Environment

- Setup Flutter version  
  fvm install 3.41.6 && fvm use 3.41.6

- Install dependencies  
  melos bootstrap  

---

## 📁 Package Structure Guidelines

Each module/package should follow:

- Clear responsibility (no mixed concerns)
- Minimal dependencies between layers
- Reusable and testable design

---

## 🤝 Contributing

Guidelines:

1. Follow existing architecture patterns  
2. Keep modules decoupled  
3. Write tests for critical logic  
4. Avoid introducing cross-layer dependencies  