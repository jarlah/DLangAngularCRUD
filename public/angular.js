var app = angular.module('myApp', []);
app.controller('personsCtrl', function($scope, $http) {
  var getPersons = function() {
      $http.get("/api/person").success(function(response) {
          $scope.persons = response;
      });
  };
  
  $scope.delete = function(id) {
      $http.delete("/api/person/" + id).success(function(response) {
          getPersons();
      });
  };
  
  $scope.edit = function(person) {
      $scope.$root.$broadcast("editPerson", person);
  };
  
  $scope.$on("newPersonAdded", function () {
      getPersons();
  });
      
  getPersons();
});

app.controller('formCtrl', function ($scope, $http) {
	var blankPerson = function() {
	  return {
	    person: {
	      id: undefined,
	      firstName: undefined,
	      lastName: undefined
	    }
	  };
	};
	$scope.$on("editPerson", function (event, _person) {
	  $scope.form = {
	  	person: _person
	  };
	});
	$scope.form = blankPerson();
	$scope.submitForm = function() {
	  if ($scope.form.person._id) {
	    $http({
	      url: "/api/person/" + $scope.form.person._id,
	      data: $scope.form,
	      method: 'PUT'
	    }).success(function(data){
	      $scope.$root.$broadcast("newPersonAdded");
	      $scope.form = blankPerson();
	    }).error(function(err){"ERR", console.log(err)})	
	  } else {
	    $http({
	      url: "/api/person",
	      data: $scope.form,
	      method: 'POST'
	    }).success(function(data){
	      $scope.$root.$broadcast("newPersonAdded");
	      $scope.form = blankPerson();
	    }).error(function(err){"ERR", console.log(err)})
	  }
    };
});