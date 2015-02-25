function init(){var require=(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({"addon":[function(require,module,exports){
var Reminder, calendarUtils, container, createCalendarSelect, createNotificationCheck, createTimeSelect, draw, drawAuthorization, drawReminderEditControl, drawReminderView, drawRemindersContainer, icons, reminder, removeRemindersContainer, start, taistApi, updateReminderForTask, wrikeUtils;

taistApi = null;

container = null;

reminder = null;

start = function(ta) {
  taistApi = ta;
  return calendarUtils.init(function() {
    wrikeUtils.onCurrentTaskChange(function(task) {
      return draw(task);
    });
    return wrikeUtils.onCurrentTaskSave(function(updatedTask) {
      return updateReminderForTask(updatedTask);
    });
  });
};

draw = function(task) {
  removeRemindersContainer();
  if (wrikeUtils.currentUserIsResponsibleForTask(task)) {
    reminder = new Reminder(task);
    if (reminder.canBeSet()) {
      drawRemindersContainer();
      if (!calendarUtils.authorized()) {
        return drawAuthorization();
      } else {
        return reminder.load(function() {
          return drawReminderView();
        });
      }
    }
  }
};

updateReminderForTask = function(task) {
  var reminderToUpdate;
  if (calendarUtils.authorized()) {
    reminderToUpdate = new Reminder(task);
    return reminderToUpdate.load(function() {
      return reminderToUpdate.updateForTask();
    });
  }
};

Reminder = (function() {
  Reminder._calendarsList = null;

  Reminder.prototype._reminderData = null;

  Reminder.prototype._defaultSettings = null;

  function Reminder(_task) {
    this._task = _task;
  }

  Reminder.prototype.load = function(callback) {
    return Reminder._loadCalendars((function(_this) {
      return function() {
        return _this._loadReminderData(function() {
          return callback();
        });
      };
    })(this));
  };

  Reminder.prototype.exists = function() {
    return this._reminderData != null;
  };

  Reminder._loadCalendars = function(callback) {
    if (this._calendarsList == null) {
      return calendarUtils.loadCalendars((function(_this) {
        return function(calendarsList) {
          _this._calendarsList = calendarsList;
          return callback();
        };
      })(this));
    } else {
      return callback();
    }
  };

  Reminder.prototype._loadReminderData = function(callback) {
    this._reminderData = null;
    return taistApi.userData.get("defaultSettings", (function(_this) {
      return function(error, defaultSettingsData) {
        _this._defaultSettings = defaultSettingsData;
        return taistApi.userData.get(_this._task.data.id, function(error, existingReminderData) {
          var calendarId, eventId;
          eventId = existingReminderData != null ? existingReminderData.eventId : void 0;
          calendarId = existingReminderData != null ? existingReminderData.calendarId : void 0;
          if ((eventId == null) || (calendarId == null)) {
            return callback();
          } else {
            return calendarUtils.getEvent(eventId, calendarId, function(event) {
              var eventIsActual;
              eventIsActual = (event != null) && event.status !== "cancelled";
              if (eventIsActual) {
                _this._reminderData = {
                  event: event,
                  calendarId: calendarId
                };
              }
              return callback();
            });
          }
        });
      };
    })(this));
  };

  Reminder.prototype.canBeSet = function() {
    return this._getRawBaseValue() != null;
  };

  Reminder.prototype._getBaseDateTime = function() {
    return new Date(this._getRawBaseValue());
  };

  Reminder.prototype._getRawBaseValue = function() {
    var ref;
    return (ref = this._task.data["startDate"]) != null ? ref : this._task.data["finishDate"];
  };

  Reminder.prototype.getDisplayData = function() {
    var addLeadingZero, currentSettings, hours, hoursRange, i, len, minutes, minutesRange, notification, ref, ref1, ref2, ref3, ref4, reminderTime, usedNotifications;
    ref = this.exists() ? (addLeadingZero = function(number) {
      if (number < 10) {
        return "0" + number;
      } else {
        return number;
      }
    }, reminderTime = new Date(this._reminderData.event.start.dateTime), [addLeadingZero(reminderTime.getHours()), addLeadingZero(reminderTime.getMinutes())]) : ['08', '00'], hours = ref[0], minutes = ref[1];
    hoursRange = ['06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23'];
    minutesRange = ['00', '15', '30', '45'];
    currentSettings = this._reminderData != null ? {
      calendardId: this._reminderData.calendarId,
      reminders: this._reminderData.event.reminders
    } : this._defaultSettings;
    usedNotifications = {};
    ref3 = (ref1 = currentSettings != null ? (ref2 = currentSettings.reminders) != null ? ref2.overrides : void 0 : void 0) != null ? ref1 : [];
    for (i = 0, len = ref3.length; i < len; i++) {
      notification = ref3[i];
      usedNotifications[notification.method] = true;
    }
    return {
      hours: hours,
      minutes: minutes,
      hoursRange: hoursRange,
      minutesRange: minutesRange,
      usedNotifications: usedNotifications,
      calendars: Reminder._calendarsList,
      currentCalendar: (ref4 = currentSettings != null ? currentSettings.calendarId : void 0) != null ? ref4 : Reminder._calendarsList[0].id
    };
  };

  Reminder.prototype["delete"] = function(callback) {
    if (this.exists()) {
      return calendarUtils.deleteEvent(this._reminderData.event.id, this._reminderData.calendarId, (function(_this) {
        return function() {
          _this._reminderData = null;
          return callback();
        };
      })(this));
    }
  };

  Reminder.prototype.set = function(hours, minutes, calendarId, useSms, useEmail, callback) {
    var eventStartDate, notifications;
    eventStartDate = this._getBaseDateTime();
    eventStartDate.setHours(hours, minutes);
    notifications = [];
    if (useSms) {
      notifications.push("sms");
    }
    if (useEmail) {
      notifications.push("email");
    }
    return this._setByDateTime(eventStartDate, calendarId, notifications, callback);
  };

  Reminder.prototype._setByDateTime = function(eventStartDate, newCalendarId, notifications, callback) {
    var eventData, i, len, method, newCallback, ref, ref1;
    eventData = (ref = (ref1 = this._reminderData) != null ? ref1.event : void 0) != null ? ref : {};
    eventData.summary = this._task.data["title"];
    eventData.start = {
      dateTime: eventStartDate
    };
    eventData.end = {
      dateTime: eventStartDate
    };
    eventData.description = "Task link: https://www.wrike.com/open.htm?id=" + this._task.data.id;
    if (notifications != null) {
      eventData.reminders = {
        useDefault: false,
        overrides: []
      };
      for (i = 0, len = notifications.length; i < len; i++) {
        method = notifications[i];
        eventData.reminders.overrides.push({
          method: method,
          minutes: 0
        });
      }
    }
    newCallback = (function(_this) {
      return function(newEvent) {
        return _this._save(newEvent, newCalendarId, callback);
      };
    })(this);
    if (this._reminderData != null) {
      return calendarUtils.changeEvent(this._reminderData.event.id, this._reminderData.calendarId, newCalendarId, eventData, newCallback);
    } else {
      return calendarUtils.createEvent(newCalendarId, eventData, newCallback);
    }
  };

  Reminder.prototype.updateForTask = function() {
    var reminderDateTime, startDateTime;
    if (this.exists()) {
      startDateTime = this._task.data["startDate"];
      reminderDateTime = this._getBaseDateTime();
      startDateTime.setHours(reminderDateTime.getHours(), reminderDateTime.getMinutes());
      return this._setByDateTime(startDateTime, this._reminderData.calendarId, null, function() {});
    }
  };

  Reminder.prototype._save = function(newEvent, calendarId, callback) {
    this._reminderData = {
      event: newEvent,
      calendarId: calendarId
    };
    this._defaultSettings = {
      calendarId: calendarId,
      reminders: newEvent.reminders
    };
    return taistApi.userData.set(this._task.data.id, {
      eventId: newEvent.id,
      calendarId: calendarId
    }, (function(_this) {
      return function() {
        return taistApi.userData.set("defaultSettings", _this._defaultSettings, function() {
          return callback();
        });
      };
    })(this));
  };

  return Reminder;

})();

drawAuthorization = function() {
  var authButton;
  taistApi.log('drawing authorization');
  authButton = $('<button>', {
    text: 'Authorize Google Calendar',
    click: function() {
      calendarUtils.authorize(function() {
        var currentTask;
        currentTask = wrikeUtils.currentTask();
        if (currentTask != null) {
          return draw(currentTask);
        }
      });
      return false;
    }
  });
  return container.append(authButton);
};

drawRemindersContainer = function() {
  var taskDurationSpan;
  taistApi.log('drawing reminders container');
  taskDurationSpan = $('.x-duration');
  container = $('<span class="taist-reminders-container"></span>');
  return taskDurationSpan.after(container);
};

removeRemindersContainer = function() {
  if (container != null) {
    container.remove();
    return container = null;
  }
};

drawReminderEditControl = function() {
  var calendarSelect, cancelLink, displayData, emailCheck, hoursSelect, minutesSelect, reminderEditControl, setLink, smsCheck;
  container.html('');
  reminderEditControl = $('<span></span>');
  displayData = reminder.getDisplayData();
  smsCheck = createNotificationCheck("Sms", "sms", displayData);
  emailCheck = createNotificationCheck("E-mail", "email", displayData);
  hoursSelect = createTimeSelect(displayData.hoursRange, displayData.hours);
  minutesSelect = createTimeSelect(displayData.minutesRange, displayData.minutes);
  setLink = $('<a></a>', {
    text: "Set",
    click: function() {
      var useEmail, useSms;
      useSms = smsCheck.check.is(':checked');
      useEmail = emailCheck.check.is(':checked');
      return reminder.set(hoursSelect.val(), minutesSelect.val(), calendarSelect.val(), useSms, useEmail, function() {
        return drawReminderView();
      });
    }
  });
  cancelLink = $("<a></a>", {
    text: 'Cancel',
    click: function() {
      return drawReminderView();
    }
  });
  calendarSelect = createCalendarSelect(displayData.calendars, displayData.currentCalendar);
  reminderEditControl.append(icons.reminderExists, ': ', hoursSelect, '-', minutesSelect, ' ', smsCheck.check, smsCheck.label, ' ', emailCheck.check, emailCheck.label, ' ', calendarSelect, ' ', setLink, ' / ', cancelLink);
  return container.append(reminderEditControl);
};

createNotificationCheck = function(caption, id, displayData) {
  return {
    check: $('<input>', {
      type: "checkbox",
      checked: displayData.usedNotifications[id],
      id: "taist-reminder-" + id
    }),
    label: $("<label for=\"Taist-reminder-" + id + "\">" + caption + "</label>")
  };
};

createTimeSelect = function(timeValues, currentValue) {
  var closestValue, i, j, len, len1, option, timeSelect, timeValue;
  closestValue = timeValues[0];
  for (i = 0, len = timeValues.length; i < len; i++) {
    timeValue = timeValues[i];
    if (timeValue <= currentValue) {
      closestValue = timeValue;
    }
  }
  timeSelect = $('<select></select>');
  for (j = 0, len1 = timeValues.length; j < len1; j++) {
    timeValue = timeValues[j];
    option = $('<option></option>', {
      text: timeValue,
      val: timeValue,
      selected: timeValue === closestValue
    });
    timeSelect.append(option);
  }
  return timeSelect;
};

createCalendarSelect = function(calendarsList, currentCalendarId) {
  var calendar, calendarSelect, i, len;
  calendarSelect = $('<select></select>');
  for (i = 0, len = calendarsList.length; i < len; i++) {
    calendar = calendarsList[i];
    calendarSelect.append($('<option></option>', {
      text: calendar.summary,
      val: calendar.id,
      selected: currentCalendarId === calendar.id
    }));
  }
  return calendarSelect;
};

drawReminderView = function() {
  var deleteLink, displayData, editLink, iconHtml, linkText;
  console.log('started drawing');
  container.html('');
  linkText = null;
  iconHtml = null;
  if (reminder.exists()) {
    displayData = reminder.getDisplayData();
    iconHtml = icons.reminderExists;
    linkText = "<span class=\"taist-reminders-linkText\">" + displayData.hours + ":" + displayData.minutes;
  } else {
    iconHtml = icons.noReminder;
    linkText = "";
  }
  editLink = $("<a></a>", {
    click: function() {
      return drawReminderEditControl();
    },
    style: "border-bottom-style:none;"
  });
  editLink.append(iconHtml, linkText);
  container.append(editLink);
  if (reminder.exists()) {
    deleteLink = $('<a></a>', {
      text: 'X',
      click: function() {
        return reminder["delete"](function() {
          return drawReminderView();
        });
      },
      title: 'Delete'
    });
  }
  return container.append(' (', deleteLink, ')');
};

calendarUtils = {
  _client: null,
  _auth: null,
  _api: null,
  _authorized: false,
  init: function(callback) {
    var jsonpCallbackName;
    jsonpCallbackName = 'calendarUtilsInitAfterApiLoad';
    window[jsonpCallbackName] = (function(_this) {
      return function() {
        delete window[jsonpCallbackName];
        return _this._waitForGapiAndInit(callback);
      };
    })(this);
    return $('body').append("<script src=\"https://apis.google.com/js/client.js?onload=" + jsonpCallbackName + "\"></script>");
  },
  _waitForGapiAndInit: function(callback) {
    var gapi;
    gapi = window["gapi"];
    this._client = gapi.client;
    this._auth = gapi.auth;
    this._client.setApiKey('AIzaSyCLQdexpRph5rbV4L3V_9i0rXRRNiib304');
    return window.setTimeout(((function(_this) {
      return function() {
        return _this._getExistingAuth(callback);
      };
    })(this)), 0);
  },
  _getExistingAuth: function(callback) {
    return this._getAuth(true, callback);
  },
  authorize: function(callback) {
    return this._getAuth(false, callback);
  },
  _getAuth: function(useExistingAuth, callback) {
    var authOptions;
    authOptions = {
      client_id: '181733347279',
      scope: 'https://www.googleapis.com/auth/calendar',
      immediate: useExistingAuth
    };
    return this._auth.authorize(authOptions, (function(_this) {
      return function(authResult) {
        _this._authorized = authResult && (authResult.error == null);
        if (_this._authorized) {
          return _this._loadCalendarApi(callback);
        } else {
          return callback();
        }
      };
    })(this));
  },
  _loadCalendarApi: function(callback) {
    return this._client.load("calendar", "v3", (function(_this) {
      return function() {
        _this._api = _this._client["calendar"];
        return callback();
      };
    })(this));
  },
  authorized: function() {
    return this._authorized;
  },
  loadCalendars: function(callback) {
    var request;
    request = this._api["calendarList"].list({
      minAccessRole: "writer",
      showHidden: true
    });
    return request.execute((function(_this) {
      return function(response) {
        return callback(response.items);
      };
    })(this));
  },
  getEvent: function(eventId, calendarId, callback) {
    return this._accessEvent("get", {
      calendarId: calendarId,
      eventId: eventId
    }, callback);
  },
  deleteEvent: function(eventId, calendarId, callback) {
    return this._accessEvent("delete", {
      calendarId: calendarId,
      eventId: eventId
    }, callback);
  },
  changeEvent: function(eventId, currentCalendarId, newCalendarId, eventData, callback) {
    taistApi.log("changing: ", arguments);
    return this._accessEvent("update", {
      resource: eventData,
      calendarId: currentCalendarId,
      eventId: eventId
    }, (function(_this) {
      return function(newEvent) {
        if (currentCalendarId !== newCalendarId) {
          return _this._moveEvent(eventId, currentCalendarId, newCalendarId, callback);
        } else {
          return callback(newEvent);
        }
      };
    })(this));
  },
  createEvent: function(calendarId, eventData, callback) {
    return this._accessEvent("insert", {
      calendarId: calendarId,
      resource: eventData
    }, callback);
  },
  _moveEvent: function(eventId, currentCalendarId, newCalendarId, callback) {
    taistApi.log("moving: ", arguments);
    return this._accessEvent("move", {
      calendarId: currentCalendarId,
      destination: newCalendarId,
      eventId: eventId
    }, callback);
  },
  _accessEvent: function(method, params, callback) {
    return this._api.events[method](params).execute(function(eventOrResponse) {
      if (eventOrResponse.error != null) {
        return taistApi.error("couldn't " + method + " event: ", params, eventOrResponse.error);
      } else {
        return callback(eventOrResponse);
      }
    });
  }
};

wrikeUtils = {
  me: function() {
    return $wrike.user.getUid();
  },
  myTaskRoles: function(task) {
    var condition, role, roleConditions;
    roleConditions = {
      owner: (function(_this) {
        return function() {
          return task.data['responsibleList'].indexOf(_this.me()) >= 0;
        };
      })(this),
      author: (function(_this) {
        return function() {
          return (task.get('author')) === _this.me();
        };
      })(this)
    };
    return (function() {
      var results;
      results = [];
      for (role in roleConditions) {
        condition = roleConditions[role];
        if (condition()) {
          results.push(role);
        }
      }
      return results;
    })();
  },
  currentUserIsResponsibleForTask: function(task) {
    return ((this.myTaskRoles(task)).indexOf('owner')) >= 0;
  },
  currentTaskView: function() {
    var taskViewId;
    taskViewId = $('.wspace-task-view').attr('id');
    if (taskViewId != null) {
      return window.Ext.ComponentMgr.get(taskViewId);
    }
  },
  currentTask: function() {
    var ref;
    return (ref = this.currentTaskView()) != null ? ref['record'] : void 0;
  },
  onTaskViewRender: function(callback) {
    var cb, currentTaskView, taskViewClass;
    cb = function(taskView) {
      return callback(taskView["record"], taskView);
    };
    taskViewClass = window.w2.folders.info.task.View;
    taistApi.aspect.before(taskViewClass, "showRecord", function() {
      return cb(this);
    });
    currentTaskView = this.getCurrentTaskView();
    if (currentTaskView != null) {
      return cb(currentTaskView);
    }
  },
  onCurrentTaskChange: function(callback) {
    return taistApi.wait.change(((function(_this) {
      return function() {
        return _this.currentTask();
      };
    })(this)), function(task) {
      if (task != null) {
        return taistApi.wait.once((function() {
          return task.data.title != null;
        }), function() {
          return callback(task);
        });
      }
    });
  },
  onCurrentTaskSave: function(callback) {
    return taistApi.aspect.after($wrike.record.Base.prototype, 'getChanges', function() {
      if (this === wrikeUtils.currentTask()) {
        return callback(this);
      }
    });
  }
};

icons = {
  noReminder: '<img class="taist-reminders-reminder-icon" title="Add reminder" alt="Add reminder" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAACXBIWXMAAAsTAAALEwEAmpwYAAACf2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNC40LjAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iPgogICAgICAgICA8ZGM6dGl0bGU+CiAgICAgICAgICAgIDxyZGY6U2VxPgogICAgICAgICAgICAgICA8cmRmOmxpIHhtbDpsYW5nPSJ4LWRlZmF1bHQiPmdseXBoaWNvbnM8L3JkZjpsaT4KICAgICAgICAgICAgPC9yZGY6U2VxPgogICAgICAgICA8L2RjOnRpdGxlPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIj4KICAgICAgICAgPHhtcDpDcmVhdG9yVG9vbD5BZG9iZSBQaG90b3Nob3AgQ1M2IChNYWNpbnRvc2gpPC94bXA6Q3JlYXRvclRvb2w+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgopxlZkAAAB0ElEQVRIDa1W23HCMBCMTf7jDqIOcDqgA1pwKsAMj2++GRigglBC6EAdBDogHUABQHYZiZHkkzFJNCMknXb3dHeycXK5XJ6atOFwuASuZ7Cr2WxWNuGlTUDE4CDKYt25tcXG5F4E4/E4P51OkyRJuq4IeJtWqzWZTqdb1x7Oax0MBoMCwh8hyV3D0ft8Pl+7NncedcCTn8/nL4B36G2XFM7TNH2LRRKtAdMCIYpr9NpmsCIm6oA5R/8Ey94cUYDGsD4uUHQwGo06BCG/mQuum1tOiBEdIPc5gN9wwLFRM5wKVnSAkHOI7zGqCiNiIEfaEh0AmIOwxfgqkSK2hxzUXsuIA5FTiSBWrIioZ5a4FQcolgLriJ557AYLw/WQ3pPc7/czvF/2KLA2BRbD9hT8xREPnVosFgdrvkVgxDU27Oaj4tR8wQE1tbhguznAxhJrhdNvcfrudfd3P22jdWUnZVkyLRqrNsQ3fxR3j7RDujqMgOEo7vyjOOUUepaiIHtMCnS+Of+rUaugtnSLOoiE/wUcGd29Yu+Q2gP+EzTrh7Ro9xbxjXm3s04hTrKFGK6fm+QEl2CCr4qei4VthXXp2qS5lyIJYG3ms6Uw63XTz5YfqiH1WdCp6QMAAAAASUVORK5CYII=" />',
  reminderExists: '<img class="taist-reminders-reminder-icon" title="Reminder set at" alt="Reminder set at" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAACXBIWXMAAAsTAAALEwEAmpwYAAACf2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNC40LjAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iPgogICAgICAgICA8ZGM6dGl0bGU+CiAgICAgICAgICAgIDxyZGY6U2VxPgogICAgICAgICAgICAgICA8cmRmOmxpIHhtbDpsYW5nPSJ4LWRlZmF1bHQiPmdseXBoaWNvbnM8L3JkZjpsaT4KICAgICAgICAgICAgPC9yZGY6U2VxPgogICAgICAgICA8L2RjOnRpdGxlPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIj4KICAgICAgICAgPHhtcDpDcmVhdG9yVG9vbD5BZG9iZSBQaG90b3Nob3AgQ1M2IChNYWNpbnRvc2gpPC94bXA6Q3JlYXRvclRvb2w+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgopxlZkAAAB5klEQVRIDa1W3W3CMBC+Qy1UKlXpBM0G0A3YoCuEl/48wQiMAE+t+gIjtBtkg8IGdIJSCalVEFw/OxBwck5SqZYi+z5/9519PlthEaEqjR+aIxLpWy7zWJ5Xgyp+tSoky9lKkHKPxymoD7hsB3zX7BDJkJhuHQmhNyIeystq5uAZozAAxENimWR8XFO4hyBTFzxY3gB25SzvoM7xtQ8uykj4xreTgjNAWow4c6RIZiDLzWCJ6Q+Q5Pw1rRzVfQdmz+eIqwbgx4uu5TC3jriFw9Qnw1ID0HaDyqEPEjJ9tZb45Lh6AGII8wLlGeQ8vIDxyTdPAKycaQb6dd7Fi/wpQHFZ6jFUn9wOfIela7qo5psLQBuTd/5CebZc9wqW9XV5zk3m3lWL6usFxCOcAQKV3GBXCxYWFp8GMvlc7qfSHSTicYTK2U+qOd076r1cUj2OrNaOkAbAxAgrCFD7s9zLqav50HailUwzhS2kxawc6TBPcMG19yl68DnF9W6Nzn5wmBxY0v+JQ44Do12Tp+8F8h5S8iyj+5eGJ15Co61UUdxFiA5WgN6WatlhQ4yX4EbwmyEt0XEVoSKl9DPnlOVpWJZj7BNELW+N9ZDvz/sOscFj2AMHUwwnRcp8CiW/LRRagGla9bflF7nn2hBRMZnFAAAAAElFTkSuQmCC">'
};

module.exports = {
  start: start
};

},{}]},{},[]);
;return require("addon")}