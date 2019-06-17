import { app } from 'app'

Router = Backbone.Router.extend {
  routes: {
    "exercices(/filter/criterion::criterion)": "exercicesList"
    "exercice::id": "exerciceShow"
    "exercice-fiche::id": "runExoFicheProf"
    "fiche-eleve::idUF/exercice-fiche::idEF":"runExoFiche"
    "exercice-fait::idUE":"runUE"
  }

  exercicesList: (criterion) ->
    app.Ariane.reset [{text:"Exercices", e:"exercices:list", link:"exercices"}]
    require("apps/exercices/list/list_exercices_controller.coffee").controller.list(criterion)

  '''
  exerciceShow: function(id){
    app.Ariane.reset([
      {text:"Exercices", e:"exercices:list", link:"exercices"},
      {text:"Exercice #"+id, e:"exercices:show:", data:id, link:"exercice:"+id}
    ]);
    require(["apps/exercices/show/show_controller"], function(showController){
      showController.execExoForTest(id);
    });
  },

  runExoFicheProf:function(id){
    this.runExoFiche(false, id);
  },

  runExoFiche: function(idUF, idEF){
    var auth = app.Auth;
    var testForProf = function(){
      app.Ariane.reset([
        { text:"Devoirs", e:"devoirs:list", link:"devoirs"},
      ]);
      require(["apps/exercices/show/show_controller"], function(showController){
        showController.execExoFicheForProf(idEF);
      });
    }

    var execForEleve = function(){
      app.Ariane.reset([]);
      require(["apps/exercices/show/show_controller"], function(showController){
        showController.execExoFicheForEleve(idUF, idEF);
      });
    }

    var todo = auth.mapItem({
      "Admin": testForProf,
      "Prof": testForProf,
      "Eleve": execForEleve,
      "def": function(){ app.trigger("home:login"); },
    });
    todo();
  },

  runUE: function(idUE){
    var auth = app.Auth;
    var forProf = function(){
      app.Ariane.reset([
        { text:"Devoirs", e:"devoirs:list", link:"devoirs"},
      ]);
      require(["apps/exercices/show/show_controller"], function(showController){
        showController.execUEForProf(idUE);
      });
    }

    var forEleve = function(){
      app.Ariane.reset([]);
      require(["apps/exercices/show/show_controller"], function(showController){
        showController.execUEForEleve(idUE);
      });
    }

    var todo = auth.mapItem({
      "Admin": forProf,
      "Prof": forProf,
      "Eleve": forEleve,
      "def": function(){ app.trigger("home:login"); },
    });
    todo();
  },
  '''

}

router = new Router()

app.on "exercices:list", ->
  app.navigate "exercices"
  router.exercicesList()

app.on "exercices:filter", (criterion)->
  if criterion
    app.navigate "exercices/filter/criterion:#{criterion}"
  else
    app.navigate "exercices"

'''
app.on("exercice:show", function(id, data){
  app.navigate("exercice:" + id);
  API.exerciceShow(id, data);
});

app.on("exercice-fiche:run", function(idEF, idUF){
  if (idUF) {
    app.navigate("fiche-eleve:"+idUF+"/exercice-fiche:" + idEF);
  } else {
    app.navigate("exercice-fiche:" + idEF);
  }
  API.runExoFiche(idUF, idEF);
});

app.on("exercice-fait:run", function(idUE){
  app.navigate("exercice-fait:"+idUE);
  API.runUE(idUE);
})
'''
