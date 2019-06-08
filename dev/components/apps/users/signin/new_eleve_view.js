define(["app","apps/users/common/user_form_view"], function(app,FormView){
	var NewView = FormView.extend({
		title: "Nouvel Utilisateur",
		initialize: function(){
			this.title = "Rejoindre la classe "+this.model.get("nomClasse");
		},
		showPWD: true,
		ranks: false
	});

	return NewView;
});
