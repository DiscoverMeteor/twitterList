Meteor.subscribe('allUsers');

Template.content.users = function () {
	return Meteor.users.find();
};