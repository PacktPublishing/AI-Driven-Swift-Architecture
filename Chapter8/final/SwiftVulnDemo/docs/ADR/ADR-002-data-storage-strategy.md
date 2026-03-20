# ADR-002: Sensitive Data Storage Strategy

**Status:** ACCEPTED  
**Date:** 2024-01-16  
**Author:** AI Assistant  
**Reviewers:** ⚠️ NOT REVIEWED

---

## Context

The app handles highly sensitive data: passwords, credit card numbers, CVV codes, and Social Security Numbers. A storage strategy must be chosen.

## Decision

All sensitive data stored in **plaintext JSON files** in the app's Documents directory. Payment info cached in **URLCache**. Logs written to **unencrypted .log files** in Documents.

## ⚠️ Security Issues Introduced

| Issue | CWE | OWASP Mobile | Severity |
|-------|-----|--------------|----------|
| PII in plaintext files | CWE-312 | M2: Insecure Data Storage | CRITICAL |
| PCI data stored locally | CWE-312 | M2 | CRITICAL |
| Files not excluded from iCloud backup | CWE-312 | M2 | HIGH |
| SSN/card data in debug logs | CWE-532 | M2 | CRITICAL |
| Predictable temp file names | CWE-377 | M2 | MEDIUM |
| Card number in clipboard (never cleared) | CWE-200 | M2 | HIGH |
| No Data Protection entitlement | CWE-312 | M2 | HIGH |

## Consequences

- Any device backup exposes all PII
- Forensic analysis of device yields plaintext card numbers
- Other apps may read clipboard with card data
- Log files readable by any tool with filesystem access

## What Should Have Been Done

```swift
// ✅ Correct: Store secrets in Keychain
let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrAccount as String: "auth_token",
    kSecValueData as String: tokenData,
    kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
]

// ✅ Correct: Exclude from backup
var resourceValues = URLResourceValues()
resourceValues.isExcludedFromBackup = true
try url.setResourceValues(resourceValues)

// ✅ Correct: Use Data Protection
try data.write(to: url, options: .completeFileProtection)
```

---

*ADR created by AI without security review. Demonstrates why AI-generated architectural decisions require mandatory human security review before implementation.*
