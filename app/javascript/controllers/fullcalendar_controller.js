import { Controller } from "@hotwired/stimulus"
import { Calendar } from '@fullcalendar/core'
import dayGridPlugin from '@fullcalendar/daygrid'
import interactionPlugin from '@fullcalendar/interaction'

export default class extends Controller {
  static targets = ["calendar"]
  static values = { year: Number, month: Number }

  connect() {
    this.visibleHabitIds = new Set() // Track which habits are visible
    this.allVisible = true // Track if all habits are shown
    this.initializeCalendar()
    this.loadHabitData()
    this.setupModal()
    this.setupToggleListeners()
  }

  disconnect() {
    this.calendar?.destroy()
    this.cleanupModal()
    this.cleanupToggleListeners()
  }

  // Calendar initialization
  initializeCalendar() {
    this.calendar = new Calendar(this.calendarTarget, {
      plugins: [dayGridPlugin, interactionPlugin],
      initialView: 'dayGridMonth',
      initialDate: new Date(this.yearValue, this.monthValue, 1),
      headerToolbar: { left: 'prev,next today', center: 'title', right: '' },
      dateClick: (info) => this.handleDateClick(info),
      datesSet: (dateInfo) => this.handleMonthChange(dateInfo),
      dayCellDidMount: (info) => this.renderHabitsInCell(info),
      height: 'auto',
      fixedWeekCount: false,
      eventDisplay: 'none'
    })
    this.calendar.render()
  }

  // Data loading
  async loadHabitData() {
    try {
      const date = this.calendar.getDate()
      const url = `/habits/calendar.json?year=${date.getFullYear()}&month=${date.getMonth() + 1}`
      const response = await fetch(url)

      if (!response.ok) throw new Error(`HTTP ${response.status}`)

      const data = await response.json()
      this.habits = data.habits || []

      // Initialize all habits as visible
      this.visibleHabitIds = new Set(this.habits.map(h => h.id))
      this.allVisible = true

      this.dispatch("habitsLoaded", { detail: { habits: this.habits } })
      this.dispatch("statsLoaded", { detail: data.stats })
      this.refreshHabitDots()
      this.updateHabitLegend()
      this.updateMonthlyStats(data.stats)
    } catch (error) {
      console.error("Error loading habits:", error)
    }
  }

  // Habit dots rendering
  renderHabitsInCell(info) {
    if (!this.habits?.length || !this.isCurrentMonth(info.date)) return

    const dayCell = info.el.querySelector('.fc-daygrid-day-frame')
    if (!dayCell) return

    dayCell.querySelector('.habit-dots-container')?.remove()

    const dateString = this.formatDate(info.date)
    const completedHabits = this.habits.filter(h =>
      h.completions?.includes(dateString) && this.visibleHabitIds.has(h.id)
    )

    if (completedHabits.length > 0) {
      dayCell.appendChild(this.createDotsContainer(completedHabits))
    }
  }

  refreshHabitDots() {
    this.calendarTarget.querySelectorAll('.habit-dots-container').forEach(el => el.remove())

    this.calendarTarget.querySelectorAll('.fc-daygrid-day').forEach(cell => {
      const dateAttr = cell.getAttribute('data-date')
      if (!dateAttr) return

      const cellDate = new Date(dateAttr + 'T00:00:00')
      if (!this.isCurrentMonth(cellDate)) return

      // Filter by visible habits
      const completedHabits = this.habits.filter(h =>
        h.completions?.includes(dateAttr) && this.visibleHabitIds.has(h.id)
      )
      if (completedHabits.length === 0) return

      const dayCell = cell.querySelector('.fc-daygrid-day-frame')
      if (dayCell) dayCell.appendChild(this.createDotsContainer(completedHabits))
    })
  }

  createDotsContainer(habits) {
    const container = document.createElement('div')
    container.className = 'habit-dots-container'
    container.style.cssText = 'display: flex; flex-wrap: wrap; gap: 3px; margin-top: 4px; justify-content: center;'

    habits.forEach(habit => {
      const dot = document.createElement('div')
      dot.className = 'habit-dot'
      dot.style.backgroundColor = habit.color
      dot.title = habit.name
      container.appendChild(dot)
    })

    return container
  }

  // Modal handling
  setupModal() {
    this.modal = document.getElementById('calendar-daily-modal')
    this.closeBtn = document.getElementById('modal-close-btn')

    if (!this.modal || !this.closeBtn) return

    this.closeBtn.addEventListener('click', this.closeModal.bind(this))
    this.modal.addEventListener('click', (e) => e.target === this.modal && this.closeModal())
    document.addEventListener('keydown', this.handleEscape = (e) => {
      if (e.key === 'Escape' && !this.modal.classList.contains('hidden')) this.closeModal()
    })
  }

  cleanupModal() {
    this.closeBtn?.removeEventListener('click', this.closeModal)
    this.handleEscape && document.removeEventListener('keydown', this.handleEscape)
  }

  // Toggle listeners
  setupToggleListeners() {
    this.toggleAllBtn = document.getElementById('toggle-all-habits')
    if (this.toggleAllBtn) {
      this.toggleAllHandler = () => this.toggleAllHabits()
      this.toggleAllBtn.addEventListener('click', this.toggleAllHandler)
    }

    // Setup event delegation for habit clicks
    this.legendList = document.getElementById('habits-legend-list')
    if (this.legendList) {
      this.habitClickHandler = (e) => {
        const habitItem = e.target.closest('[data-habit-id]')
        if (habitItem) {
          const habitId = parseInt(habitItem.dataset.habitId)
          this.toggleHabit(habitId)
        }
      }
      this.legendList.addEventListener('click', this.habitClickHandler)
    }
  }

  cleanupToggleListeners() {
    if (this.toggleAllBtn && this.toggleAllHandler) {
      this.toggleAllBtn.removeEventListener('click', this.toggleAllHandler)
    }
    if (this.legendList && this.habitClickHandler) {
      this.legendList.removeEventListener('click', this.habitClickHandler)
    }
  }

  toggleAllHabits() {
    this.allVisible = !this.allVisible

    if (this.allVisible) {
      // Show all habits
      this.visibleHabitIds = new Set(this.habits.map(h => h.id))
      this.toggleAllBtn.textContent = 'Hide All'
    } else {
      // Hide all habits
      this.visibleHabitIds.clear()
      this.toggleAllBtn.textContent = 'Show All'
    }

    this.refreshHabitDots()
    this.updateHabitLegend()
  }

  toggleHabit(habitId) {
    if (this.visibleHabitIds.has(habitId)) {
      this.visibleHabitIds.delete(habitId)
    } else {
      this.visibleHabitIds.add(habitId)
    }

    // Update toggle all button text
    if (this.toggleAllBtn) {
      this.allVisible = this.visibleHabitIds.size === this.habits.length
      this.toggleAllBtn.textContent = this.allVisible ? 'Hide All' : 'Show All'
    }

    this.refreshHabitDots()
    this.updateHabitLegend()
  }

  handleDateClick(info) {
    const dateString = this.formatDate(info.date)
    const today = this.formatDate(new Date())
    const isToday = dateString === today

    // Categorize habits by their status on this date
    const completed = this.habits?.filter(h => h.completions?.includes(dateString)) || []
    const skipped = this.habits?.filter(h => h.skipped?.includes(dateString)) || []

    // Not logged only shows for TODAY
    let notLogged = []
    if (isToday) {
      notLogged = this.habits?.filter(h =>
        !h.completions?.includes(dateString) &&
        !h.skipped?.includes(dateString) &&
        !h.drafts?.includes(dateString)
      ) || []
    }

    this.openModal(info.date, completed, skipped, notLogged, isToday)
  }

  openModal(date, completed, skipped, notLogged, isToday) {
    if (!this.modal) return

    const dateStr = date.toLocaleDateString('en-US', {
      weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
    })

    this.updateElement('modal-date-string', dateStr)
    this.renderHabitList('modal-completed-habits', completed, 'completed')
    this.renderHabitList('modal-skipped-habits', skipped, 'skipped')
    this.renderHabitList('modal-not-logged-habits', notLogged, 'not-logged')

    // Show/hide "Not Logged" section based on whether it's today
    const notLoggedSection = document.getElementById('modal-not-logged-section')
    if (notLoggedSection) {
      notLoggedSection.style.display = isToday ? 'block' : 'none'
    }

    this.modal.classList.remove('hidden')
    document.body.style.overflow = 'hidden'
  }

  closeModal() {
    if (this.modal) {
      this.modal.classList.add('hidden')
      document.body.style.overflow = ''
    }
  }

  renderHabitList(elementId, habits, status) {
    const container = document.getElementById(elementId)
    if (!container) return

    if (habits.length === 0) {
      const emptyMessages = {
        'completed': '<p class="text-sm text-text-secondary italic">No habits completed</p>',
        'skipped': '<p class="text-sm text-text-secondary italic">No habits skipped</p>',
        'not-logged': '<p class="text-sm text-success-600 italic">All habits logged! 🎉</p>'
      }
      container.innerHTML = emptyMessages[status] || ''
      return
    }

    const styles = {
      'completed': { bg: 'bg-success-50', icon: '<i class="fas fa-check text-success-600 ml-auto"></i>' },
      'skipped': { bg: 'bg-warning-50', icon: '<i class="fas fa-ban text-warning-600 ml-auto"></i>' },
      'not-logged': { bg: 'bg-gray-50', icon: '<i class="fas fa-circle text-gray-300 ml-auto"></i>' }
    }

    const style = styles[status] || styles['not-logged']

    container.innerHTML = habits.map(h => `
      <div class="flex items-center space-x-2 p-2 rounded-lg ${style.bg}">
        <div class="w-3 h-3 rounded-full" style="background-color: ${h.color}"></div>
        <span class="text-sm text-text-primary">${this.escape(h.name)}</span>
        ${style.icon}
      </div>
    `).join('')
  }

  // Habit legend updates
  updateHabitLegend() {
    const legendList = document.getElementById('habits-legend-list')
    const todayCount = document.getElementById('habits-today-count')

    if (!legendList) return

    const today = this.formatDate(new Date())
    const completedToday = this.habits.filter(h => h.completions?.includes(today))

    // Update today count
    if (todayCount) {
      todayCount.textContent = `${completedToday.length} completed today`
    }

    // Render habits list
    if (this.habits.length === 0) {
      legendList.innerHTML = `
        <div class="text-center py-4">
          <p class="text-sm text-text-secondary">No active habits found</p>
          <a href="/habits/items" class="text-primary-600 hover:text-primary-700 text-sm font-medium">
            Create your first habit
          </a>
        </div>
      `
      return
    }

    legendList.innerHTML = this.habits.map(habit => {
      const isVisible = this.visibleHabitIds.has(habit.id)
      const isCompletedToday = habit.completions?.includes(today)
      const borderClass = isCompletedToday ? 'border-success-300 bg-success-50/50' : 'border-gray-100'
      const opacityClass = isVisible ? '' : 'opacity-40'
      const eyeIcon = isVisible ? 'fas fa-eye text-primary-600' : 'fas fa-eye-slash text-gray-400'
      const streakHtml = habit.current_streak > 0 ? `
        <span class="flex items-center gap-1">
          <i class="fas fa-fire text-accent-600"></i>
          <span>${habit.current_streak}</span>
        </span>
      ` : ''

      return `
        <div data-habit-id="${habit.id}" 
             class="flex items-center justify-between p-3 rounded-lg border ${borderClass} ${opacityClass} hover:bg-gray-50 transition-all duration-200 cursor-pointer">
          <div class="flex items-center space-x-3 flex-1">
            <div class="w-4 h-4 rounded-full flex-shrink-0" style="background-color: ${habit.color}"></div>
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-text-primary truncate">${this.escape(habit.name)}</p>
              <div class="flex items-center gap-3 text-xs text-text-secondary mt-0.5">
                <span>${habit.completion_count}/${habit.total_days} days</span>
                ${streakHtml}
              </div>
            </div>
          </div>
          <i class="${eyeIcon} flex-shrink-0"></i>
        </div>
      `
    }).join('')
  }

  // Monthly stats updates
  updateMonthlyStats(stats) {
    if (!stats) return

    this.updateElement('stat-completion-rate', `${stats.completion_rate}%`)
    this.updateElement('stat-best-streak', stats.best_streak)
    this.updateElement('stat-total-habits', stats.total_habits)
  }

  // Month change handler
  handleMonthChange(dateInfo) {
    const newDate = dateInfo.view.currentStart
    this.yearValue = newDate.getFullYear()
    this.monthValue = newDate.getMonth()
    this.habits = []
    this.calendarTarget.querySelectorAll('.habit-dots-container').forEach(el => el.remove())
    this.loadHabitData()
  }

  // Utilities
  formatDate(date) {
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
  }

  isCurrentMonth(date) {
    return date.getMonth() === this.calendar.getDate().getMonth()
  }

  updateElement(id, text) {
    const el = document.getElementById(id)
    if (el) el.textContent = text
  }

  escape(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  // Public API
  goToToday() { this.calendar.today() }
  previousMonth() { this.calendar.prev() }
  nextMonth() { this.calendar.next() }
}
