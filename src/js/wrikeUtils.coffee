app = require './app'

wrikeUtils =
  me: -> $wrike.user.getUid()

  myTaskRoles: (task) ->
    roleConditions =
      owner: => task.data['responsibleList'].indexOf(@me()) >= 0
      author: => (task.get 'author') is @me()

    return (role for role, condition of roleConditions when condition())

  currentUserIsResponsibleForTask: (task) -> ((@myTaskRoles task).indexOf 'owner') >= 0

  currentTaskView: ->
    taskViewId = $('.wspace-task-view').attr 'id'
    if taskViewId?
      window.Ext.ComponentMgr.get taskViewId

  currentTask: -> @currentTaskView()?['record']

  onTaskViewRender: (callback) ->
    cb = (taskView) -> callback taskView["record"], taskView
    taskViewClass = window.w2.folders.info.task.View
    app.api.aspect.before taskViewClass, "showRecord", ->  cb @

    currentTaskView = @getCurrentTaskView()
    if currentTaskView?
      cb currentTaskView

  onCurrentTaskChange: (callback) ->
    app.api.wait.change (=> @currentTask()), (task) ->
      if task?
        app.api.wait.once (-> task.data.title?), ->
          callback task

  onCurrentTaskSave: (callback) ->
    app.api.aspect.after $wrike.record.Base.prototype, 'getChanges', ->
      if @ is wrikeUtils.currentTask()
        callback @

module.exports = wrikeUtils
