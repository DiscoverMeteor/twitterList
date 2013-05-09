Session.set('usersLoaded', false);

Meteor.subscribe('allUsers', function(){
	Session.set('usersLoaded', true);
});

Template.content.users = function () {
	return Meteor.users.find();
};

Template.user.rendered = function(){
	// if(Meteor.user() && !Meteor.loggingIn())
		// console.log(this.data.services.twitter.screenName)
}
Template.user.usersReady = function(){
	return Session.get('usersLoaded');
}