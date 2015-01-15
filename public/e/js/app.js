/*
 * Setup
 */

/* Start the App */
App = Ember.Application.create( {
    // LOG_STACKTRACE_ON_DEPRECATION : true,
    LOG_BINDINGS                  : true,
    LOG_TRANSITIONS               : true,
    // LOG_TRANSITIONS_INTERNAL      : true,
    LOG_VIEW_LOOKUPS              : true,
    // LOG_ACTIVE_GENERATION         : true

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

// //////////////////////////////////////////////////////////////////
//
//      At some point i tried to get a serializer to do this
//
      App.ApplicationSerializer = DS.RESTSerializer.extend({
          normalizePayload: function (type, payload) {
              console.log("this is the payload");
              this._super(type, payload);
          },
           extractArray: function(store, type, payload) {
                console.log("HOLY MOLY! CALLED EXTRACTARRAY");
                return this._super(store, type, payload);
           }
      });

//      App.adapter = DS.Adapter.extend({
//          serializer: App.ApplicationSerializer
//      });
//
// //////////////////////////////////////////////////////////////////

App.store = DS.Store.extend({

});

var attr = DS.attr;


App.Tab = DS.Model.extend({
    tab_name : attr(),
    tab_data : attr()
});

App.Feed = DS.Model.extend({
    feed_title: attr(),
    feed_data: attr(),
    feed_len: attr(),
    tab: attr()
});

App.Article = DS.Model.extend({
    pubdate : attr(),
    feed_title : attr(),
    title : attr(),
    summary : attr(),
    url: attr()
});

App.ApplicationRoute = Ember.Route.extend({

    model : function (params) {

    /*
     * This is probably wrong in some way which is why its so nasty
     * we make one request for all the data and put the data into
     * the store. This *is* what the serializer ought to do i think?
     */
    var tabs_url = "/tabdata/all";
    var self = this;
    var back = Ember.$.getJSON(tabs_url, function (indata) {
        self.store.unloadAll('feed');
        var a, i = 0, j = 10, ii = 0;
        var tab_count = indata.length;
        // console.log('reading '  + tab_count + " tabs" );

        for (a = 0; a < tab_count; a++) {
            // var data = $.parseJSON(indata[a]);
            var data = indata[a];
            // console.log('data is ');
            // console.log(data['tab_name']);
            self.store.push('tab', data);
            j = data.tab_data.length;
            for (i = 0; i < j; i++) {
                var feed = data.tab_data[i];
                var feed_len = feed.feed_data.length;
                feed.feed_len = feed_len;
                feed.tab = data.tab_name;
                // console.log('the feed');
                // console.log(feed);
                self.store.push('feed', feed);
                for (ii = 0; ii < feed_len; ii++) {
                    // console.log('storing ' + feed.feed_data[ii].title);
                    self.store.push('article', feed.feed_data[ii]);
                }
            }
            var f  = self.store.all('article');
        };
        return back;
    });

},
setupController : function (controller, model) {
    // console.log("Running application route");
    // console.log(this.store.filter('feed').map(function(e){ return e.get('feed_title') }) );
    //  this.controllerFor('tab').set('model', this.model);
}
});

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
                                          );
    },
    model: function (params) {
        this.tab_name = params.tabname;
        return this.store.filter('tab', function (e) { 
            if (e.get('tab_name') === params.tabname) {
                return e;
            }
        });
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
