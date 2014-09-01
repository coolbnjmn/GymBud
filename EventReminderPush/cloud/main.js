
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  console.log("Hello World");
  response.success("Hello world!");
});

Parse.Cloud.job("eventReminder", function(request, response) {
	Parse.Cloud.useMasterKey();
	var Event = Parse.Object.extend("Event");
	console.log("Hello world!");
	var query = new Parse.Query(Event);
	query.equalTo("isVisible", true);
	console.log("creating query: ");
	query.each(function(eventObj) {
	   console.log(eventObj.get("time"));
	   var d = new Date();
	   var currDate = Date.UTC(d.getFullYear(), d.getMonth(), d.getDate(), d.getHours(), d.getMinutes(), d.getSeconds()) + d.getTimezoneOffset()*60*1000;
	   var eventDate = Date.parse(eventObj.get("time"));
	   var duration = eventObj.get("duration");

	   console.log(eventObj.get("activity"));
	   var timeDiff = (eventDate + duration*60*1000) - currDate;
	   console.log(timeDiff);

           if(timeDiff < 0) {
	     // send a push for that event
	     eventObj.set("isVisible", false);
	     eventObj.save(); 
	   }

	 }).then(function() {
	    console.log("set isVisible correctly");
	 }, function(error) {
	    console.log("set isVisible INcorrectly");
	});

	var query2 = new Parse.Query(Event);
	query2.equalTo("isVisible", true);
	query2.each(function(eventObj) {
	   console.log(eventObj.get("time"));
	   var d = new Date();
	   var currDate = Date.UTC(d.getFullYear(), d.getMonth(), d.getDate(), d.getHours(), d.getMinutes(), d.getSeconds()) + d.getTimezoneOffset()*60*1000;
	   var eventDate = Date.parse(eventObj.get("time"));

 		console.log("eventDate: ");
	   console.log(eventDate);
	       console.log("currDate: ");
	   console.log(currDate);

	   var timeDiff = eventDate - currDate;
	   console.log(timeDiff);

           if(timeDiff < 15*60*1000 && timeDiff > 0) {
	     // send a push for that event
	     console.log("sending push");
	     var pushQuery = new Parse.Query(Parse.Installation);
	     var attendeesAndOrganizer = eventObj.get("attendees");
	     if(attendeesAndOrganizer)
	       attendeesAndOrganizer.push(eventObj.get("organizer"));
	     else 
	       attendeesAndOrganizer = [eventObj.get("organizer")];

	     console.log(attendeesAndOrganizer);
	     pushQuery.containedIn("user", attendeesAndOrganizer);
	     Parse.Push.send({
	       where: pushQuery, 
	       data: {
	         alert: "Your event is starting soon!"
	       }
	     }, {
	       success: function() {
	         response.success("pushed");
	       }, error: function(error) {
	         reponse.error("didn't push");
	       }
	     });
	   }

	 }).then(function() {
	   //response.success("printed objects");
	   console.log("sent pushes");
	 }, function(error) {
	   //response.error("error happened");
	   console.log("didn't send pushes");
	});
});
