window.Scheduler =
  class Scheduler
    constructor: () ->
      @scheduleEl = $('#scheduler_schedule')
      $('.starts-on').on 'change', @startsOnChanged
      $('.rs_start_time button').on 'click', (e) ->
        if e.target.id == 'rs_am'
          $('#rs_am').addClass('btn-primary')
          $('#rs_pm').removeClass('btn-primary')
        else
          $('#rs_pm').addClass('btn-primary')
          $('#rs_am').removeClass('btn-primary')
        $('.starts-on').trigger 'change'
      $('#start-date').datetimepicker
        timepicker: false
        format: 'm/d/Y'
      $('#start-time').datetimepicker
        datepicker: false
        format: 'h:i'
        formatTime: 'h:i'
        hours12: true
        step: 10
      $('#rs_end_date').datetimepicker
        timepicker: false
        format: 'm/d/Y'
      $('#rs_end_date').on 'change', @endOnDateChanged

    schedule: {}

    cancel: =>
      @outer_holder.remove()

    outerCancel: (event) =>
      if $(event.target).hasClass('rs_dialog_holder')
        @cancel()

    # =================== Schedule management methods ====================

    readSchedule: ->
      @schedule = JSON.parse(@scheduleEl.val())
      @current_rule = @schedule.rrules[0]

    writeSchedule: ->
      @schedule.rrules[0] = @current_rule if @current_rule
      @scheduleEl.val JSON.stringify(@schedule)

    # ======================= Init methods ===============================

    initDialog: ->
      @readSchedule()
      @outer_holder = $('.rs_dialog_holder')
      @inner_holder = @outer_holder.find '.rs_dialog'
      @content = @outer_holder.find '.rs_dialog_content'
      @footer = @outer_holder.find '.rs_dialog_footer'
      @mainEventInit();
      @freqInit()
      @summaryInit();
      @freq_select.focus()
      @positionDialogVert(true)
      @outer_holder.trigger 'recurring_select:dialog_opened'

    positionDialogVert: (initial_positioning) =>
      window_height = $(window).height()
      window_width = $(window).width()
      dialog_height = @content.outerHeight()
      if dialog_height < 80
        dialog_height = 80
      margin_top = (window_height - dialog_height)/2 - 115
      margin_top = 10 if margin_top < 10
      # if dialog_height > window_height - 20
      # dialog_height = window_height - 20

      new_style_hash =
        'margin-top' : margin_top+'px'
        'min-height' : dialog_height+'px'

      if initial_positioning?
        @inner_holder.css new_style_hash
        @inner_holder.trigger 'recurring_select:dialog_positioned'
      else
        @content.css {'width': @content.width()+'px'}
        @inner_holder.addClass 'animated'
        @inner_holder.animate new_style_hash, 200, =>
          @inner_holder.removeClass 'animated'
          @content.css {'width': 'auto'}
          @inner_holder.trigger 'recurring_select:dialog_positioned'

    mainEventInit: ->
      # Tap hooks are for jQueryMobile
      @outer_holder.on 'click tap', @outerCancel
      @content.on 'click tap', 'h1 a', @cancel
      @footer.find('input.rs_cancel').on 'click tap', @cancel

    freqInit: ->
      @freq_select = @outer_holder.find '.rs_frequency'
      if @current_rule? && (rule_type = @current_rule.rule_type)?
        @endInit()
        if rule_type.search(/Daily/) != -1
          @initDailyOptions()
        else if rule_type.search(/Weekly/) != -1
          @initWeeklyOptions()
        else if rule_type.search(/Monthly/) != -1
          @initMonthlyOptions()
        else if rule_type.search(/Yearly/) != -1
          @initYearlyOptions()
      else
        @initNeverOptions()
      @freq_select.off 'click', @freqChanged
      @freq_select.on 'click', @freqChanged

    initNeverOptions: ->
      $('#rs_repeats_never').addClass('btn-primary')

      @current_rule = null
      @schedule.rrules = []

    initDailyOptions: ->
      $('#rs_repeats_daily').addClass('btn-primary')

      section = @content.find('.daily_options')
      interval_input = section.find('.rs_daily_interval')
      interval_input.val(@current_rule.interval)
      interval_input.off 'change keyup', @intervalChanged
      interval_input.on 'change keyup', @intervalChanged
      section.show()

    initWeeklyOptions: ->
      $('#rs_repeats_weekly').addClass('btn-primary')

      section = @content.find('.weekly_options')

      # connect the interval field
      interval_input = section.find('.rs_weekly_interval')
      interval_input.val(@current_rule.interval)
      interval_input.off 'change keyup', @intervalChanged
      interval_input.on 'change keyup', @intervalChanged

      # connect the day fields
      section.off 'click', '.day_holder a', @daysChanged # to avoid multiple bindings
      @content.find('.day_holder').children().each ->
        $(@).removeClass('selected')
      if @current_rule.validations? && @current_rule.validations.day?
        $(@current_rule.validations.day).each (index, val) ->
          section.find(".day_holder a[data-value='"+val+"']").addClass('selected')
      section.off 'click', '.day_holder a', @daysChanged
      section.on 'click', '.day_holder a', @daysChanged

      section.show()

    initMonthlyOptions: ->
      $('#rs_repeats_monthly').addClass('btn-primary')

      section = @content.find('.monthly_options')
      interval_input = section.find('.rs_monthly_interval')
      interval_input.val(@current_rule.interval)
      interval_input.off 'change keyup', @intervalChanged
      interval_input.on 'change keyup', @intervalChanged

      @current_rule.validations ||= {}
      @current_rule.validations.day_of_month ||= []
      @current_rule.validations.day_of_week ||= {}
      @init_calendar_days(section)
      @init_calendar_weeks(section)

      in_week_mode = Object.keys(@current_rule.validations.day_of_week).length > 0
      if in_week_mode
        $('#rs_monthly_rule_type_week').addClass('btn-primary')
      else
        $('#rs_monthly_rule_type_day').addClass('btn-primary')
      @content.find('.rs_calendar_week').toggle(in_week_mode)
      @content.find('.rs_calendar_day').toggle(!in_week_mode)
      section.find('.monthly_rule_type .btn-group').off 'click', @toggle_month_view
      section.find('.monthly_rule_type .btn-group').on 'click', @toggle_month_view
      section.show()

    initYearlyOptions: ->
      $('#rs_repeats_yearly').addClass('btn-primary')

      section = @content.find('.yearly_options')
      interval_input = section.find('.rs_yearly_interval')
      interval_input.val(@current_rule.interval)
      interval_input.off 'change keyup', @intervalChanged
      interval_input.on 'change keyup', @intervalChanged
      section.show()

    endInit: ->
      @content.find('.rs_ends_block').show()
      @content.find('.rs_ends_options').show()
      @content.find('.rs_ends_after').hide()
      @content.find('.rs_ends_date').hide()
      @end_select = @outer_holder.find '.rs_ends'

      @end_select.children().each ->
        $(@).removeClass('btn-primary')

      if @current_rule.count?
        @initEndAfterOptions()
      else if @current_rule.until?
        @initEndOnDateOptions()
      else
        @initNeverEndOptions()
      @end_select.off 'click', @endChanged # to avoid multiple bindings
      @end_select.on 'click', @endChanged

    initEndAfterOptions: ->
      $('#rs_ends_after').addClass('btn-primary')

      section = @content.find('.rs_ends_after')
      count_input = section.find('.rs_ends_after_interval')
      count_input.val(@current_rule.count)
      count_input.off 'change keyup', @countEndChanged
      count_input.on 'change keyup', @countEndChanged
      section.show()

    initEndOnDateOptions: ->
      $('#rs_ends_date').addClass('btn-primary')

      section = @content.find('.rs_ends_date')
      until_input = section.find('#rs_end_date')
      until_input.val(new Date(@current_rule.until.time).toLocaleDateString('en-us'))
      section.show()

    initNeverEndOptions: ->
      $('#rs_ends_never').addClass('btn-primary')

    summaryInit: ->
      @summary = @outer_holder.find('.rs_summary p')
      @summaryUpdate()

    # ====================== Render methods ================================

    summaryUpdate: =>
      $.ajax
        url: '/schedulers/update_summary',
        type: 'POST',
        beforeSend: (xhr) ->
          token = $('meta[name="csrf-token"]').attr('content')
          if token
            xhr.setRequestHeader('X-CSRF-Token', token)
        data: { schedule: JSON.stringify(@schedule) }
        success: @summarySuccess

    summarySuccess: (data) =>
      @summary.html data

    init_calendar_days: (section) =>
      monthly_calendar = section.find('.rs_calendar_day')
      monthly_calendar.html ''
      for num in [1..31]
        monthly_calendar.append (day_link = $(document.createElement('a')).text(num))
        if $.inArray(num, @current_rule.validations.day_of_month) != -1
          day_link.addClass('selected')

      # add last day of month button
      monthly_calendar.append (end_of_month_link = $(document.createElement('a')).text('Last day'))
      end_of_month_link.addClass('end_of_month btn')
      if $.inArray(-1, @current_rule.validations.day_of_month) != -1
        end_of_month_link.addClass('selected')

      monthly_calendar.find('a').off 'click tap', @dateOfMonthChanged
      monthly_calendar.find('a').on 'click tap', @dateOfMonthChanged

    init_calendar_weeks: (section) =>
      monthly_calendar = section.find('.rs_calendar_week')
      monthly_calendar.html ''
      row_labels = ['1st', '2nd', '3rd', '4th']
      cell_str = ['S', 'M', 'T', 'W', 'T', 'F', 'S']

      for num in [1..4]
        monthly_calendar.append "<span>#{row_labels[num - 1]}</span>"
        for day_of_week in [0..6]
          day_link = $('<a>', {text: cell_str[day_of_week]})
          day_link.attr('day', day_of_week)
          day_link.attr('instance', num)
          monthly_calendar.append day_link
      $.each @current_rule.validations.day_of_week, (key, value) ->
        $.each value, (index, instance) ->
          section.find("a[day='#{key}'][instance='#{instance}']").addClass('selected')
      monthly_calendar.find('a').off 'click tap', @weekOfMonthChanged
      monthly_calendar.find('a').on 'click tap', @weekOfMonthChanged

    toggle_month_view: (e) =>
      switch e.target.id
        when 'rs_monthly_rule_type_day'
          $('#rs_monthly_rule_type_day').addClass('btn-primary')
          $('#rs_monthly_rule_type_week').removeClass('btn-primary')
          week_mode = false
        when 'rs_monthly_rule_type_week'
          $('#rs_monthly_rule_type_week').addClass('btn-primary')
          $('#rs_monthly_rule_type_day').removeClass('btn-primary')
          week_mode = true
      @content.find('.rs_calendar_week').toggle(week_mode)
      @content.find('.rs_calendar_day').toggle(!week_mode)

    # ====================== Change callbacks ==============================

    freqChanged: (e) =>
      @current_rule = null unless $.isPlainObject(@current_rule) # for custom values

      @content.find('.rs_frequency').children().each ->
        $(@).removeClass('btn-primary')

      @current_rule ||= {}
      @current_rule.interval = 1
      @current_rule.until = null
      @current_rule.count = null
      @current_rule.validations = null
      @content.find('.freq_option_section').hide();
      @content.find('input[type=radio], input[type=checkbox]').prop('checked', false)

      @endInit()

      switch e.target.id
        when 'rs_repeats_weekly'
          @current_rule.rule_type = 'IceCube::WeeklyRule'
          @initWeeklyOptions()
        when 'rs_repeats_monthly'
          @current_rule.rule_type = 'IceCube::MonthlyRule'
          @initMonthlyOptions()
        when 'rs_repeats_yearly'
          @current_rule.rule_type = 'IceCube::YearlyRule'
          @initYearlyOptions()
        when 'rs_repeats_daily'
          @current_rule.rule_type = 'IceCube::DailyRule'
          @initDailyOptions()
        else
          @initNeverOptions()
          @content.find('.rs_ends_block').hide()
      @positionDialogVert()
      @writeSchedule()
      @summaryUpdate()

    endChanged: (e) =>
      @content.find('.rs_ends').children().each ->
        $(@).removeClass('btn-primary')

      @current_rule ||= {}
      @current_rule.until = null
      @current_rule.count = null
      @content.find('.rs_ends_after').hide();
      @content.find('.rs_ends_date').hide();
      switch e.target.id
        when 'rs_ends_after'
          @current_rule.count = 1
          @initEndAfterOptions()
        when 'rs_ends_date'
          @current_rule.until = {}
          @current_rule.until.time = new Date(Date.now()).toISOString()
          @current_rule.until.zone = @schedule.start_time.zone
          @initEndOnDateOptions()
        else
          @initNeverEndOptions()
      @positionDialogVert()
      @writeSchedule()
      @summaryUpdate()

    intervalChanged: (event) =>
      @current_rule ||= {}
      @current_rule.interval = parseInt($(event.currentTarget).val())
      if @current_rule.interval < 1 || isNaN(@current_rule.interval)
        @current_rule.interval = 1
        # $(event.currentTarget).val(@current_rule.interval)
      @writeSchedule()
      @summaryUpdate()

    countEndChanged: (event) =>
      @current_rule ||= {}
      @current_rule.count = parseInt($(event.currentTarget).val())
      if @current_rule.count < 1 || isNaN(@current_rule.count)
        @current_rule.count = 1
        # $(event.currentTarget).val(@current_rule.count)
      @writeSchedule()
      @summaryUpdate()

    daysChanged: (event) =>
      $(event.currentTarget).toggleClass('selected')
      @current_rule ||= {}
      @current_rule.validations = {}
      raw_days = @content.find('.day_holder a.selected').map -> parseInt($(this).data('value'))
      @current_rule.validations.day = raw_days.get()
      @writeSchedule()
      @summaryUpdate()
      false # this prevents default and propogation

    dateOfMonthChanged: (event) =>
      $(event.currentTarget).toggleClass('selected')
      @current_rule ||= {}
      @current_rule.validations = {}
      raw_days = @content.find('.monthly_options .rs_calendar_day a.selected').map ->
        res = if $(this).text() == 'Last day' then -1 else parseInt($(this).text())
        res
      @current_rule.validations.day_of_week = {}
      @current_rule.validations.day_of_month = raw_days.get()
      @writeSchedule()
      @summaryUpdate()
      false

    weekOfMonthChanged: (event) =>
      $(event.currentTarget).toggleClass('selected')
      @current_rule ||= {}
      @current_rule.validations = {}
      @current_rule.validations.day_of_month = []
      @current_rule.validations.day_of_week = {}
      @content.find('.monthly_options .rs_calendar_week a.selected').each (index, elm) =>
        day = parseInt($(elm).attr('day'))
        instance = parseInt($(elm).attr('instance'))
        @current_rule.validations.day_of_week[day] ||= []
        @current_rule.validations.day_of_week[day].push instance
      @writeSchedule()
      @summaryUpdate()
      false

    startsOnChanged: =>
      startTimeString = $('#start-time').val() + ' ' + $('.rs_start_time .btn-primary').text()
      timeZone = $('#time-zone').val()
      timeString = [
        $('#start-date').val()
        startTimeString
        timeZone
      ].join(' ')
      startTime = new Date(Date.parse(timeString))
      @schedule.start_time.time = startTime.toISOString()
      @writeSchedule()
      @summaryUpdate()

    endOnDateChanged: =>
      timeZone = $('#time-zone').val()
      timeString = [
        @content.find('#rs_end_date').val()
        '11:59 pm'
        timeZone
      ].join(' ')
      endOnDate = new Date(Date.parse(timeString))
      @current_rule.until.time = endOnDate.toISOString()
      @writeSchedule()
      @summaryUpdate()
