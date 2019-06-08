define([
	"app",
	"marionette",
	"apps/home/signin/signin_view",
	"apps/common/not_found",
	"apps/home/signin/test_mdp_view",
	"apps/home/signin/new_eleve_view",
	"apps/common/alert_view",
], function(
	app,
	Marionette,
	SigninView,
	NotFoundView,
	TestMdpView,
	NewEleveView,
	AlertView
){
	var Controller = Marionette.Object.extend({
		channelName: "entities",

		showSignin: function(){
			app.trigger("header:loading", true);
			var channel = this.getChannel();
			require(["entities/dataManager"], function(){
				var fetching = channel.request("classes:entities");
				$.when(fetching).done(function(items){
					var listClassesView = new SigninView({
						collection: items
					});

					listClassesView.on("childview:classe:join", function(childView){
						var classe = childView.model;
						require(["entities/user"], function(User){
							var newUser = new User({ nomClasse:classe.get("nom"), idClasse:classe.get("id")});
							var mdp_view = new TestMdpView({ model: newUser });

							mdp_view.on("form:submit", function(data_test){
								testingMdp = newUser.testClasseMdp(data_test.mdp);
								app.trigger("header:loading", true);
								$.when(testingMdp).always(function(){
									app.trigger("header:loading", false);
								}).done(function(){
									newUser.set("classeMdp", data_test.mdp);
									mdp_view.trigger("dialog:close");

									// Débug : Réutiliser la vue de l'autre app n'est peut-être pas idéal
									new_eleve_view = new NewEleveView({ model: newUser });

									new_eleve_view.on("form:submit", function(data_user){
										// Dans ce qui suit, le handler error sert s'il y a un problème avec la requête
										// Mais la fonction renvoie false directement si le save n'est pas permis pour ne pas vérifier des conditions comme un terme vide
										var savingUser = newUser.save(data_user);
										if (savingUser){
											app.trigger("header:loading", true);
											$.when(savingUser).done(function(){
												new_eleve_view.trigger("dialog:close");
												var alertView = new AlertView({
													title: "Inscription réussie",
													message:"Vous avez créé un compte. Vous pouvez maintenant vous connecter.",
													dismiss: true,
													type:"success"
												});
												app.regions.getRegion('message').show(alertView);
												app.trigger("home:show");
											}).fail(function(response){
												if(response.status == 422){
													new_eleve_view.triggerMethod("form:data:invalid", response.responseJSON.errors);
												} else {
													alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code "+response.status+"/026]");
												}
											}).always(function(){
												app.trigger("header:loading", false);
											});
										} else {
											new_eleve_view.triggerMethod("form:data:invalid",newUser.validationError);
										}

									});

									app.regions.getRegion('dialog').show(new_eleve_view);
								}).fail(function(response){
									if(response.status == 422){
										mdp_view.triggerMethod("form:data:invalid", {mdp:"Mot de passe incorrect."});
									}
									else{
										alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code "+response.status+"/027]");
									}
								});
							});

							app.regions.getRegion('dialog').show(mdp_view);

						});
					});
					app.regions.getRegion('main').show(listClassesView);
				}).fail(function(response){
					var alertView = new AlertView();
					app.regions.getRegion('main').show(alertView);
				}).always(function(){
					app.trigger("header:loading", false);
				});
			});
		}
	});

	return new Controller();
});
