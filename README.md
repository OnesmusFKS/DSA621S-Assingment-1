# DSA612S Assignment 1 — Distributed Library & Rental System

## Structure

```
DSA612S-Assignment1/
├── Q1-Library-System/
│   ├── backend/     -> models.bal, service.bal   (Lucia)
│   ├── client/      -> client.bal                (Octa)
│   └── tests/
├── Q2-Rental-System/
│   ├── proto/       -> rental.proto              (Lavinia, Manfred)
│   ├── server/      -> models.bal, service.bal   (Onesmus)
│   ├── client/      -> client.bal                (Johannes)
│   └── tests/
└── documentation/
    ├── architecture/
    ├── testing/
    └── screenshots/
```

## Build order

1. **Q2-Rental-System/proto/rental.proto** first — nothing in Q2 compiles without it.
   Run `bal grpc --input rental.proto --output .` inside `server/` (and again in
   `client/`) to generate the stub types referenced in `service.bal` / `client.bal`.
2. **Q1-Library-System/backend** — get plain CRUD on `/assets` working before
   adding filtering, maintenance, components, schedules, work orders.
3. Clients (`Q1.../client`, `Q2.../client`) only after their backend/server compiles
   and runs — they're both currently stubs that just define the menu shape.
4. Everything marked `// TODO` is where the actual logic goes — the models,
   endpoints, and RPC signatures are already shaped to match the assignment brief
   and mark allocation, so nobody has to re-decide the contract mid-project.

## Branches

`main`, `q1-backend`, `q1-client`, `q2-proto`, `q2-server`, `q2-client`, `testing`.
No direct commits to `main` — PR + review + merge.
