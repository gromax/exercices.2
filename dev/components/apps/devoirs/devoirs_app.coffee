import { app } from 'app'

Router = Backbone.Router.extend {
  routes: {
    "devoirs": "devoirsList"
    "devoir::id": "devoirShow"
    "devoirs/fiche-eleve::id": "aUfShow"
    "devoir::id/exercices": "devoirShowExercices"
    "devoir::id/fiches-eleves": "devoirShowUserfiches"
    "devoir::id/ajout-fiche-eleve": "devoirAddUserfiche"
    "devoir::id/tex": "devoirShowExams"
    "devoir/tex::idT": "examShow"
    "devoir::idUF/exercice::idEF": "showExercicesFaits_Eleve"
    "devoirs/fiche-eleve::idUF/exercice::idEF": "showExercicesFaits"
    "exercices-faits/fiche::idUF/exercice::idEF": "showExercicesFaits"
    "exercices/a-finir(::id)": "showUnfinished"
  }

  devoirsList: ->
    auth = app.Auth
    profFct = ->
      app.Ariane.reset [{ text:"Devoirs", e:"devoirs:list", link:"devoirs"}]
      require("apps/devoirs/list/list_devoirs_controller.coffee").controller.list()

    todo = auth.mapItem {
      "Admin": profFct
      "Prof": profFct
      "Eleve": -> app.trigger "notFound"
      "def": -> app.trigger "home:login"
    }

    todo()

  '''
  devoirShow: (id) ->
    auth = app.Auth
    devoirEdition = ->
      # Affichage du devoir afin d'édition
      app.Ariane.reset [
        { text:"Devoirs", e:"devoirs:list", link:"devoirs"}
        { text:"Devoir ##{id}", e:"devoir:show", data:id, link:"devoir:#{id}"}
      ]

      require("apps/devoirs/edit/edit_devoir_controller.coffee").controller.show(id)

    exoFicheRun = ->
      app.Ariane.reset []
      require("apps/devoirs/run/run_controller").controller.showEleve(id)

    todo = auth.mapItem {
      "Admin": devoirEdition
      "Prof": devoirEdition
      "Eleve": exoFicheRun
      "def": -> app.trigger "home:login"
    }

    todo()

	aUfShow: function(idUF){
		# Permet au professeur de voir la fiche devoir d'un élève
		var auth = app.Auth;

		var exoFicheRun = function(){
			app.Ariane.reset([{ text:"Devoirs", e:"devoirs:list", link:"devoirs"}]);

			require(["apps/devoirs/run/run_controller"], function(Controller){
				Controller.showProf(idUF);
			});
		}

		var todo = auth.mapItem({
			"Admin": exoFicheRun,
			"Prof": exoFicheRun,
			"Eleve": function(){ app.trigger("notFound"); },
			"def": function(){ app.trigger("home:login"); },
		});
		todo();
	},

	devoirShowExercices: function(id){
		var auth = app.Auth;
		var devoirEF_list = function(){
			app.Ariane.reset([
				{ text:"Devoirs", e:"devoirs:list", link:"devoirs"},
				{ text:"Devoir #"+id, e:"devoir:show", data:id, link:"devoir:"+id},
				{ text:"Exercices", e:"devoir:showExercices", data:id, link:"devoir:"+id+"/exercices"},
			]);

			require(["apps/devoirs/edit/edit_fiche_controller"], function(Controller){
				Controller.showExercices(id);
			});
		}

		var todo = auth.mapItem({
			"Admin": devoirEF_list,
			"Prof": devoirEF_list,
			"Eleve": function(){ app.trigger("notFound"); },
			"def": function(){ app.trigger("home:login"); },
		});
		todo();
	},

	devoirShowUserfiches: function(id){
		var auth = app.Auth;
		var devoirUF_list = function(){
			app.Ariane.reset([
				{ text:"Devoirs", e:"devoirs:list", link:"devoirs"},
				{ text:"Devoir #"+id, e:"devoir:show", data:id, link:"devoir:"+id},
				{ text:"Fiches élèves", e:"devoir:showUserfiches", data:id, link:"devoir:"+id+"/fiches-eleves"},
			]);
			require(["apps/devoirs/edit/edit_fiche_controller"], function(Controller){
				Controller.showUserfiches(id);
			});
		}

		var todo = auth.mapItem({
			"Admin": devoirUF_list,
			"Prof": devoirUF_list,
			"Eleve": function(){ app.trigger("notFound"); },
			"def": function(){ app.trigger("home:login"); },
		});
		todo();
	},

	devoirAddUserfiche: function(id){
		var auth = app.Auth;
		var devoirAddUF = function(){
			app.Ariane.reset([
				{ text:"Devoirs", e:"devoirs:list", link:"devoirs"},
				{ text:"Devoir #"+id, e:"devoir:show", data:id, link:"devoir:"+id},
				{ text:"Fiches élèves", e:"devoir:showUserfiches", data:id, link:"devoir:"+id+"/fiches-eleves"},
				{ text:"Ajouter", e:"devoir:showAddUserfiche", data:id, link:"devoir:"+id+"/ajout-fiche-eleve"}
			]);
			require(["apps/devoirs/edit/edit_fiche_controller"], function(Controller){
				Controller.showAddUserfiche(id);
			});
		}

		var todo = auth.mapItem({
			"Admin": devoirAddUF,
			"Prof": devoirAddUF,
			"Eleve": function(){ app.trigger("notFound"); },
			"def": function(){ app.trigger("home:login"); },
		});
		todo();
	},

	devoirShowExams: function(id){
		var auth = app.Auth;
		var fct = function(){
			app.Ariane.reset([
				{ text:"Devoirs", e:"devoirs:list", link:"devoirs"},
				{ text:"Devoir #"+id, e:"devoir:show", data:id, link:"devoir:"+id},
				{ text:"Tex"},
			]);
			require(["apps/devoirs/edit/edit_fiche_controller"], function(Controller){
				Controller.showExams(id);
			});
		}

		var todo = auth.mapItem({
			"Admin": fct,
			"Prof": fct,
			"Eleve": function(){ app.trigger("notFound"); },
			"def": function(){ app.trigger("home:login"); },
		});
		todo();

	},

	examShow: function(idT){
		var auth = app.Auth;
		var fct = function(){
			app.Ariane.reset([
				{ text:"Devoirs", e:"devoirs:list", link:"devoirs"},
			]);
			require(["apps/devoirs/exam/exam_controller"], function(Controller){
				Controller.show(idT);
			});
		}

		var todo = auth.mapItem({
			"Admin": fct,
			"Prof": fct,
			"Eleve": function(){ app.trigger("notFound"); },
			"def": function(){ app.trigger("home:login"); },
		});
		todo();
	},

	showExercicesFaits_Eleve:function(idUF,idEF){
		var auth = app.Auth;
		var forEleve = function(){
			app.Ariane.reset([]);
			require(["apps/devoirs/faits/faits_controller"], function(Controller){
				Controller.listForEleve(idUF,idEF);
			});
		}
		var todo = auth.mapItem({
			"Admin": function(){ app.trigger("notFound"); },
			"Prof": function(){ app.trigger("notFound"); },
			"Eleve": forEleve,
			"def": function(){ app.trigger("home:login"); },
		});

		todo();
	},

	showExercicesFaits:function(idUF, idEF){
		var auth = app.Auth;
		var forProf = function(){
			if (!idUF){
				app.trigger("notFound")
			} else if (!idEF) {
				# On affiche la fiche UF pour aiguiller vers les exercices faits par l'élève
				# debug : cette possibilité fait doublon... avec aUfShow
				this.aUfShow(idUF);
			} else {
				app.Ariane.reset([{ text:"Devoirs", e:"devoirs:list", link:"devoirs"}]);
				require(["apps/devoirs/faits/faits_controller"], function(Controller){
					Controller.listForProf(idUF,idEF);
				});
			}
		}

		var todo = auth.mapItem({
			"Admin": forProf,
			"Prof": forProf,
			"Eleve": function(){ app.trigger("notFound"); },
			"def": function(){ app.trigger("home:login"); },
		});

		todo();
	},

	showUnfinished:function(){
		var auth = app.Auth;
		var forEleve = function(){
			app.Ariane.reset([{ text:"Exercices à terminer", e:"faits:unfinished", link:"exercices/a-finir"}]);
			require(["apps/devoirs/faits/faits_controller"], function(Controller){
				Controller.unfinishedForEleve();
			});
		}

		var todo = auth.mapItem({
			"Admin": function(){ app.trigger("notFound"); },
			"Prof": function(){ app.trigger("notFound"); },
			"Eleve": forEleve,
			"def": function(){ app.trigger("home:login"); },
		});

		todo();
	},
  '''
}


router = new Router()

app.on "devoirs:list", ->
	app.navigate "devoirs"
	router.devoirsList()

'''
app.on("devoir:show", function(id){
	app.navigate("devoir:" + id);
	API.devoirShow(id);
});

app.on("devoir:showExercices", function(id){
	app.navigate("devoir:" + id+"/exercices");
	API.devoirShowExercices(id);
});

app.on("devoir:showUserfiches", function(id){
	app.navigate("devoir:" + id+"/fiches-eleves");
	API.devoirShowUserfiches(id);
});

app.on("devoir:addUserfiche", function(id){
	app.navigate("devoir:" + id+"/ajout-fiche-eleve");
	API.devoirAddUserfiche(id);
});

app.on("devoir:exams", function(id){
	# app.navigate("devoir:" + id+"/ajout-fiche-eleve");
	# API.devoirAddUserfiche(id);
	app.navigate("devoir:" + id+"/tex");
	API.devoirShowExams(id);
});

app.on("devoir:exam", function(idT){
	app.navigate("devoir/tex:"+idT);
	API.examShow(idT);
});

app.on("devoirs:fiche-eleve:show", function(id){
	# navigation prof depuis devoir
	app.navigate("devoirs/fiche-eleve:" + id);
	API.aUfShow(id);
});


app.on("devoirs:fiche-eleve:faits", function(idUF,idEF){
	# navigation prof depuis une fiche devoir vers l'élève
	# Voir la liste des exercices faits dans pour une fiche UF
	# et pour l'exercice EF
	app.navigate("devoirs/fiche-eleve:"+idUF+"/exercice:"+idEF);
	API.showExercicesFaits(idUF,idEF);
});

app.on("userfiche:exofiche:faits", function(idUF,idEF){
	# navigation d'un élève
	# Voir la liste des exercices faits dans pour une fiche UF
	# et pour l'exercice EF
	app.navigate("devoir:"+idUF+"/exercice:"+idEF);
	API.showExercicesFaits_Eleve(idUF,idEF);
});


app.on("faits:unfinished", function(){
	# Voir la liste des exercices faits pas terminés
	app.navigate("exercices/a-finir");
	API.showUnfinished();
});
'''
