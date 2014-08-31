
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  console.log("Hello World");
  response.success("Hello world!");
});

Parse.Cloud.job("eventReminder", function(request, response) {
	console.log("Hello world!");
	var query = new Parse.Query("Event");
	query.each(function(event) {
	  console.log(event.time);
	});
	response.success("eventReminder");
});
