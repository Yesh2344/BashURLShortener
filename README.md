# BashURLShortener![Bash](https://img.shields.io/badge/bash-5.0%2B-brightgreen)![License](https://img.shields.io/badge/license-MIT-blue)

A lightweight, production‑ready URL shortener written entirely in Bash. 
It stores mappings in a SQLite database, provides a simple CLI, and includes
logging, configuration handling, and a test suite.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [API Documentation](#api-documentation)
- [Testing](#testing)
- [License](#license)

## Features

- **Fully self‑contained** – only Bash and SQLite are required.
- **CLI commands**: `shorten`, `expand`, `list`, `delete`.
- **Robust error handling** and **structured logging**.
- **Configurable** via `.env` file.
- **Unit tests** covering core functionality.

## Prerequisites

- Bash 5.0 or newer
- `sqlite3` command‑line client
- `curl` (optional, for URL validation)

## Installation