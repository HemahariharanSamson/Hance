# Hance - Smart Transaction Manager

A Flutter-based fintech application that automatically scans SMS messages to track and categorize financial transactions, providing users with intelligent insights into their spending patterns.

## Features

### 🔍 Smart SMS Scanning
- Automatic detection of transaction SMS from banks and financial institutions
- Real-time parsing of transaction details (amount, merchant, account, timestamp)
- Support for both debit and credit transactions
- Intelligent filtering to avoid duplicate entries

### 📊 Transaction Management
- **Active Transactions**: View and manage pending transactions
- **Transaction History**: Complete record of all processed transactions
- **Cancelled Transactions**: Track deleted/cancelled transactions
- Card-based UI with swipe gestures for easy navigation

### 📈 Analytics & Insights
- Monthly and yearly spending analysis
- Category-wise transaction breakdown
- Interactive charts and visualizations using FL Chart
- Customizable date range selection

### 🗓️ Calendar Integration
- Monthly calendar view for transaction tracking
- Day-wise transaction filtering
- Visual indicators for transaction dates

### 📰 Financial News
- Real-time financial news integration
- Curated news feed relevant to personal finance
- Refresh functionality for latest updates

### 🎨 Modern UI/UX
- Professional fintech design with custom color palette
- Smooth animations and transitions
- Card-based layout with intuitive navigation
- Responsive design for various screen sizes

## Technology Stack

### Framework & Language
- **Flutter**: Cross-platform mobile app development
- **Dart**: Programming language

### State Management & Storage
- **Hive**: Local database for transaction storage
- **Native SMS Integration**: Android SMS permissions and scanning

### UI Components
- **Flutter Card Swiper**: Interactive card navigation
- **FL Chart**: Data visualization and analytics
- **Font Awesome Flutter**: Icon library

### Network & External Integration
- **HTTP Package**: API calls for news and external data
- **URL Launcher**: External link handling

## Installation

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- Android device or emulator (Android 6.0+)

### Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/hance.git
   cd hance
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Android Permissions**
   
   Add the following permissions to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.RECEIVE_SMS" />
   <uses-permission android:name="android.permission.READ_SMS" />
   <uses-permission android:name="android.permission.INTERNET" />
   ```

4. **Set up Native SMS Channel**
   
   The app uses a method channel (`sms_channel`) to communicate with native Android code for SMS access. Ensure you have the corresponding native Android implementation.

5. **Build and Run**
   ```bash
   flutter run
   ```

## App Structure

### Main Components

#### 1. **MainScreen**
- Central hub with bottom navigation
- Manages four main sections: Analytics, Transactions, Calendar, News
- Handles SMS scanning and transaction processing

#### 2. **Transaction Processing**
- Automatic SMS parsing with regex patterns
- Smart categorization (Food, Utility, Transport, Shopping, etc.)
- Duplicate detection and prevention

#### 3. **Data Storage**
- Three main Hive boxes:
  - `transactions`: Active pending transactions
  - `history`: Completed transaction history
  - `cancelled`: Deleted/cancelled transactions

#### 4. **Analytics Engine**
- Monthly and yearly spending analysis
- Category-wise breakdown
- Interactive charts and graphs

### Color System

The app uses a professional fintech color palette:
- **Primary**: Blue (#2563eb)
- **Accent**: Teal/Green (#10b981)
- **Background**: Light grey (#f4f6fa)
- **Surface**: White (#ffffff)
- **Text**: Dark grey (#22223b)

## Usage

### First Launch
1. **Onboarding**: New users see a welcome screen
2. **Permission Request**: App requests SMS permissions
3. **Initial Scan**: Automatic scan of today's SMS for transactions
4. **Dashboard Setup**: Analytics and transaction views are populated

### Daily Usage
1. **Automatic Detection**: App continuously monitors SMS for new transactions
2. **Transaction Review**: Users can review, categorize, or delete transactions
3. **Analytics Viewing**: Check spending patterns and trends
4. **News Updates**: Stay informed with financial news

### Transaction Actions
- **Swipe Cards**: Navigate through transactions
- **Tap to Expand**: View detailed transaction information
- **Delete**: Remove unwanted transactions
- **Categorize**: Assign categories for better analytics

## Permissions

### Required Permissions
- **SMS Read**: To scan transaction SMS
- **SMS Receive**: To detect new transaction messages
- **Internet**: For news updates and external API calls

### Privacy & Security
- All transaction data is stored locally using Hive
- No transaction data is sent to external servers
- SMS scanning is performed locally on device

## Development

### Key Files
- `main.dart`: App entry point and theme configuration
- `MainScreen`: Core application logic and UI
- `AppColors`: Centralized color system
- Transaction parsing logic with regex patterns

### Adding New Features
1. **New Transaction Sources**: Extend regex patterns in `_parseTransactionFromSms`
2. **Additional Categories**: Update category system in `AppColors`
3. **Enhanced Analytics**: Add new chart types using FL Chart
4. **External Integrations**: Implement new API endpoints

## API Integration

### News API
The app fetches financial news from external APIs. Configure your news API endpoint in the HTTP requests section.

### Method Channels
- `sms_channel`: Native Android SMS operations
- `requestSmsPermissions`: Request SMS access
- `getTodaySms`: Fetch today's SMS messages
- `getPendingTransactions`: Load pending transactions

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Deployment

### Android Release
1. **Build APK**
   ```bash
   flutter build apk --release
   ```

2. **Build App Bundle**
   ```bash
   flutter build appbundle --release
   ```

3. **Sign and Deploy** to Google Play Store

## Troubleshooting

### Common Issues
1. **SMS Permission Denied**: Ensure permissions are granted in device settings
2. **No Transactions Detected**: Check SMS formats and regex patterns
3. **Storage Issues**: Clear Hive boxes if data corruption occurs
4. **Chart Rendering**: Ensure FL Chart dependencies are properly installed

### Debug Mode
Enable debug logging to trace SMS parsing and transaction processing:
```dart
print('Parsing SMS: $text');
print('Extracted transaction: $transaction');
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Open an issue on GitHub
- Email: hemahariharansamson@gmail.com

## Acknowledgments

- Flutter team for the amazing framework
- Hive for local storage solution
- FL Chart for beautiful visualizations
- Font Awesome for comprehensive icons

---

**Hance** - Making financial management effortless through intelligent automation.