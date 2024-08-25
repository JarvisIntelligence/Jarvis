# Jarvis App

An AI-powered application for users to summarize notes.

## Technologies and Packages Used

Refer to the `pubspec.yaml` file for the complete list of packages and their versions. Major packages used include:

- **Encrypt**: For encrypting data stored on the user's phone using various encryption algorithms, such as AES with PKCS7 padding.
- **Provider**: For app state management in areas such as the homepage and theme mode.
- **Flutter Sound** and **Just Audio**: For managing the recording and playback of voice recordings.
- **Sqflite**: For database management, used to store and manage data like encrypted messages and chat lists.

## Project File Structure

- **lib/**: Contains the main application code.
  - **components/**: Data components that may be reused across different pages in the app.
    - **Utilities/**: Utility functions and classes.
    - **ChangeNotifiers/**: Functions that help implement the provider state management across different parts of the app.
    - **AIChats/**: UI screens/pages for the AI aspect of the app.
    - **SettingsComponents/**: UI screens/pages for the app's settings.
  - **pages/**: UI screens/pages for the app.
  - **Themes/**: Dark and Light Mode configurations for the app.
- **assets/**: Contains assets such as images and fonts.
- **fonts/**: Contains font assets such as Inter.

## Architecture of the Application

### Encryption Architecture

Jarvis App emphasizes end-to-end encryption to protect user messages before storage or transmission. The `encrypt` package is used due to resource constraints.

**How Encryption Works in the Application:**

The `encrypt` package is managed through a Singleton class that handles encryption key generation and retrieval from secure storage. This key is used for both encrypting and decrypting data.

- **Encryption**: Uses AES with a unique initialization vector (IV) for each piece of data.
- **Decryption**: Reverses the encryption process using the same key and IV.
- **Storage**: Encrypted data is stored in the `Sqflite` database to ensure data at rest is protected.

Future updates will include a review of the encryption process to cover data transmission and key management for complete end-to-end encryption.

### Database Architecture

Given the potential large volume of data, such as chat messages and contact lists, `Sqflite` is used for database management. Initially, `Flutter Secure Storage` was considered but proved unsuitable for large datasets.

`Sqflite` uses SQL syntax and management systems. Helper classes for database operations are located in the 'SqfliteHelperClasses' folder under 'Utilities':

- **contactListDatabaseHelper**
- **chatListDatabaseHelper**

