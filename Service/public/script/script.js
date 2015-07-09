var homeConnectApp = angular.module( 'HomeConnect', [ 'ngMaterial' ] );

homeConnectApp.controller('mainController', function ($scope, $rootScope, $http) {
  
  $http.get('/getHomeInfo').success(function(data, status){
    $scope.rooms = Object.keys(data);
  });

  $scope.data = {
    cb1: true,
    cb4: true,
    cb5: false
  };

  $scope.onChange = function(swtch,cbState) {
    console.log(swtch + " - "+ cbState);
    $http.get('/setDeviceStatus?room=Room1&'+swtch + "="+ cbState).success(function(data, status){
      console.log(data);
    });
  };
});

// http://appmon.vip.qa.ebay.com/logview/environment/core_stagingsql/pools
