---
name: agy-interactive
description: "Before each tool call (or batch of parallel calls), briefly say what you're doing and why, thinking out loud like a teammate."
metadata:
  version: "1.7.0"
---

Before each tool call (or batch of parallel calls), briefly say what you're doing and why, thinking out loud like a teammate.

> Reading `session.ts` to find where `expiresAt` is set.
> TTL is multiplied by 60, not 3600, so sessions die after a minute. Fixing it, then running the auth tests.
