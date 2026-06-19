/// Returns the maximum phone number digits length for a given country ISO code.
/// Defaults to 15 (E.164 standard limit) if not explicitly matched.
int getPhoneNumberLengthLimit(String countryCode) {
  switch (countryCode.toUpperCase()) {
    case 'IN': // India
    case 'US': // USA
    case 'CA': // Canada
    case 'MX': // Mexico
    case 'FR': // France
    case 'IT': // Italy
    case 'ES': // Spain
    case 'UK': // United Kingdom
    case 'GB': // United Kingdom
    case 'JP': // Japan
    case 'KR': // South Korea
      return 10;
    case 'AU': // Australia
    case 'NZ': // New Zealand
    case 'SG': // Singapore
    case 'MY': // Malaysia
    case 'AE': // UAE
    case 'SA': // Saudi Arabia
    case 'ZA': // South Africa
    case 'CH': // Switzerland
    case 'NL': // Netherlands
    case 'BE': // Belgium
    case 'SE': // Sweden
    case 'NO': // Norway
    case 'DK': // Denmark
    case 'FI': // Finland
    case 'HK': // Hong Kong
      return 9;
    case 'DE': // Germany
    case 'RU': // Russia
    case 'BR': // Brazil
    case 'CN': // China
      return 11;
    default:
      return 15; // standard max length limit for E.164
  }
}
