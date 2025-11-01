import { Controller } from "@hotwired/stimulus"
import { Calendar } from '@fullcalendar/core'
import dayGridPlugin from '@fullcalendar/daygrid'
import interactionPlugin from '@fullcalendar/interaction'

// Simple, clean FullCalendar integration for habit tracking
export default class extends Controller {
  static targets = ["calendar"]
  static values = {
    year: Number,
    month: Number
  }

  connect() {
    console.log("FullCalendar controller connected")
    this.initializeCalendar()
    this.loadHabitData()
    this.setupModalListeners()
  }

  disconnect() {
    if (this.calendar) {
      this.calendar.destroy()
    }
    this.removeModalListeners()
  }

  setupModalListeners() {
    // Get modal elements
    this.modal = document.getElementById('calendar-daily-modal')
    this.closeBtn = document.getElementById('modal-close-btn')

    if (!this.modal || !this.closeBtn) {
      console.warn("Modal elements not found")
      return
    }

    // Close on button click
    this.closeModalHandler = () => this.closeModal()
    this.closeBtn.addEventListener('click', this.closeModalHandler)

    // Close on backdrop click
    this.backdropClickHandler = (e) => {
      if (e.target === this.modal) {
        this.closeModal()
      }
    }
    this.modal.addEventListener('click', this.backdropClickHandler)

    // Close on Escape key
    this.escapeKeyHandler = (e) => {
      if (e.key === 'Escape' && !this.modal.classList.contains('hidden')) {
        this.closeModal()
      }
    }
    document.addEventListener('keydown', this.escapeKeyHandler)
  }

  removeModalListeners() {
    if (this.closeBtn && this.closeModalHandler) {
      this.closeBtn.removeEventListener('click', this.closeModalHandler)
    }
    if (this.modal && this.backdropClickHandler) {
      this.modal.removeEventListener('click', this.backdropClickHandler)
    }
    if (this.escapeKeyHandler) {
      document.removeEventListener('keydown', this.escapeKeyHandler)
    }
  }

  // Helper method to format date as YYYY-MM-DD in local timezone
  formatDateLocal(date) {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  initializeCalendar() {
    // Create FullCalendar instance
    this.calendar = new Calendar(this.calendarTarget, {
      plugins: [dayGridPlugin, interactionPlugin],
      initialView: 'dayGridMonth',
      headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: ''
      },

      // Set initial date if provided
      initialDate: new Date(this.yearValue, this.monthValue, 1),

      // Event handlers
      dateClick: (info) => this.handleDateClick(info),
      datesSet: (dateInfo) => this.handleMonthChange(dateInfo),

      // Render habit dots in day cells
      dayCellDidMount: (info) => this.renderHabitsInCell(info),

      // Styling
      height: 'auto',
      fixedWeekCount: false,

      // Don't display events as regular events
      eventDisplay: 'none'
    })

    this.calendar.render()
  }

  async loadHabitData() {
    try {
      // Get current calendar date
      const date = this.calendar.getDate()
      const year = date.getFullYear()
      const month = date.getMonth() + 1

      const url = `/habits/calendar.json?year=${year}&month=${month}`
      console.log('Fetching habit data from:', url)
      const response = await fetch(url)

      console.log("url is ", url)
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)

      const data = await response.json()
      console.log("response is ", data)
      console.log('Received habit data:', data)
      this.habits = data.habits || []

      // Dispatch events for stats and legend
      this.dispatch("habitsLoaded", { detail: { habits: this.habits } })
      this.dispatch("statsLoaded", { detail: data.stats })

      // Re-render all habit dots with the new data
      this.refreshHabitDots()

    } catch (error) {
      console.error("Error loading habit data:", error)
    }
  }

  renderHabitsInCell(info) {
    if (!this.habits || this.habits.length === 0) return

    const cellDate = info.date
    const cellMonth = cellDate.getMonth()
    const currentMonth = this.calendar.getDate().getMonth()

    // Only render for current month days
    if (cellMonth !== currentMonth) return

    const dayCell = info.el.querySelector('.fc-daygrid-day-frame')
    if (!dayCell) return

    // Remove any existing dots container to prevent duplicates
    const existingDots = dayCell.querySelector('.habit-dots-container')
    if (existingDots) {
      existingDots.remove()
    }

    // Format cell date as YYYY-MM-DD in local timezone to match backend format
    const cellDateString = this.formatDateLocal(cellDate)

    console.log(`Checking completions for date: ${cellDateString}`)

    // Find habits completed on this exact date
    const completedHabits = this.habits.filter(habit =>
      habit.completions && habit.completions.includes(cellDateString)
    )

    console.log('Completed habits:', completedHabits)

    if (completedHabits.length === 0) return

    console.log(`Rendering ${completedHabits.length} habits for date ${cellDateString}`)

    // Create container for habit dots
    const dotsContainer = document.createElement('div')
    dotsContainer.className = 'habit-dots-container'
    dotsContainer.style.cssText = 'display: flex; flex-wrap: wrap; gap: 3px; margin-top: 4px; justify-content: center;'

    // Create a dot for each completed habit
    completedHabits.forEach(habit => {
      const dot = document.createElement('div')
      dot.className = 'habit-dot'
      dot.style.backgroundColor = habit.color
      dot.title = habit.name
      dotsContainer.appendChild(dot)
    })

    // Append to day cell
    dayCell.appendChild(dotsContainer)
  }

  refreshHabitDots() {
    // Remove all existing habit dots
    const allDots = this.calendarTarget.querySelectorAll('.habit-dots-container')
    allDots.forEach(dot => dot.remove())

    // Re-render dots for all visible cells
    const dayCells = this.calendarTarget.querySelectorAll('.fc-daygrid-day')
    dayCells.forEach(cell => {
      const dateAttr = cell.getAttribute('data-date')
      if (!dateAttr) return

      const cellDate = new Date(dateAttr + 'T00:00:00')
      const cellMonth = cellDate.getMonth()
      const currentMonth = this.calendar.getDate().getMonth()

      // Only render for current month days
      if (cellMonth !== currentMonth) return

      const dayCell = cell.querySelector('.fc-daygrid-day-frame')
      if (!dayCell) return

      const cellDateString = dateAttr // Already in YYYY-MM-DD format

      // Find habits completed on this exact date
      const completedHabits = this.habits.filter(habit =>
        habit.completions && habit.completions.includes(cellDateString)
      )

      if (completedHabits.length === 0) return

      // Create container for habit dots
      const dotsContainer = document.createElement('div')
      dotsContainer.className = 'habit-dots-container'
      dotsContainer.style.cssText = 'display: flex; flex-wrap: wrap; gap: 3px; margin-top: 4px; justify-content: center;'

      // Create a dot for each completed habit
      completedHabits.forEach(habit => {
        const dot = document.createElement('div')
        dot.className = 'habit-dot'
        dot.style.backgroundColor = habit.color
        dot.title = habit.name
        dotsContainer.appendChild(dot)
      })

      // Append to day cell
      dayCell.appendChild(dotsContainer)
    })
  }

  handleDateClick(info) {
    console.log('Date clicked:', info.date)

    // Get all habits for this date
    const clickedDate = info.date
    const clickedDateString = this.formatDateLocal(clickedDate)

    // Find which habits were completed on this exact date
    const completedHabits = this.habits ? this.habits.filter(habit =>
      habit.completions && habit.completions.includes(clickedDateString)
    ) : []

    // Find which habits were missed on this date
    const missedHabits = this.habits ? this.habits.filter(habit =>
      !habit.completions || !habit.completions.includes(clickedDateString)
    ) : []

    console.log('Completed habits on', clickedDateString, ':', completedHabits)
    console.log('Missed habits:', missedHabits)

    // Open modal with the data
    this.openModal(clickedDate, completedHabits, missedHabits)
  }

  openModal(date, completedHabits, missedHabits) {
    if (!this.modal) {
      console.error("Modal not found")
      return
    }

    // Format date string
    const dateString = date.toLocaleDateString('en-US', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })

    // Update modal content
    const dateElement = document.getElementById('modal-date-string')
    const completedContainer = document.getElementById('modal-completed-habits')
    const missedContainer = document.getElementById('modal-missed-habits')

    if (dateElement) {
      dateElement.textContent = dateString
    }

    // Render completed habits
    if (completedContainer) {
      if (completedHabits.length === 0) {
        completedContainer.innerHTML = `
          <p class="text-sm text-text-secondary italic">
            No habits completed on this day
          </p>
        `
      } else {
        completedContainer.innerHTML = completedHabits.map(habit => `
          <div class="flex items-center space-x-2 p-2 rounded-lg bg-success-50">
            <div class="w-3 h-3 rounded-full" style="background-color: ${habit.color}"></div>
            <span class="text-sm text-text-primary">${this.escapeHtml(habit.name)}</span>
            <i class="fas fa-check text-success-600 ml-auto"></i>
          </div>
        `).join('')
      }
    }

    // Render missed habits
    if (missedContainer) {
      if (missedHabits.length === 0) {
        missedContainer.innerHTML = `
          <p class="text-sm text-success-600 italic">
            All habits completed! 🎉
          </p>
        `
      } else {
        missedContainer.innerHTML = missedHabits.map(habit => `
          <div class="flex items-center space-x-2 p-2 rounded-lg bg-gray-50">
            <div class="w-3 h-3 rounded-full" style="background-color: ${habit.color}"></div>
            <span class="text-sm text-text-primary">${this.escapeHtml(habit.name)}</span>
          </div>
        `).join('')
      }
    }

    // Show modal
    this.modal.classList.remove('hidden')
    document.body.style.overflow = 'hidden'
  }

  closeModal() {
    if (this.modal) {
      this.modal.classList.add('hidden')
      document.body.style.overflow = ''
    }
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  handleMonthChange(dateInfo) {
    // Calendar month changed - reload data
    const newDate = dateInfo.view.currentStart
    this.yearValue = newDate.getFullYear()
    this.monthValue = newDate.getMonth()

    console.log(`Month changed to: ${this.yearValue}-${this.monthValue + 1}`)

    // Clear habits data to prevent showing old data on new month
    this.habits = []

    // Clear all existing dots immediately
    const allDots = this.calendarTarget.querySelectorAll('.habit-dots-container')
    allDots.forEach(dot => dot.remove())

    // Load new data (which will call refreshHabitDots when complete)
    this.loadHabitData()
  }

  // Public methods for external controls
  goToToday() {
    this.calendar.today()
  }

  previousMonth() {
    this.calendar.prev()
  }

  nextMonth() {
    this.calendar.next()
  }
}
