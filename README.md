# WALL UP

## Introduction
WALL UP is an application designed for climbing gym owners and bouldering enthusiasts, providing a platform to manage and engage with the indoor climbing community.

### For Gym Owners:
- Create a digital presence for their gym.
- Add a customizable profile and location map.
- Upload and manage active boulders.

### For Bouldering Enthusiasts:
- Track progress and rate boulder problems.
- Engage with other climbers through chat.
- Build a strong gym community.

---

## Features

### User Management
- Login/registration with email and password.
- Profile customization (name, gender, profile picture, gym preference).

### Interactive Climbing Map
- SVG-based dynamic map.
- Zoom in/out functionality.
- Clickable sectors revealing boulders.
- Filtering by difficulty level, color, and sector.

### Boulder Info & Tracking
- Users can mark boulders as "flashed" or "completed."
- Flash actions include animations and sound effects.
- Rate boulder difficulty and view rating charts.
- "Topped By" section displaying climbers who completed the route.

### Ranking System
- Leaderboard for top climbers in the past two months.
- Skill level tracking based on completed boulders.
- Progress tracking toward the next skill level.

### Chat System
- Post, comment, and engage with other climbers.
- "Your Posts" section to view personal activity.
- Supports real-time interaction.

### Personal Statistics
- Displays tops, flashes, and visits.
- Charts for monthly points and boulder difficulty distribution.
- Highlights top 10 boulders completed in the past two months.

### Gym Profiles
- Gym logo, photos, and rating.
- Opening hours and real-time status.
- Route distribution by difficulty.
- Interactive address and navigation support.

### Settings & Accessibility
- Dark Mode toggle.
- "Report Issue" functionality.
- Video guide for map usage.
- Privacy Policy & Terms of Service.
- Account deletion option.

---

## Ranking & Points System
- Climbers' rankings are based on the average score of their top 10 hardest boulders completed in the last two months.
- Points are awarded based on difficulty and flash bonus:
  - Example: Completing a 6A boulder earns 80 points.
  - Flash Bonus: Extra 20% points if flashed.

---

## Testing & Performance
The app includes a comprehensive suite of tests:

### Unit Tests
- GymChatModel: Validates chat functionalities.
- ChartsViewModel: Ensures correct data generation.
- ProfileView: Checks user statistics and boulder tracking.

### Smoke Tests
- MapView: Ensures map loads and filters correctly.
- BoulderInfo: Validates data integrity of boulders and sectors.

### UI Tests
- Login/Register Views: Checks form validation and authentication.
- RankingView: Ensures leaderboard displays correctly.

### Performance Tests
- Database queries and UI responsiveness tests for scalability.

---

## Contributing
We welcome contributions! To get started:
1. Fork the repository.
2. Create a new branch (`feature-xyz`).
3. Commit your changes.
4. Open a pull request.

---

## License
This project is licensed under the MIT License. See `LICENSE` for details.

---

## Contact
For issues or suggestions, please open an issue on GitHub or contact the development team.

