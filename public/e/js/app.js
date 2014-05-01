/*
 * Setup
 */

/* Start the App */
App = Ember.Application.create( {
//    LOG_STACKTRACE_ON_DEPRECATION : true,
        LOG_BINDINGS                  : true,
        LOG_TRANSITIONS               : true,
//        LOG_TRANSITIONS_INTERNAL      : true,
        LOG_VIEW_LOOKUPS              : true,
//        LOG_ACTIVE_GENERATION         : true

});



App.Router.map(function() {

    this.resource("index", { path: "/" }, function () {
        this.resource("tab", { path: "/tab/:tabname" }, function () {
            this.resource("article", { path: "/article/:article_id" });
            this.resource("feed", { path: "/feed/:feed_id" });
        } );
    } );

    this.route("settings", { path: "/settings" });

});

App.ApplicationSerializer = DS.RESTSerializer.extend({
    normalizePayload: function (type, payload) {
        console.log("this is the payload");
        this._super(type, payload);
    }
});

App.adapter = DS.Adapter.extend({
    serializer: App.ApplicationSerializer
});

App.store = DS.Store.extend({

});

var attr = DS.attr;
/// Feed Model
App.Feed = DS.Model.extend({
    feed_title: attr(),
    feed_data: attr()
});


/// Article Model
App.Article = DS.Model.extend({
    pubdate : attr(),
    feed_title : attr(),
    title : attr(),
    summary : attr(),
    url: attr()
});






/// IndexRoute
App.IndexRoute = Ember.Route.extend({
    model: function () {
        var tabs_url = "/tabs/list";
        return Ember.$.getJSON(tabs_url);
    }
});




/// SettingsRoute
App.SettingsRoute = Ember.Route.extend({
    model: function () { return [
        { "name" : "AAA" },
        { "name" : "BBB" },
        { "name" : "CCC" }
    ];
    }
});

App.FeedslistView = Ember.View.extend({
    templateName: 'flistview',
    flist: []
});

/// TabController
App.TabController = Ember.ObjectController.extend({
    needs: "feedlist",
    feeds : function () {
        return App.Feed.find();
    }
});

/// TabRoute
App.TabRoute = Ember.Route.extend({
    setupController: function (controller, model) {
        controller.set('model', model);
    },
    afterModel: function (mm, tt) {
      console.log(mm);
    },
    model: function (params) {
        // App.TabRouteBuilder(params);
        var tabs_url = "/tabdata/"+ params.tabname.toLowerCase();
        var self = this;

        var back = Ember.$.getJSON(tabs_url, function (indata) {
            self.store.unloadAll('feed');
            var i = 0,
              ii = 0,
              data = indata[0],
              j = data.tab_data.length;

            for (i=0; i<j; i++) {
                var feed = data.tab_data[i];
                var feed_len = feed.feed_data.length;

                self.store.push('feed', feed);
                for (ii = 0; ii < feed_len; ii++) {
                    self.store.push('article', feed.feed_data[ii]);
                }
            }
        });
        back.then( function (e) {
            // console.log(e[0]);
            var a = self.store.all('feed');
            var feed_array = a.content.map(function(e) { return e.get('feed_title'); });
            console.log(feed_array);
            self.feed_array = feed_array;
        } );
        return back;
    },
//    afterModel: function() { this.transitionTo('article', this.model().id); }
});


App.FeedRoute = Ember.Route.extend({
    tab: Ember.computed.alias("controllers.tab"),
    model: function (params) {
      console.log("feed route");
      var r = this.store.all('feed');
      console.log(r);
      return r;

    }

});
App.FeedController = Ember.ObjectController.extend({
  needs: "tab"
});

App.FeedlistController = Ember.ObjectController.extend({
  needs: "tab",
  feedlist: ['qweqweqwe','asdfasdfa','xzxcvzxcv']
});

/// ArticleController
App.ArticleController = Ember.ObjectController.extend({
    needs: "tab"
});


/// ArticleRoute
App.ArticleRoute = Ember.Route.extend({
    setupController: function(controller, model) {
         controller.set('model', model);
     },
 });





// Ember.Application.initializer({
//   name: 'feedme',
//
//   initialize: function(container, application) {
//     application.register('feedme:main', App.FeedlistController);
//   }
// });
