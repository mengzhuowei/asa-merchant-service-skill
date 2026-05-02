---
name: asa-merchant-service
description: Use when interacting with ASA Merchant Service merchant/shop APIs, including product browse, order lifecycle, payment, email-auth, merchant onboarding, and merchant console management.
---

# ASA Merchant Service Skill

Follow this workflow when the user asks to query, create, update, or troubleshoot merchant/shop data on ASA Merchant Service.

## Source of Truth

- Read `references/api-external.md` before calling any endpoint.
- Treat endpoint path, request schema, and response fields in that file as authoritative.

## API Domains

- Shop API (agent-facing): `/shop/{merchant_id}`
- Merchant Console API (admin-facing): `/merchant`

## Required Checks Before Any Call

1. Confirm which API domain is needed (`/shop` vs `/merchant`).
2. Confirm required authentication type for the target endpoint.
3. Confirm required identifiers (`merchant_id`, `product_id`, `order_id`, `payment_order_id`, etc.).
4. Confirm required request fields and validation constraints.

## Authentication Rules

- For `/shop/{merchant_id}` endpoints:
  - Use `Authorization: Bearer <access_token>` when OAuth 2.0 is available.
  - Or use `X-API-Key: <api_key>` when API key flow is provided.
  - `try/*` endpoints can be called without auth.
- For `/merchant` endpoints:
  - Login first, then send `Authorization: Bearer <jwt_token>`.

## Execution Rules

1. For list endpoints, use pagination (`offset`, `limit`) and return both `data` and `total` when provided.
2. Use ISO 8601 timestamps as documented.
3. On non-2xx response, return normalized error details: HTTP status, `code`, and `message`.
4. Respect rate limiting and handle `429 RATE_LIMIT_EXCEEDED` with retry strategy.

## High-Frequency Workflows

1. Product browse: list products -> get product details.
2. Order workflow: create order -> query order -> cancel or fulfill depending on status.
3. Payment workflow: list methods -> create payment order -> query status -> close/refund when needed.
4. Email auth workflow: request code -> verify code -> refresh session -> get user info -> logout.
5. Merchant ops workflow: admin login -> manage products/orders/settlements/config.

## Response Quality Standard

1. Return concise operational result first (success/failure + key identifiers).
2. Then return structured data fields relevant to the user goal.
3. Include next actionable step when workflow is incomplete (for example payment pending -> poll payment order status).

## Safety Rules

- Never invent fields, statuses, or endpoints not present in `references/api-external.md`.
- If required data is missing, ask for the exact missing identifier/value before proceeding.
- If endpoint semantics are ambiguous, quote the relevant section from `references/api-external.md` and proceed conservatively.