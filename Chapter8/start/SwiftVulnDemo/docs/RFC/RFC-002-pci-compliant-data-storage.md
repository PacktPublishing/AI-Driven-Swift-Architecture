# RFC-002: PCI-DSS Compliant Data Storage & Logging

**Status:** DRAFT  
**RFC Number:** 002  
**Date:** 2024-02-02  
**Author:** [Security Reviewer]  
**Addresses:** ADR-002, PCI-DSS SAQ A-EP

---

## Problem Statement

The current AI-generated implementation violates PCI-DSS requirements by storing full card data (PAN, CVV, expiry) locally in plaintext files and logging sensitive data. This creates legal liability and exposes users to fraud.

## Critical Violations

| Violation | PCI-DSS Req. | CWE | Fine Risk |
|-----------|-------------|-----|-----------|
| CVV stored post-auth | 3.2 | CWE-312 | Up to $100K/month |
| Full PAN stored locally | 3.4 | CWE-312 | Up to $100K/month |
| Card data in logs | 3.3 | CWE-532 | Up to $50K/month |
| Insecure HTTP for payments | 4.1 | CWE-319 | Up to $100K/month |
| Card number in clipboard | 3.3 | CWE-200 | HIGH |

## Proposed Changes

### 1. Never Store CVV (PCI-DSS 3.2)

```swift
// ❌ Remove PaymentInfo model entirely
// ✅ Use tokenization: only store the last 4 digits + provider token

struct PaymentToken: Codable {
    let token: String          // From payment provider (Stripe, etc.)
    let last4Digits: String    // For display only
    let brand: CardBrand       // Visa, Mastercard, etc.
    let expiryMonth: Int       // OK to store
    let expiryYear: Int
    // NO cvv, NO full card number, NO cardholder name unless required
}
```

### 2. Encrypt Sensitive Files (CWE-312)

```swift
func saveEncrypted<T: Encodable>(_ value: T, filename: String) throws {
    let data = try JSONEncoder().encode(value)
    let key = try loadOrCreateEncryptionKey()
    let sealedBox = try AES.GCM.seal(data, using: key)
    let encrypted = sealedBox.combined!
    
    let url = documentsURL(filename)
    try encrypted.write(to: url, options: .completeFileProtection) // Data Protection
    
    // Exclude from iCloud backup
    var resourceValues = URLResourceValues()
    resourceValues.isExcludedFromBackup = true
    try url.setResourceValues(resourceValues)
}
```

### 3. Sanitize All Logging (CWE-532)

```swift
// ✅ Safe logging extension
extension String {
    var redacted: String {
        guard count > 4 else { return "****" }
        return String(repeating: "*", count: count - 4) + suffix(4)
    }
}

// Usage:
print("Payment for card: \(cardNumber.redacted)") // "************1234"
// Never log: CVV, full PAN, SSN, passwords, tokens
```

### 4. Clear Clipboard After Delay (CWE-200)

```swift
func copyToClipboard(_ value: String, clearAfter seconds: TimeInterval = 30) {
    UIPasteboard.general.string = value
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        if UIPasteboard.general.string == value {
            UIPasteboard.general.string = ""
        }
    }
}
```

### 5. Disable URLCache for Sensitive Requests (CWE-312)

```swift
func makeSecureRequest(url: URL) -> URLRequest {
    var request = URLRequest(url: url)
    request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    return request
}
```

## SonarQube Rules to Enforce

Add to `sonar-project.properties`:
```properties
sonar.issue.ignore.allfile=**/PaymentInfo.swift
# After deletion — track removal
sonar.swift.s2068.credentialWords=password,secret,key,token,cvv,ssn,pin
```

## Acceptance Criteria

- [ ] CVV never stored beyond payment flow
- [ ] No PAN in logs (verified by log scanner)
- [ ] All sensitive files use `.completeFileProtection`
- [ ] Files excluded from backup (verified by entitlement check)
- [ ] Clipboard cleared after 30 seconds
- [ ] PCI-DSS Self-Assessment Questionnaire A-EP passes
- [ ] SonarQube: 0 critical issues in DataStorageService.swift

## References

- PCI Security Standards Council: https://www.pcisecuritystandards.org
- OWASP Mobile Top 10: M2 (Insecure Data Storage)
- Apple Data Protection: https://developer.apple.com/documentation/uikit/protecting_the_user_s_privacy
