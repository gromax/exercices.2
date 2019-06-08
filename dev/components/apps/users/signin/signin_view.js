define(["marionette","app","jst"], function(Marionette,app,JST){
	var noView = Marionette.View.extend({
		template: window.JST["home/signin/signin-noview"],
	});

	var ClasseView = Marionette.View.extend({
		template: window.JST["home/signin/signin-item"],
		tagName:"a",
		className:"list-group-item list-group-item-action js-join",
		triggers: {
			"click": "classe:join",
		},
	});

	var ListView = Marionette.CollectionView.extend({
		tagName:"div",
		className: "list-group",
		childView:ClasseView,
		emptyView:noView,
	});

	return ListView;
});
