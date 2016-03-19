var prefs = JSON.parse(self.options.defaultOptions);

function Settings() {
  var self = this;

  this.loaded = false;
  this.moduleQueue = [];
  this.events = {};

  // Load the settings
  self.tips = prefs.tips;

  // Quick hack to hide the document before the theme is fully loaded (to avoid
  // the ugly jump) It's animated in by the visual theme
  if (prefs.visualTheme || prefs.highContrast ||
      prefs.grayVisitedLinks || prefs.stickyHeader) {
    document.documentElement.classList.add("hnspecial-theme-preload");
  }
}

Settings.prototype.getUrl = function(name) {
  return self.options.urlBase + name;
};

Settings.prototype.subscribe = function (event, callback) {
  if (!this.events[event]) {
    this.events[event] = [];
  }
  this.events[event].push(callback);
};

Settings.prototype.emit = function (event, data) {
  if (this.events[event]) {
    this.events[event].forEach(function (callback) {
      callback(data);
    });
  }
};

Settings.prototype.applyRequirements = function (requirements, map) {
  var self = this;

  Object.keys(requirements).forEach(function (key) {
    if (map[key]) {
      // Checkbox that can't be activated if the others aren't
      var subordinate = map[key].getElementsByTagName("input")[0];
      var mandatory = requirements[key].map(function (requirement) {
        return map[requirement].getElementsByTagName("input")[0];
      });

      // Preliminary check to prevent invalid conditions
      if (subordinate.checked) {
        var status = true; // Starts enabled
        mandatory.forEach(function (current) {
          // If any mandatory switch is disabled, subordinate is disabled too
          status = status && current.checked;
        });

        subordinate.checked = status;
        _.dispatch("change", subordinate);
        self.updateSettings();
      }

      // Add the change listeners to propagate changes to mandatory switches
      subordinate.addEventListener("change", function () {
        if (this.checked) { // All mandatory checkboxes must be enabled too
          mandatory.forEach(function (current) {
            current.checked = true;
            _.dispatch("change", current);
          });
        }
      });

      // Add the change listeners to propagate changes to subordinate switches
      mandatory.forEach(function (current) {
        current.addEventListener("change", function () {
          if (!this.checked) {
            subordinate.checked = false;
            _.dispatch("change", subordinate);
          }
        });
      });
    }
  });
};

(function () {
  // Run the settings module as soon as possible
  this.HNSpecial = new Settings();
}).call(this);
