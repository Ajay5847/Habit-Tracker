# 🌱 Habit Tracker

A modern, full-featured habit tracking application built with Ruby on Rails 8 and Hotwire. Track your daily habits, visualize your progress, and build consistent routines with an intuitive interface.

## ✨ Features

- **User Authentication**: Secure sign-up/sign-in with email/password and Google OAuth integration
- **Habit Management**: Create, organize, and manage your habits with custom tags
- **Daily Dashboard**: View today's habits with "In Progress" and "Completed" status tracking
- **Calendar View**: Monthly calendar overview with completion statistics including:
  - Completion rate percentage
  - Best streak tracking
  - Total habits count
- **Search & Filter**: Search habits by name and filter by tags
- **Responsive Design**: Modern, dark-themed UI that works across devices
- **Real-time Updates**: Powered by Hotwire (Turbo & Stimulus) for seamless interactions

## 🚀 Live Demo

Visit the live application: [https://habit-tracker-ohfv.onrender.com/](https://habit-tracker-ohfv.onrender.com/)

**Demo Credentials:**
- Email: demouser@demo.com
- Password: demouser

## 🔧 Installation

1. **Clone the repository**
```bash
git clone https://github.com/Ajay5847/Habit-Tracker.git
cd Habit-Tracker
```

2. **Install dependencies**
```bash
bundle install
yarn install
```

3. **Environment Configuration**

Create a `.env` file in the root directory:
```env
DATABASE_URL=postgresql://username:password@localhost/habit_tracker
```

4. **Database Setup**
```bash
rails db:create
rails db:migrate
rails db:seed  # Optional: load sample data
```

5. **Start the development server**
```bash
bin/dev
```

The application will be available at `http://localhost:3000`

## 🙏 Acknowledgments

- Built with Ruby on Rails
- UI inspired by modern habit tracking applications
- Powered by Hotwire for real-time interactions
