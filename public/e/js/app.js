/*
 * Setup
 */
String.prototype.hashCode = function(){
    var hash = 0, i, char;
    if (this.length == 0) return hash;
    for (i = 0, l = this.length; i < l; i++) {
        char  = this.charCodeAt(i);
        hash  = ((hash<<5)-hash)+char;
        hash |= 0; // Convert to 32bit integer
    }
    return hash;
};








/* 
 * Start the App
 */
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


App.store = DS.Store.extend({});

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








/// TabController
App.TabController = Ember.ObjectController.extend({ });

/// TabRoute

App.TabRouteBuilder = function (params) {
    var tabs_url = "/tabdata/"+ params.tabname.toLowerCase();
    var back = Ember.$.getJSON(tabs_url, function (indata) {

        var i = 0;
        var data = indata[0];
        var j = data.tab_data.length;

        for (i=0; i<j; i++) {
            var feed = data.tab_data[i];
            console.log("Checking " + feed.id);
            var newfeed = App.store.createRecord('feed', feed);
            var feed_len = feed.feed_data.length;
            for (ii = 0; ii < feed_len; ii++) {
                var article = feed.feed_data[ii];
                console.log(article.title);
                var newarticle = App.store.createRecord('article', article);
            }
        }
        // var ret = App.store.find('article', {title : params.title} );
        // console.log("returning");
        // console.log(ret.get('title'));
        // return ret;
    });
    return indata;
};

App.TabRoute = Ember.Route.extend({
    setupController: function (controller, model) {
        console.log('TabRoute controller');
        controller.set('model', model);
    },
    model: function (params) { 
        // App.TabRouteBuilder(params);
        var tabs_url = "/tabdata/"+ params.tabname.toLowerCase();

        var self = this;
        var back = Ember.$.getJSON(tabs_url, function (indata) {

            var i = 0;
            var data = indata[0];
            var j = data.tab_data.length;

            for (i=0; i<j; i++) {
                var feed = data.tab_data[i];
                // console.log("Checking " + feed.id);
                var newfeed = self.store.push('feed', feed);

                var feed_len = feed.feed_data.length;
                for (ii = 0; ii < feed_len; ii++) {
                    var article = feed.feed_data[ii];
                    // console.log("Storing: " + article.title);
                    var newarticle = self.store.push('article', article);
                }
            }

            
        });
        return back;
    },
//    afterModel: function() { this.transitionTo('article', this.model().id); }
});

/// ArticleController
App.ArticleController = Ember.ObjectController.extend({ 
    needs: "tab"
});


/// ArticleRoute
App.ArticleRoute = Ember.Route.extend({
   // serialize : function(model) { return { article_id: model.get('id')}; },

    setupController: function(controller, model) {
         controller.set('model', model);
         // console.log("setup article controller"); console.log(model);
     },
//     model:  function (params) { // console.log(params);
//         var ret = this.store.find('article', {id: params.article_id} );
//         if (ret) {
//             return ret;
//         } else {
//             console.log("MAYDAY");
//             return {};
//         }
//     }
 });



