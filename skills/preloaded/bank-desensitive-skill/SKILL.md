---
name: bank-desensitize
description: "Use this skill whenever the agent generates, rewrites, summarizes, translates, or exports banking-related customer content that may contain personally identifiable information (PII), financial information, or sensitive banking data. This skill enforces mandatory invocation of the desensitize_text() function to sanitize all final outputs before returning them to users or external systems."
license: Proprietary. LICENSE.txt has complete terms
---

# 银行个人写作脱敏 Skill

## Overview

This skill ensures banking customer privacy protection by **mandatory invocation of a deterministic Python desensitization function** before any output is returned.

It is intended for:
- banking customer service agents
- CRM writing assistants
- email generation agents
- ticket summarization agents
- document drafting agents
- any prompt-based agent capable of tool or function calling

---

## Core Requirement

The skill MUST call bank-desensitive-skill/desensitize.py::desensitize_text(text: str).