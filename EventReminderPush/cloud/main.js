var twilio = require("twilio");
var express = require('express');
var app = express();

twilio.initialize("ACed42b9aed728493cddb8c7d35935865b", "dffc6073b68750dfa8f7230c4e1506bf");
app.use(express.bodyParser());

app.post('/receiveSMS', function(req, res) {
	console.log('receive SMS');
	console.log(req.body.Body);

	if(req.body.Body.toLowerCase() == "in" || req.body.Body.toLowerCase() == "out") {
		twilio.sendSMS({
			From: "(650) 614-5446",
			To: req.body.From,
			Body: "It's been noted, and notifications have been sent. Check us out at https://itunes.apple.com/us/app/gymbud/id935537048?ls=1&mt=8"
		}, {
			success: function(httpResponse) {
				console.log(httpResponse);
				res.send('Success');
			}, 
			error: function(httpResponse) {
				console.error(httpResponse);
				res.send('Error');
			}
		});

		if(req.body.Body.toLowerCase() == "in") {
			console.log("in was received");
			// eventQuery
			var contactObj = Parse.Object.extend("Contact");
			var contactQuery = new Parse.Query(contactObj);
			console.log(req.body.From);

			contactQuery.equalTo("phone", req.body.From);
			// contactQuery.
			contactQuery.first({
				success: function(contact) {

					console.log("found contact");
					console.log(contact);
					console.log(contact.get('owner'));
					console.log(contact.get('owner').id);
					var eventObj = Parse.Object.extend("Event");
					var eventQuery = new Parse.Query(eventObj);
					eventQuery.equalTo("organizer", contact.get('owner'));
					eventQuery.descending("createdAt");
					eventQuery.first({
						success: function(foundEvent) {
							console.log(foundEvent);
							var attendees = foundEvent.get('attendees');
							console.log(attendees);
							if(attendees)
								attendees.push(contact);
							else 
								attendees = [contact];
							foundEvent.set("attendees",attendees);
							foundEvent.save(null, {
								success: function(savedEvent) {
									var organizer = foundEvent.get('organizer');
									var userQuery = new Parse.Query(Parse.User);
									userQuery.equalTo("objectId", organizer.id);

									var pushQuery = new Parse.Query(Parse.Installation);

									pushQuery.matchesQuery('user', userQuery);

									Parse.Push.send({
										where: pushQuery, 
										data: {
											alert: contact.get('name')+" has joined your event!",
											badge: "Increment"
										},
									}, {
										success: function() {
											console.log("trying to send push succeeded");
										}, error: function(error) {
											console.log("trying to send push failed");
										}
									});
								}, error: function(error) {
									alert("Error at event saving level: " + error.code + " " + error.message);
								}
							});

						}, error: function(error) {
							alert("Error at event level: " + error.code + " " + error.message);
						}
					});
				}, error: function(error) {
					alert("Error: " + error.code + " " + error.message);
				}
			});
		}
	}
});


// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  console.log("Hello World");
  response.success("Hello world!");
});


Parse.Cloud.define("inviteWithTwilio", function(request, response) {
	console.log(request.params.phone);
	twilio.sendSMS({
		From: "(650) 614-5446",
		To: request.params.phone,
		Body: request.params.body
	}, {
		success: function(httpResponse) {
			console.log(httpResponse);
			response.success("SMS Sent!");
		},
		error: function(httpResponse) {
			console.error(httpResponse);
			response.error("Uh OH, something went wrong");
		}
	});

});
Parse.Cloud.job("eventReminder", function(request, response) {
	Parse.Cloud.useMasterKey();
	var Event = Parse.Object.extend("Event");
	var query = new Parse.Query(Event);
	query.equalTo("isVisible", true);
	query.each(function(eventObj) {
	   var d = new Date();
	   var currDate = Date.UTC(d.getFullYear(), d.getMonth(), d.getDate(), d.getHours(), d.getMinutes(), d.getSeconds()) + d.getTimezoneOffset()*60*1000;
	   var eventDate = Date.parse(eventObj.get("time"));
	   var duration = eventObj.get("duration");

	   var timeDiff = (eventDate + duration*60*1000) - currDate;

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
	   var d = new Date();
	   var currDate = Date.UTC(d.getFullYear(), d.getMonth(), d.getDate(), d.getHours(), d.getMinutes(), d.getSeconds()) + d.getTimezoneOffset()*60*1000;
	   var eventDate = Date.parse(eventObj.get("time"));
	   var duration = eventObj.get("duration");

	  // var end_date =  new Date(Date.parse(eventObj.get("time")).getTime() + eventObj.get("duration")*60000);
	  var end_date = new Date(eventDate + duration * 60 * 1000);
	  console.log("end date: ");
	  console.log(end_date);

 		console.log("eventDate: ");
	   console.log(eventDate);
	       console.log("currDate: ");
	   console.log(currDate);

	   var timeDiff = eventDate - currDate;

           if(timeDiff < 15*60*1000 && timeDiff > -15*60*1000) {
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
	         alert: "Your event is starting soon!",
		  eventObjectId: eventObj.id,
		  eventObj: attendeesAndOrganizer,
		  badge: "Increment"
	       }
	     }, {
	       success: function() {
	         response.success("pushed");
	       }, error: function(error) {
	         reponse.error("didn't push");
	       }
	     });
	     
	     console.log("Object ID: ");
	     console.log(eventObj.id);
	     Parse.Push.send({
	        where: pushQuery, 
		data: {
		  alert: "How was your GymBud?",
		  eventObjectId: eventObj.id,
		  eventObj: eventObj,
		  badge: "Increment"
		},
		push_time: end_date// end date
	       }, {
	        success: function() {
		  response.success("scheduled end of event push");
	       }, error: function(error) {
	          reponse.error("didn't schedule the push")
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

app.listen();
