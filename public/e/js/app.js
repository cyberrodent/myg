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
    feed_data: attr(),
    feed_len: attr(),
    tab: attr()
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
});

App.FeedlistController = Ember.ArrayController.extend({
  
 

});

App.TabController = Ember.ObjectController.extend({
    needs: "feedlist",
    tab_name : "",
    feedlistController: Ember.computed.alias("controllers.feedlist"),
});


App.TabRoute = Ember.Route.extend({
    tab_name : '',
    setupController: function (controller, model) {
        self = this;
        controller.set('model', model);
        controller.set('tab_name', this.tab_name);
        this.controllerFor('feedlist').set('model', 
            this.store.filter('feed', function (e) { 
                if (self.tab_name == e.get('tab')) {
                    return e;
                }
            } )
        )
    },
    model: function (params) {
        var tabs_url = "/tabdata/"+ params.tabname.toLowerCase();
        var self = this;

        var back = Ember.$.getJSON(tabs_url, function (indata) {

//            self.store.unloadAll('feed');
            var i = 0,
              ii = 0,
              data = indata[0],
              j = data.tab_data.length;
            self.tab_name = data.tab_name;
            for (i=0; i<j; i++) {
                var feed = data.tab_data[i];
                var feed_len = feed.feed_data.length;
                feed.feed_len = feed_len;
                feed.tab = data.tab_name;
                self.store.push('feed', feed);
                for (ii = 0; ii < feed_len; ii++) {
                    self.store.push('article', feed.feed_data[ii]);
                }
            }
            var f  = self.store.all('article');
            console.log(f);
            return f; 
        });
        back.then(function (d) {
            console.log('BACK');
            console.log(d);

       
        });
        return back;
    },
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

Ember.Handlebars.helper('firstarticle', function (value) {
    var e = value[0];
    out = e.title;
    return out;
});
