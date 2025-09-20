# FoodCoach Analytics Event Catalog

Complete list of all analytics events tracked in the FoodCoach app for nutrition tracking, user engagement, and performance monitoring.

## 📱 App Lifecycle Events

### Onboarding & Setup
- `app_open` - App launch
- `onboarding_started` - User starts onboarding
- `onboarding_completed` - User completes setup
- `consent_banner_shown` - GDPR consent displayed
- `consent_given` - User grants consent
- `notification_permission_granted` - Push notifications enabled
- `splash_screen_completed` - Initial loading finished

### User Properties
- `user_properties` - Core user attributes
- `pro_status` - Subscription state
- `diet_mode` - User's dietary preferences

## 🍎 Food Tracking Events

### Barcode Scanning
- `barcode_scan_started` - User opens scanner
- `barcode_scan_success` - Product successfully scanned
- `barcode_scan_failed` - Scanning error or product not found
- `product_lookup_success` - OpenFoodFacts data retrieved
- `product_lookup_failed` - API error or no data

### Food Logging
- `food_added` - User logs a food item
- `food_edited` - User modifies logged food
- `food_deleted` - User removes food entry
- `portion_selected` - Weight/portion chosen
- `meal_category_selected` - Breakfast/lunch/dinner/snack

### Nutrition Tracking
- `daily_goal_reached` - Calorie goal achieved
- `macro_goal_reached` - Protein/carb/fat target met
- `nutrition_report_viewed` - User checks progress
- `nutrition_export` - Data exported (PRO feature)

## 🔍 Search & Discovery
- `food_search_started` - Manual product search
- `food_search_results` - Search results displayed
- `food_search_selected` - Product chosen from search
- `popular_foods_viewed` - Trending products shown
- `category_browsed` - Food category explored

## 📊 Analytics & Reports
- `daily_summary_viewed` - Progress overview checked
- `weekly_report_generated` - Advanced analytics (PRO)
- `nutrition_trends_viewed` - Historical data analysis
- `goal_modified` - User changes targets
- `weight_tracking_updated` - Body weight logged

## 💰 Monetization Events
- `paywall_shown` - Subscription screen displayed
- `subscription_started` - User begins purchase flow
- `subscription_completed` - Payment successful
- `subscription_cancelled` - User cancels subscription
- `trial_started` - Free trial begins
- `trial_ended` - Trial period expires

## ⚙️ App Settings & Features
- `settings_opened` - User accesses settings
- `language_changed` - Localization updated
- `units_changed` - Metric/imperial toggle
- `notification_settings_changed` - Reminder preferences
- `privacy_settings_updated` - Data sharing preferences

## 🔔 Notifications
- `notification_sent` - Push notification delivered
- `notification_opened` - User taps notification
- `notification_dismissed` - User swipes away
- `reminder_snoozed` - Notification postponed
- `smart_reminder_triggered` - Context-aware notification

## 📱 Technical Events
- `app_version_updated` - New version installed
- `crash_reported` - App crash occurred
- `performance_issue` - Slow loading detected
- `api_error` - External service failure
- `sync_completed` - Cloud data synchronized

## 🎯 User Engagement
- `session_started` - App becomes active
- `session_ended` - App goes to background
- `feature_discovered` - New functionality used
- `tutorial_completed` - Help guide finished
- `feedback_submitted` - User review or rating

## 🏆 Achievements & Gamification
- `achievement_unlocked` - Milestone reached
- `streak_milestone` - Consecutive days logging
- `goal_streak` - Target achievement streak
- `sharing_action` - Social media share

## 🔧 Error Tracking
- `camera_permission_denied` - Scanner access blocked
- `storage_permission_denied` - Local data access blocked
- `network_error` - Internet connectivity issue
- `food_database_error` - OpenFoodFacts API failure
- `data_corruption_detected` - Local storage issue

## 📈 Custom Parameters

### Common Event Properties
- `user_id` - Anonymous user identifier
- `session_id` - Current app session
- `app_version` - Application version
- `platform` - iOS/Android
- `locale` - User language
- `timezone` - User timezone
- `subscription_status` - Free/PRO/Trial

### Food-Specific Properties
- `barcode` - Product barcode (hashed for privacy)
- `product_category` - Food type classification
- `nutrition_score` - Nutri-Score grade
- `calories_per_serving` - Caloric content
- `macro_distribution` - Protein/carb/fat percentages
- `portion_size` - Weight in grams

### Engagement Properties
- `screen_name` - Current app screen
- `action_source` - How user triggered action
- `time_spent` - Duration in current screen
- `scroll_depth` - How far user scrolled
- `tap_coordinates` - UI interaction location

## 🛠️ Implementation Notes

### Event Naming Convention
- Use lowercase with underscores
- Start with action verb when possible
- Include object being acted upon
- Keep names under 32 characters

### Parameter Guidelines
- Use consistent parameter names across events
- Limit to 25 parameters per event
- Use descriptive but concise names
- Include units for numeric values

### Privacy Considerations
- Hash all personally identifiable information
- Use anonymous user IDs only
- Respect user consent preferences
- Comply with GDPR/CCPA requirements

### Testing & Validation
- Test all events in debug mode
- Validate parameter types and ranges
- Check event firing timing
- Monitor for duplicate events

---

*This catalog is maintained as events are added or modified. Last updated: September 2025*