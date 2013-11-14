App = Ember.Application.create( {
  LOG_TRANSITIONS: true
});

App.Router.map(function() {
  this.route("settings", { path: "/settings" });
  this.route("tab", { path: "/tab/:tabname" });
});

App.IndexRoute = Ember.Route.extend({
    model: function () { 
        var tabs_url = "/tabs/list";
        return Ember.$.getJSON(tabs_url);
    }
});

App.SettingsRoute = Ember.Route.extend({
    model: function () { return [ 
        { "name" : "AAA" },
        { "name" : "BBB" },
        { "name" : "CCC" }
    ];
    }
});

App.TabRoute = Ember.Route.extend({
    setupController: function (controller, model) {
        controller.set('model', model);
    },
    model: function (params) { 
        var tabs_url = "/tabdata/"+ params.tabname.toLowerCase();
        return Ember.$.getJSON(tabs_url);
    }
});
App.TabController = Ember.ObjectController.extend({
    actions: {
        toggle: function (article) {
            console.log('hi');
            console.log(article);
        }
    }
});
