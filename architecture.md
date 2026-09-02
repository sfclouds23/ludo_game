# Ludo Application Architecture

## Purpose

This document defines the architectural boundaries and dependency rules for the Flutter client.

The goal is to keep the application maintainable as it grows across Android, iOS, and Web, while preserving clear separation between game rules, application state, presentation, networking, and platform infrastructure.

---

## Top-Level Structure

```text
lib/
├── app/
├── core/
├── features/
├── shared/
└── main.dart